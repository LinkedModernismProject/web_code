(*
    This file is part of 'squall2sparql' <http://www.irisa.fr/LIS/softwares/squall/>

    Sébastien Ferré <ferre@irisa.fr>, équipe LIS, IRISA/Université Rennes 1

    Copyright 2012.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)

type uri = string
type var = string
type label = UserVar of string | Noun of string
type term =
  | Var of var
  | Ref of label
  | Uri of uri
  | Literal of string
  | GraphLiteral of var list * triple list
  | Cons of term * term
and triple = term * term * term 

let string_of_label = function
  | UserVar s -> s
  | Noun s -> "this " ^ s

(* pseudo predicates and prepositions *)
let pseudo_p1_belongs = "belongs"
let list_pseudo_p1 = [pseudo_p1_belongs]
let pseudo_p2_relates = "relates"
let list_pseudo_p2 = [pseudo_p2_relates]
let pseudo_prep_to = "to"
let pseudo_prep_into = "into"
let list_pseudo_prep = [pseudo_prep_to; pseudo_prep_into]
let p2_sublist = "rdf:rest*"


let disjoint xs1 xs2 = not (List.exists (fun x1 -> List.mem x1 xs2) xs1)

let option_map f = function
  | None -> None
  | Some x -> Some (f x)

let option_apply f_opt x =
  match f_opt with
  | None -> x
  | Some f -> f x

let rec fold_while : ('a -> 'a option) -> 'a -> 'a =
  fun f e ->
    match f e with
    | None -> e
    | Some e' -> fold_while f e'

let rec merge lf =
  match merge_aux (List.rev lf) (`True,[]) with
  | `True, [] -> `True
  | f, [] -> f
  | `True, [f] -> f
  | `True, l -> `And l
  | f, l -> `And (f::l)
and merge_aux rev_lf (facc,lacc) =
  match rev_lf with
  | [] -> facc, lacc
  | (`And lf1)::rev_lf1 ->
      merge_aux (List.rev lf1 @ rev_lf1) (facc,lacc)
  | f1::rev_lf1 ->
      match merge_bin f1 facc with
      | None -> merge_aux rev_lf1 (f1,facc::lacc)
      | Some f1acc -> merge_aux rev_lf1 (f1acc,lacc)
and merge_bin f1 f2 =
  match f1, f2 with
  | `True, _ -> Some f2
  | _, `True -> Some f1
  | `Select _, _
  | _, `Select _ -> None
  | `Exists (xs1,f1), `Exists (xs2,f2) ->
      if disjoint xs1 xs2
      then option_map (fun f12 -> `Exists (xs1@xs2, f12)) (merge_bin f1 f2)
      else None
  | `Exists (xs1,f1), f2 ->
      option_map (fun f12 -> `Exists (xs1, f12)) (merge_bin f1 f2)
  | f1, `Exists (xs2,f2) ->
      option_map (fun f12 -> `Exists (xs2, f12)) (merge_bin f1 f2)
  | _ -> Some (bin_and_ f1 f2)
and bin_and_ f1 f2 =
  match f1, f2 with
  | `True, _ -> f2
  | _, `True -> f1
  | `And lf1, `And lf2 -> `And (lf1 @ lf2)
  | `And lf1, _ -> `And (lf1 @ [f2])
  | _, `And lf2 -> `And (f1 :: lf2)
  | _ -> `And [f1; f2]


let and_ = merge

let not_ = function
  | `Not f1 -> f1
  | f1 -> `Not f1

let bool =
  object (self)
    method id f = f
    method label l t = `Label (t, l)
    method func op la res = `Func (op,la,res)
    method modif op lz y f = `Modif (op,lz,y,f)
    method maybe_ f = `Option f
    method or_ lf = `Or lf
    method and_ lf = and_ lf
    method not_ f = not_ f
    method implies f1 f2 = `Forall (f1,f2)
    method true_ = `True
    method is_true f = (f = `True)
    method exists lv f =
      if lv = []
      then f
      else merge [`Exists (lv,`True); f]
    method forall lv f1 f2 =
      let f1 = self#exists lv f1 in
      match f2 with
      | `Forall (f21,f22) ->
	  ( match merge_bin f1 f21 with
	  | Some f121 -> `Forall (f121,f22)
	  | None -> `Forall (f1,f2) )
      | _ -> `Forall (f1,f2)

  end

(* type and operations for env-state monad *)
type ('env,'state,'t) monad = ('env -> 'state -> 't * 'state)
let return x = (fun e s -> x, s)
let fail msg = (fun e s -> failwith msg)
let error exn = (fun e s -> raise exn)
let trial m fexn = (fun e s -> try m e s with exn -> fexn exn e s)
let bind m k = (fun e s -> let x, s' = m e s in k x e s')
let bind_list lm k =
  let rec aux lm lx =
    match lm with
      | [] -> k (List.rev lx)
      | m1::lm1 -> bind m1 (fun x1 -> aux lm1 (x1::lx)) in
  aux lm []
let ask = (fun e s -> e, s)
let get = (fun e s -> s, s)
let set s' = (fun e s -> (), s')
let modify f = (fun e s -> (), f s)
let local f m = (fun e s -> m (f e) s)

class ['f] env =
object
  val query : bool = false
  val args : (uri * term) list = []

  method is_mode_query = query
  method mode_query = {< query = true; >}

  method args = args
  method add_arg uri z = {< args = (uri,z)::args; >}
  method reset_args = {< args = []; >}
end

let mode_query env = env#mode_query
let add_arg uri z env = env#add_arg uri z
let reset_args env = env#reset_args

class ['f] state =
object (self)
  val var_cpt : int = 0
  val selects : (term * 'f) list option = None
  val modif : ('f -> 'f) option = None

  method next_var = {< var_cpt = var_cpt + 1; >}

  method var = "x" ^ string_of_int var_cpt

  method add_whether =
    match selects with
      | None -> {< selects = Some []; >}
      | Some _ -> self

  method add_which x f =
    match selects with
      | None -> {< selects = Some [(x,f)]; >}
      | Some l -> {< selects = Some ((x,f)::l); >}

  method set_modif m1 =
    match modif with
      | None -> {< modif = Some m1; >}
      | Some _ -> failwith "Semantic error: 2 modifiers (e.g., superlatives)"

  method apply_modif f =
    match modif with
      | None -> f
      | Some m1 ->
	match f with
	  | `Exists (xs,f1) -> `Exists (xs, m1 f1)
	  | _ -> m1 f

  method reset_modif =
    match modif with
      | None -> self
      | Some _ -> {< modif = None; >}

  method apply f =
    match selects with
      | None ->
	if modif <> None then failwith "Modifiers (e.g. superlatives) are not allowed in updates";
	f
      | Some l ->
	let lx, lf = List.split l in
	let f = bool#and_ (List.rev (f::lf)) in
	let f = self#apply_modif f in
	`Select (List.rev lx, f)
end

let next_var state = state#next_var
let add_whether state = state#add_whether
let add_which x f state = state#add_which x f
let set_modif m1 state = state#set_modif m1
let reset_modif state = state#reset_modif


let bool0 =
object (self)
  method id s = s
  method fail msg = fail msg
  method label l t = return (bool#label l t)
  method func op larg res = return (bool#func op larg res)
  method maybe_ s = bind s (fun f -> return (bool#maybe_ f))
  method or_ ls = bind_list ls (fun lf -> return (bool#or_ lf))
  method and_ ls = bind_list ls (fun lf -> return (bool#and_ lf))
  method not_ s = bind s (fun f -> return (bool#not_ f))
  method true_ = return bool#true_
  method if_true s s1 s2 = bind s (fun f -> if bool#is_true f then s1 else s2)
  method new_var =
    bind (modify next_var) (fun () ->
      bind get (fun state ->
	return (Var state#var)))
  method new_var_list n =
    if n = 0
    then return []
    else bind self#new_var (fun x -> bind (self#new_var_list (n-1)) (fun lx -> return (x::lx)))
  method exists d =
    bind self#new_var (fun x ->
      bind (d x) (fun f ->
	return (bool#exists [x] f)))
  method forall d1 d2 =
    bind self#new_var (fun x ->
      bind (local mode_query (d1 x)) (fun f1 ->
	bind (d2 x) (fun f2 ->
	  return (bool#forall [x] f1 f2))))
  method the d1 d2 =
    bind self#new_var (fun x ->
      bind (d2 x) (fun f2 ->
	bind ask (fun env ->
	  if env#is_mode_query
	  then bind (d1 x) (fun f1 -> return (bool#exists [x] (bool#and_ [f1; f2])))
	  else bind (local mode_query (d1 x)) (fun f1 -> return (bool#forall [x] f1 f2)))))
  method ifthen s1 s2 =
    bind s1 (fun f1 ->
      bind s2 (fun f2 ->
	return (bool#implies f1 f2)))
  method where s1 s2 =
    bind s1 (fun f1 ->
      bind ask (fun env ->
	if env#is_mode_query
	then bind s2 (fun f2 -> return (bool#and_ [f2; f1]))
	else bind (local mode_query s2) (fun f2 -> return (bool#implies f2 f1))))

  method whether s =
    bind (local mode_query s) (fun f ->
      bind (modify add_whether) (fun () ->
	return f))
  method which d1 d2 =
    bind self#new_var (fun x ->
      bind (local mode_query (d1 x)) (fun f1 ->
	bind (modify (add_which x f1)) (fun () ->
	  bind (local mode_query (d2 x)) (fun f2 ->
	    return f2))))

  method open_modif op lz y s =
    bind (modify (set_modif (bool#modif op lz y))) (fun () ->
      s)
  method close_modif s =
    bind s (fun f ->
      bind get (fun state ->
	bind (modify reset_modif) (fun () ->
	  return (state#apply_modif f))))
    
  method add_arg uri z s = local (add_arg uri z) s
  method reset_args s = local reset_args s
  method from_args f_args =
    bind ask (fun env ->
      return (f_args env#args))

  method tell s =
    let f, state = s (new env) (new state) in
    state#apply f

end


let bool1 =
  object
    method id d x = bool0#id (d x)
    method label l t x = bool0#label l t
    method func op la res x = bool0#func op la res
    method maybe_ d x = bool0#maybe_ (d x)
    method or_ ld x = bool0#or_ (List.map (fun d -> d x) ld)
    method and_ ld x = bool0#and_ (List.map (fun d -> d x) ld)
    method not_ d x = bool0#not_ (d x)
    method true_ x = bool0#true_
    method the r1 r2 x = bool0#the (fun v -> r1 v x) (fun v -> r2 v x)
    method open_modif op lz y d x = bool0#open_modif op lz y (d x)
    method close_modif d x = bool0#close_modif (d x)
  end

let bool2 =
  object
    method id r x y = bool0#id (r x y)
    method label l t x y = bool0#label l t
    method func op la res x y = bool0#func op la res
    method maybe_ r x y = bool0#maybe_ (r x y)
    method or_ lr x y = bool0#or_ (List.map (fun r -> r x y) lr)
    method and_ lr x y = bool0#and_ (List.map (fun r -> r x y) lr)
    method not_ r x y = bool0#not_ (r x y)
    method true_ x y = bool0#true_
    method the t1 t2 x y = bool0#the (fun v -> t1 v x y) (fun v -> t2 v x y)
    method open_modif op ly z r x y= bool0#open_modif op ly z (r x y)
    method close_modif r x y = bool0#close_modif (r x y)
    method compose r1 r2 x y = bool0#exists (fun z -> bool0#and_ [r1 x z; r2 z y])
    method inverse r x y = bool0#id (r y x)
  end

let arg uri z s = bool0#add_arg uri z s
let init d x = bool0#reset_args (d x)

let open_modif op lz x s = bool0#open_modif op lz x s
let close_modif d x = bool0#close_modif (d x)

let rec vars_triples_of_formula = function
  | `Triple (s,p,o) -> [], [(s,p,o)]
  | `And lf -> 
      let l = List.map vars_triples_of_formula lf in
      let llv, llt = List.split l in
      List.flatten llv, List.flatten llt
  | `Exists (xs,f) ->
      let lv, lt = vars_triples_of_formula f in
      let lv = List.fold_right (fun x lv -> match x with Var v -> v::lv | _ -> assert false) xs lv in
      lv, lt
  | _ -> failwith "Invalid graph literal: must be a conjunction of triples"
(*
let graph_literal f =
  let lv, lt = vars_triples_of_formula f in
  GraphLiteral (lv, lt)
*)
let graph_literal s d =
  bind s (fun f ->
    let lv, lt = vars_triples_of_formula f in
    d (GraphLiteral (lv,lt)))

let nil = Uri "rdf:nil"
let cons x l = Cons (x,l)

let stat s p o =
  bind ask (fun env ->
    let args = env#args in
    let s, p, o, args =
      if p = Uri "rdf:type" && o = Uri pseudo_p1_belongs then
	if List.mem_assoc pseudo_prep_to args
	then s, Uri "rdf:type", List.assoc pseudo_prep_to args, List.remove_assoc pseudo_prep_to args
	else failwith "'belong(s)' expects a complement introduced by 'to'"
      else if p = Uri pseudo_p2_relates then
	if List.mem_assoc pseudo_prep_to args
	then o, s, List.assoc pseudo_prep_to args, List.remove_assoc pseudo_prep_to args
	else failwith "'relate(s)' expects a complement introduced by 'to'"
      else s, p, o, args in
    (try 
       let prep = List.find (fun prep -> List.mem_assoc prep args) list_pseudo_prep in
       failwith ("unexpected preposition '" ^ prep ^ "'")
     with _ -> ());
    let f = `Triple (s,p,o) in
    return f)
let triple s p o = return (`Triple (s,p,o))
let a c x = stat x (Uri "rdf:type") c
let rel p x y = stat x p y
let label (l : label) t = bool0#label l t
let unify x y = return (`Unify (x,y))
let matches (lre : string list) x = return (`Matches (x,lre))
let pred1 op x = return (`Pred (op,[x]))
let pred2 op x y = return (`Pred (op,[x;y]))
let func0 op x = bool0#func op [] x
let func1 op x y = bool0#func op [x] y
let proc1 op x =
  bind ask (fun env ->
    let args = env#args in
    return (`Proc1 (op,x,args)))

let context kind x s =
  let rec aux x = function
    | `Exists (xs,f1) -> `Exists (xs, aux x f1)
    | `Forall (f1,f2) -> `Forall (aux x f1, aux x f2)
    | f -> `Context (kind,x,f) in
  bind s (fun f -> return (aux x f))

let aggreg op n g x =
  bind bool0#new_var (fun y ->
    bind (bool0#new_var_list n) (fun lz ->
      bind (g y lz) (fun f ->
	bind get (fun state ->
	  bind (modify reset_modif) (fun () ->
	    return (`Aggreg (op, x, y, lz, state#apply_modif f)))))))

type modif = { order : [`NONE|`DESC|`ASC];
	       offset : int;
	       limit : int;
	     }
let modif_default = { order=`NONE; offset=0; limit=(-1); }

let func1_id = `Id
let pred2_eq = `Eq
let pred2_neq = `Neq
let pred2_geq = `Geq
let pred2_leq = `Leq
let pred2_gt = `Gt
let pred2_lt = `Lt
let proc1_return = `Return
let aggreg_count = `Count
let modif_highest = `Mod { modif_default with order=`DESC; limit=1 }
let modif_lowest = `Mod { modif_default with order=`ASC; limit=1 }

let pol_positive op = op
let pol_negative = function
  | `Gt -> `Lt
  | `Lt -> `Gt
  | `Geq -> `Leq
  | `Leq -> `Geq
  | `Mod modif -> `Mod { modif with order=(match modif.order with `DESC -> `ASC | `ASC -> `DESC | `NONE -> `NONE) }
  | op -> op

let whether s = bool0#whether s
let which d1 d2 = bool0#which d1 d2
let exists d = bool0#exists d (* [x] (d x) *)
let forall d1 d2 = bool0#forall d1 d2
let ifthen s1 s2 = bool0#ifthen s1 s2
let ifthenelse s1 s2 s3 = bool0#and_ [bool0#ifthen s1 s2; bool0#ifthen (bool0#not_ s1) s3]
let the d1 d2 = bool0#the d1 d2
let where s1 s2 = bool0#where s1 s2
let a_number d x = aggreg aggreg_count 0 (fun y lz -> d y) x

let tell a = bool0#tell a

(* formula analysis and validation by adding iterators on resources *)

module VS =
  struct
    module M = Set.Make (struct type t = var let compare = Pervasives.compare end)
    include M

    let rec add x vs =
      match x with
      | Var v -> M.add v vs
      | Ref l -> vs
      | Uri _ -> vs
      | Literal _ -> vs
      | GraphLiteral (lv,lt) ->
	  let vs = List.fold_right (fun (s,p,o) vs -> add s (add p (add o vs))) lt vs in
	  let vs = List.fold_right M.remove lv vs in
	  vs
      | Cons (e,l) -> add e (add l vs)
    let add_list xs vs = List.fold_right add xs vs
    let list xs = add_list xs empty
    let rec remove x vs =
      match x with
      | Var v -> M.remove v vs
      | Ref l -> vs
      | Uri _ -> vs
      | Literal _ -> vs
      | GraphLiteral (_lv,lt) -> List.fold_right (fun (s,p,o) vs -> remove s (remove p (remove o vs))) lt vs
      | Cons (e,l) -> remove e (remove l vs)
    let remove_list xs vs = List.fold_right remove xs vs
    let elements vs = fold (fun v res -> Var v :: res) vs []
    let rec is_bound x vs =
      match x with
      | Var v -> mem v vs
      | Ref l -> true
      | Uri _ -> true
      | Literal _ -> true
      | GraphLiteral (lv,lt) ->
	  let vs = List.fold_right M.add lv vs in
	  List.for_all (fun (s,p,o) -> is_bound s vs && is_bound p vs && is_bound o vs) lt
      | Cons (e,l) -> is_bound e vs && is_bound l vs
    let rec unbounds x vs =
      match x with
      | Var v -> if mem v vs then empty else singleton v
      | Ref l -> empty
      | Uri _ -> empty
      | Literal _ -> empty
      | GraphLiteral (lv,lt) ->
	  let vs = List.fold_right M.add lv vs in
	  List.fold_right
	    (fun (s,p,o) res -> union (unbounds s vs) (union (unbounds p vs) (union (unbounds o vs) res)))
	    lt empty
      | Cons (e,l) -> union (unbounds e vs) (unbounds l vs)
    let unbounds_list xs vs =
      List.fold_right
	(fun x res -> union (unbounds x vs) res)
	xs empty

    let check_gen msg xs vs =
      let unbounds = unbounds_list xs vs in
      if not (is_empty unbounds)
      then failwith (msg ^ String.concat ", " (M.elements unbounds))
    let check_access = check_gen "Some references are out of scope: "
    let check_bound = check_gen "Some references are unbound: "

  end

type mode = Q | U

class validate_env =
object
  val mode : mode = U
  val acc : VS.t = VS.empty

  method mode = mode
  method set_query_mode = {< mode = Q; >}
  method access = acc
  method is_access x = VS.is_bound x acc
  method add_access xs = {< acc = VS.add_list xs acc; >}
  method remove_access x = {< acc = VS.remove x acc; >}
end

class validate_state =
object (self)
  val bound : VS.t = VS.empty
  val refs : (label * VS.t) list = []

  method bound = bound
  method is_bound x = VS.is_bound x bound
  method add_bound xs = {< bound = VS.add_list xs bound; >}
  method remove_bound xs = {< bound = VS.remove_list xs bound; >}
  method reset_bound = {< bound = VS.empty; >}
  method set_bound vs = {< bound = vs; >}

  method add_label x l =
    match x with
      | Var v ->
	(try
	   let vs = List.assoc l refs in
	   {< refs = (l, VS.M.add v vs) :: List.remove_assoc l refs; >}
	 with _ ->
	   {< refs = (l, VS.M.singleton v) :: refs; >})
      | _ -> assert false
  method resolve acc x =
    match x with
      | Var _ -> x
      | Ref l ->
	let vs =
	  try
	    let vs0 = List.assoc l refs in
	    VS.M.inter acc vs0 (* only accessible vars *)
	  with Not_found -> VS.empty in
	( match VS.cardinal vs with
	  | 0 -> failwith ("The reference '" ^ string_of_label l ^ "' cannot be resolved")
	  | 1 -> Var (VS.choose vs)
	  | _ -> failwith ("The reference '" ^ string_of_label l ^ "' is ambiguous") )
      | Uri _ -> x
      | Literal _ -> x
      | Cons (e,l) ->
	Cons (
	  self#resolve acc e,
	  self#resolve acc l)
      | GraphLiteral (lv,lt) ->
	GraphLiteral (lv, 
		      List.map
			(fun (s,p,o) ->
			  (self#resolve acc s,
			   self#resolve acc p,
			   self#resolve acc o))
			lt)
end

(* env modifiers *)
let set_query_mode = (fun env -> env#set_query_mode)
let add_access xs = (fun env -> env#add_access xs)
let remove_access x = (fun env -> env#remove_access x)

(* custom monads *)
let resolve x = (fun env state -> state#resolve env#access x, state)
let resolve_list xs = (fun env state -> List.map (state#resolve env#access) xs, state)
let resolve_args args = (fun env state -> List.map (fun (uri,z) -> (uri, state#resolve env#access z)) args, state)
let check_query_mode msg = bind ask (fun env -> match env#mode with Q -> return () | U -> fail msg)
let check_update_mode msg = bind ask (fun env -> match env#mode with U -> return () | Q -> fail msg)
let check_access xs = bind ask (fun env -> return (VS.check_access xs env#access))
let get_access = bind ask (fun env -> return env#access)
let check_bound xs = bind get (fun state -> return (VS.check_bound xs state#bound))
let add_bound xs = modify (fun state -> state#add_bound xs)
let remove_bound xs = modify (fun state -> state#remove_bound xs)
let get_bound = bind get (fun state -> return state#bound)
let set_bound vs = modify (fun state -> state#set_bound vs)
let reset_bound = modify (fun state -> state#reset_bound)
let add_label x l = modify (fun state -> state#add_label x l)

let validate_run m = fst (m (new validate_env) (new validate_state))

let rec validate = function
  | `And lf ->
    `And (List.map validate lf)
  | `Select (xs,f1) ->
    validate_run
      (bind (local set_query_mode (local (add_access xs) (validate_aux f1))) (fun f1 ->
	bind (check_bound xs) (fun () ->
	  return (`Select (xs,f1)))))
  | f -> validate_run (validate_aux f)
and validate_aux = function
  | `Triple (s,p,o) ->
    bind (resolve s) (fun s ->
      bind (resolve p) (fun p ->
	bind (resolve o) (fun o ->
	  bind (check_access [s;p;o]) (fun () ->
	    bind (add_bound [s;p;o]) (fun () ->
	      return (`Triple (s,p,o)))))))
  | `Label (x,l) ->
    bind (add_label x l) (fun () ->
      return `True)
  | `Unify (x,y) ->
    bind (check_query_mode "Equalities are not allowed in updates") (fun () ->
      bind (resolve x) (fun x ->
	bind (resolve y) (fun y ->
	  bind (check_access [x;y]) (fun () ->
	    bind get (fun state ->
	      match state#is_bound x, state#is_bound y with
		| true, true -> return (`Pred (pred2_eq, [x;y]))
		| true, false -> bind (add_bound [y]) (fun () -> return (`Func (func1_id,[x],y)))
		| false, true -> bind (add_bound [x]) (fun () -> return (`Func (func1_id,[y],x)))
		| false, false -> fail "In equality, at least one side must be bound")))))
  | `Matches (x,lre) ->
    bind (check_query_mode "Patterns are not allowed in updates") (fun () ->
      bind (resolve x) (fun x ->
	bind (check_access [x]) (fun () ->
	  bind (check_bound [x]) (fun () ->
	    return (`Matches (x,lre))))))
  | `Func (op,lx,y) ->
    bind (check_query_mode "Functions are not allowed in updates") (fun () ->
      bind (resolve_list lx) (fun lx ->
	bind (resolve y) (fun y ->
	  bind (check_access (y::lx)) (fun () ->
	    bind (check_bound lx) (fun () ->
	      bind (add_bound [y]) (fun () ->
		return (`Func (op,lx,y))))))))
  | `Pred (op,lx) ->
    bind (check_query_mode "Predicates are not allowed in updates") (fun () ->
      bind (resolve_list lx) (fun lx ->
	bind (check_access lx) (fun () ->
	  bind (check_bound lx) (fun () ->
	    return (`Pred (op,lx))))))
  | `Proc1 (op,x,args) ->
    bind (check_update_mode "Actions are not allowed in queries") (fun () ->
      bind (resolve x) (fun x ->
	bind (resolve_args args) (fun args ->
	  let lz = List.map snd args in
	  bind (check_access (x::lz)) (fun () ->
	    bind (check_bound (x::lz)) (fun () ->
	      return (`Proc1 (op,x,args)))))))
  | `Context (`GRAPH,x,f1) ->
    bind (resolve x) (fun x ->
      bind (check_access [x]) (fun () ->
	bind (validate_aux f1) (fun f1 ->
	  bind (add_bound [x]) (fun () ->
	    return (`Context (`GRAPH,x,f1))))))
  | `Context (`SERVICE,x,f1) ->
    bind (resolve x) (fun x ->
      bind (check_access [x]) (fun () ->
	bind (check_bound [x]) (fun () ->
	  bind (validate_aux f1) (fun f1 ->
	    return (`Context (`SERVICE,x,f1))))))
  | `Aggreg (op,x,y,lz,f1) ->
    bind (check_query_mode "Aggregations are not allowed in updates") (fun () ->
      bind (resolve x) (fun x ->
	bind (resolve y) (fun y ->
	  bind (resolve_list lz) (fun lz ->
	    bind (check_access [x]) (fun () ->
		(* like s SELECT lz y WHERE f1 *)
	      bind get_bound (fun bound ->
		bind reset_bound (fun () -> (* because SPARQL subqueries are isolated *)
		  bind (local (add_access (y::lz)) (local (remove_access x) (validate_aux f1))) (fun f1 ->
		    bind (check_bound (y::lz)) (fun () ->
		      bind (remove_bound [y]) (fun () ->
			bind get_access (fun acc ->
			  bind get_bound (fun bound2 ->
			    let lz = VS.elements (VS.inter acc bound2) @ lz in
			    (* variables accessible outside Aggreg and bound must be projected as a dim *)
			    bind (add_bound (x :: VS.elements bound)) (fun () ->
			      return (`Aggreg (op,x,y,lz,f1)))))))))))))))
  | `Modif (op,lz,x,f1) ->
    bind (check_query_mode "Superlatives are not allowed in updates") (fun () ->
      bind (resolve_list lz) (fun lz ->
	bind (resolve x) (fun x ->
	  bind (validate_aux f1) (fun f1 ->
	    bind (check_bound (x::lz)) (fun () ->
	      return (`Modif (op,lz,x,f1)))))))
  | `Exists (xs,f1) ->
    bind ask (fun env ->
      let xs = List.filter (fun x -> not (env#is_access x)) xs in (* because of lz in Aggreg *)
      if xs = []
      then validate_aux f1
      else
	let vs_xs = VS.list xs in
	if not (VS.is_empty (VS.inter env#access vs_xs)) then failwith "A same variable is introduced twice: replace one by a reference"; (* TODO: check whether useful *)
	bind (local (add_access xs) (validate_aux f1)) (fun f1' ->
	  bind (remove_bound xs) (fun () ->
	    return (`Exists (xs,f1')))))
  | `Forall (`Exists (xs,f1), f2) ->
    bind ask (fun env ->
      let vs_xs = VS.list xs in
      if not (VS.is_empty (VS.inter env#access vs_xs)) then failwith "A same variable is introduced twice: replace one by a reference";
      bind get_bound (fun bound ->
	bind (local set_query_mode (local (add_access xs) (validate_aux f1))) (fun f1 ->
	  bind (local (add_access xs) (validate_aux f2)) (fun f2 ->
	    bind (set_bound bound) (fun () ->
	      return (`Forall (`Exists (xs,f1), f2)))))))
  | `Forall (f1,f2) ->
    bind get_bound (fun bound ->
      bind (local set_query_mode (validate_aux f1)) (fun f1 ->
	bind (validate_aux f2) (fun f2 ->
	  bind (set_bound bound) (fun () ->
	    return (`Forall (f1,f2))))))
  | `True ->
    return `True
  | `Not f1 ->
    bind get (fun state ->
      bind (validate_aux f1) (fun f1' ->
	bind (set state) (fun () ->
	  return (`Not f1'))))
  | `And lf ->
    bind (validate_and lf `True) (fun (lf0, and_lf1) ->
      assert (lf0 = []);
      return and_lf1)
  | `Or lf1 ->
    bind (validate_or lf1) (fun lf1 ->
      return (`Or lf1))
  | `Option f1 ->
    bind (validate_aux f1) (fun f1 ->
      return (`Option f1))  (* bound variables can be used in SELECT and are therefore kept *)
  | _ -> assert false
and validate_and lf0 and_lf1 =
  if lf0 = []
  then return (lf0, and_lf1)
  else
    bind (validate_find lf0 [] (Failure "Some variable is unbound")) (fun (lf0',f1) ->
(*      let rev_lf1' = if f1 = `True then rev_lf1 else f1::rev_lf1 in *)
      validate_and lf0' (bin_and_ and_lf1 f1))
and validate_or = function
  | [] -> assert false
  | [f1] ->
    bind (validate_aux f1) (fun f1 ->
      return [f1])
  | f1::lf1 ->
    bind (validate_aux f1) (fun f1 ->
      bind get_bound (fun bound1 ->
	bind (validate_or lf1) (fun lf1 ->
	  bind get_bound (fun bound2 ->
	    bind (set_bound (VS.inter bound1 bound2)) (fun () ->
	      return (f1::lf1))))))
and validate_find lf0 rev_lf0' exn =
  match lf0 with
    | [] -> error exn
    | f0::l ->
      trial
	(bind (validate_aux f0) (fun f1 ->
	  return ((List.rev rev_lf0' @ l), f1)))
	(fun exn -> validate_find l (f0::rev_lf0') exn)

(* pretty-printing for semantics *)

let rec print = ipp
    [ f -> print_aux of f; EOF ]
and print_aux = ipp
    [ `Select (xs,f) -> "(select "; LIST0 print_term SEP " " of xs; " "; print_aux of f; ")"
    | `Triple (s,p,o) -> "(triple "; LIST1 print_term SEP " " of [s;p;o]; ")"
    | `Unify (x,y) -> "(unify "; LIST1 print_term SEP " " of [x;y]; ")"
    | `Label (x,l) -> "(label "; print_term of x; " "; print_label of l; ")"
    | `Func (op,lx,y) -> "(func "; print_op of op; " "; LIST0 print_term SEP " " of lx; " "; print_term of y; ")"
    | `Pred (op,lx) -> "(pred "; print_op of op; " "; LIST0 print_term SEP " " of lx; ")"
    | `Proc1 (op,x,args) -> "(proc1 "; print_op of op; " "; print_term of x; " "; print_args of args; ")"
    | `Context (kind,x,f) -> "(context "; print_context_kind of kind; " "; print_term of x; " "; print_aux of f; ")"
    | `Aggreg (op,x,y,lz,f1) -> "(aggreg "; print_op of op; " "; LIST1 print_term SEP " " of x::y::lz; " "; print_aux of f1; ")"
    | `Modif (modif,lz,x,f1) -> "(modif "; print_modif of modif; " "; LIST0 print_term SEP " " of lz; " "; print_term of x; " "; print_aux of f1; ")"
    | `Exists (xs,f) -> "(exists "; LIST1 print_term SEP " " of xs; " "; print_aux of f; ")"
    | `Forall (f1,f2) -> "(forall "; print_aux of f1; " "; print_aux of f2; ")"
    | `True -> "true"
    | `Not f1 -> "(not "; print_aux of f1; ")"
    | `And lf1 -> "(and "; LIST0 print_aux SEP " " of lf1; ")"
    | `Or lf1 -> "(or "; LIST0 print_aux SEP " " of lf1; ")"
    | `Option f1 -> "(option "; print_aux of f1; ")"
    | _ -> "(? ...)" ]
and print_args = ipp
  [ args -> MANY print_arg of args ]
and print_arg = ipp
  [ prep, z -> 'prep; "="; print_term of z ]
and print_context_kind = ipp
    [ `GRAPH -> "graph"
    | `SERVICE -> "service" ]
and print_modif = ipp
  [ `Mod { order; offset; limit } -> "("; print_order of order; " "; print_int of offset; " "; print_int of limit; ")" ]
and print_order = ipp
  [ `DESC -> "desc"
  | `ASC -> "asc"
  | `NONE -> "none" ]
and print_op = ipp
    [ `Appl s -> 's
    | `Infix s -> 's
    | `Prefix s -> 's
    | `Id -> "id"
    | `Eq -> "="
    | `Geq -> ">="
    | `Leq -> "<="
    | `Gt -> ">"
    | `Lt -> "<"
    | `Return -> "return"
    | `Describe -> "describe"
    | `Load -> "load"
    | `Clear -> "clear"
    | `Drop -> "drop"
    | `Create -> "create"
    | `Add -> "add"
    | `Move -> "move"
    | `Copy -> "copy"
    | `Count -> "count" ]
and print_term = ipp
    [ Var s -> "?"; 's
    | Ref l -> print_label of l
    | Uri s -> 's
    | Literal s -> 's
    | GraphLiteral (lv,lt) -> "{ "; LIST0 print_var SEP " " of lv; " : "; MANY print_triple of lt; "}"
    | Cons (e,l) -> "["; print_term of e; "|"; print_term of l; "]" ]
and print_label = ipp
    [ UserVar v -> "??"; 'v
    | Noun s -> "this("; 's; ")" ]
and print_triple = ipp
    [ (s,p,o) -> print_term of s; " "; print_term of p; " "; print_term of o; " . " ]
and print_var = ipp [ v -> 'v ]
and print_int = ipp [ i -> '(string_of_int i) ]
