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

open Semantics

class pre_context =
  object (self)
    val sentence_start : Msg.Coord.t = (1,1)
    method set_sentence_start coord =
      {< sentence_start = coord >}
    method is_sentence_start coord = (coord = sentence_start)

    method private is_kwd_norm s =
      List.mem s
	[ "a"; "all"; "an"; "and"; "are"; "as"; "at";
	  "be"; "between"; "by";
	  "did"; "different"; "do"; "does";
	  "else"; "equal"; "each"; "every"; "exactly";
	  "first"; "for"; "from";
	  "greater"; "greatest";
	  "had"; "has"; "have"; "higher"; "highest"; "how";
	  "if"; "in"; "into"; "is";
	  "last"; "later"; "latest"; "least"; "less"; "lesser"; "lower"; "lowest";
	  "many"; "maybe"; "more"; "most"; "much";
	  "nil"; "no"; "not";
	  "of"; "or"; "other";
	  "per";
	  "same"; "second"; "share"; "shared"; "shares"; "some"; "such";
	  "than"; "that"; "the"; "then"; "there"; "third"; "to";
	  "unit"; "units";
	  "was"; "were"; "what"; "where"; "whether"; "which"; "with"; "without"; "who"; "whom"; "whose";
	]

    method is_kwd coord s =
      let s = if sentence_start = coord then String.uncapitalize s else s in
      self#is_kwd_norm s
  end
let set_sentence_start = dcg "set sentence start" [ @cursor; ?ctx; ctx' in "new ctx" [ctx#set_sentence_start cursor#coord]; !ctx' -> () ]
let is_sentence_start = dcg "is sentence start" [ @cursor; ?ctx; when "" ctx#is_sentence_start cursor#coord -> () ]

(* punctuations *)

let skip = Str.regexp ""

let ws = dcg "space" [ s = match "[ \t\r\n]+" as "space" -> s ]
let comma = dcg "comma" [ s = match "[ \t\r\n]*,[ \t\r\n]*" as "comma" -> s ]
let semicolon = dcg "semicolon" [ s = match "[ \t\r\n]*;[ \t\r\n]*" as "semicolon" -> s ]
let dot = dcg "dot" [ s = match "[ \t\r\n]*[.]" as "dot" -> s ]
let interro = dcg "question mark" [ s = match "[ \t\r\n]*[?]" as "question mark" -> s ]
let left = dcg "left bracket" [ s = match "([ \t\r\n]*" as "left bracket"-> s ]
let right = dcg "right bracket" [ s = match "[ \t\r\n]*)" as "right bracket" -> s ]
let left_square = dcg "left square bracket" [ s = match "\\[[ \t\r\n]*" as "left square bracket" -> s ]
let right_square = dcg "right square bracket" [ s = match "[ \t\r\n]*\\]" as "right square bracket" -> s ]
let left_curly = dcg "left curly bracket" [ s = match "{[ \t\r\n]*" as "left curly bracket" -> s ]
let right_curly = dcg "right curly bracket" [ s = match "[ \t\r\n]*}" as "right curly bracket" -> s ]
let left_quote = dcg "left quote" [ s = match "'[ \t\r\n]*" as "left quote"-> s ]
let right_quote = dcg "right quote" [ s = match "[ \t\r\n]*'" as "right quote" -> s ]
let bar = dcg "bar" [ s = match "[ \t\r\n]*|[ \t\r\n]*" as "bar" -> s ]

(* grammatical morphemes and words *)
let kwd s =
  Dcg.map
    (Dcg.alt
       (Matcher.look s)
       (Dcg.seq (Dcg.check "Capitalized words only at sentence start" (fun ctx cursor -> ctx#is_sentence_start cursor#coord))
	  (fun _ -> Matcher.look (String.capitalize s))))
    (fun (s,coord) -> String.uncapitalize s)

let rec kwds ls =
  match ls with
  | [] -> Dcg.fail
  | s::ls1 -> Dcg.alt (kwd s) (kwds ls1)

let a_an = dcg [ s = kwds ["a"; "an"] -> s ]
let a_the = dcg [ s = kwds ["a"; "an"; "the"] -> s ]
let does = dcg [ s = kwds ["does"; "did"; "do"] -> s ]
let be = dcg [ s = kwds ["is"; "are"; "was"; "were"; "be"] -> s ]
let have = dcg [ s = kwds ["has"; "have"; "had"] -> s ]
let share = dcg [ s = kwds ["shares"; "share"; "shared"] -> s ]
let thing = dcg [ s = kwds ["thing"; "things"] -> s ]
let exist = dcg [ s = kwds ["exists"; "exist"; "existed"] -> s ]
let belong = dcg [ s = kwds ["belongs"; "belong"; "belonged"] -> s ]
let relate = dcg [ s = kwds ["relates"; "relate"; "related"] -> s ]
let what = dcg [ s = kwds ["what"; "who"; "whom"] -> s ]

(* words *)
let re_reluri = "<[^<>\"{}|^`\\\x00-\x20]*>"
let re_prefix = "[A-Za-z]\\([A-Za-z_0-9.-]*[A-Za-z_0-9-]\\)?"
let re_ns = "\\(" ^ re_prefix ^ "\\)?:"
let re_local = "[A-Za-z_:0-9]\\([A-Za-z_0-9-.:]*[A-Za-z_0-9-:]\\)?"
let re_qname = re_ns ^ re_local
let re_word_aux = "[a-zA-Z_0-9.']*[a-zA-Z_0-9]"
let re_word = "[a-zA-Z]" ^ re_word_aux
let re_word_lowercase = "[a-z]" ^ re_word_aux
let re_word_uppercase = "[A-Z]" ^ re_word_aux

let parse_uri re_word = dcg "uri"
  [ rel = match re_reluri as "relative URI" -> rel
  | ns = match re_ns as "prefix";
    ( "<"; local = match re_local as "quoted local name"; ">" -> ns^local
    | word = match re_word as "qualifed word" -> ns^word )
  | @cursor; ?ctx;
    word = match re_word as "bare word";
    when '("reserved keyword: " ^ word) not (ctx#is_kwd cursor#coord word) -> ":" ^ word ]

let parse_nat = dcg "nat" [ s = match "[0-9]+" as "natural number" -> int_of_string s ]
let parse_ordinal = dcg "ordinal"
    [ _ = kwd "first" -> 1
    | _ = kwd "second" -> 2
    | _ = kwd "third" -> 3
    | n = parse_nat; _ = match "\\(st\\|nd\\|rd\\|th\\)" as "th" -> n ]
let parse_literal_nat = dcg [ n = parse_nat -> Literal (string_of_int n) ]
let parse_string = dcg
    [ s = match "\"\\([^\"\\\n\r]\\|[\\][tbnrf\"]\\)*\"" as "string" -> s
    | s = match "\"\"\"\\(\\(\"\\|\"\"\\)?\\([^\"\\]\\|[\\][tbnrf\"]\\)\\)*\"\"\"" as "long string" -> s ]
let re_date = "[0-9][0-9][0-9][0-9]-\\(0[1-9]\\|1[0-2]\\)-\\(0[1-9]\\|1[0-9]\\|2[0-9]\\|3[0-1]\\)"
let re_time = "\\([0-1][0-9]\\|2[0-3]\\):[0-5][0-9]:[0-5][0-9]\\(\\.[0-9]+\\)?"
let re_dateTime = re_date ^ "T" ^ re_time
let parse_literal_str = dcg "literal_str"
    [ _ = kwd "true" -> "true"
    | _ = kwd "false" -> "false"
    | s = match "[+-]?[0-9]*\\.[0-9]+" as "decimal" -> "\"" ^ s ^ "\"^^xsd:decimal"
    | s = match "[+-]?\\([0-9]+\\(\\.[0-9]*\\)?\\|\\.[0-9]+\\)[eE][+-]?[0-9]+" as "double" -> "\"" ^ s ^ "\"^^xsd:double"
    | s = match "[+-]?[0-9]+" as "integer" -> s
    | s = match re_dateTime as "dateTime" -> "\"" ^ s ^ "\"^^xsd:dateTime" 
    | s = match re_date as "date" -> "\"" ^ s ^ "\"^^xsd:date"
    | s = match re_time as "time" -> "\"" ^ s ^ "\"^^xsd:time"
    | s = parse_string;
      ( "@"; lang = match "[-a-zA-Z0-9]+" as "language tag" -> s ^ "@" ^ lang
      | "^^"; uri = parse_uri re_word -> s ^ "^^" ^ uri
      |  -> s )
    | _ = kwd "the"; _ = ws; uri = parse_uri re_word; _ = ws; s = parse_string -> s ^ "^^" ^ uri ]
let parse_literal = dcg "literal" [ s = parse_literal_str -> Literal s ]

let parse_pattern = dcg "pattern"
    [ "'"; re = match "[^\n']+" as "pattern"; "'";
      lre in "invalid pattern" [Str.split (Str.regexp "[ \t]+") re]; when "empty pattern" lre <> [] -> matches lre ]

(* Lexicon *)

let rec parse_e_default = dcg
  [ "the default graph" -> Uri "DEFAULT"
  | "all named graphs" -> Uri "NAMED"
  | "all graphs" -> Uri "ALL"
  | _ = kwd "the"; _ = ws; _ = kwds ["resource"; "class"; "property"]; _ = ws; uri = parse_uri re_local -> Uri uri
  | uri = parse_uri re_word_uppercase -> Uri uri ]

let rec parse_p1_default = dcg
    [ uri = parse_uri re_word -> a (Uri uri) ]

let rec parse_p2_default = dcg
    [ uri = parse_uri re_word_lowercase; suf = parse_p2_suffix_opt -> rel (Uri (suf uri)) ]
and parse_p2_suffix_opt = dcg
    [ s = match "[?+*]" as "property suffix" -> (fun uri -> uri ^ s)
    | s = match "{[0-9]+\\(,\\([0-9]+\\)?\\)?}" as "property suffix" -> (fun uri -> uri ^ s)
    | s = match "{,[0-9]+}" as "property suffix" -> (fun uri -> uri ^ s)
    |  -> (fun uri -> uri) ]

class ['s1,'p1,'p2,'p2_measure,'str] context =
object (self)
  inherit pre_context as super

  method parse_e_np : 's1 = dcg
    [ x = parse_e_default -> x ]

  method parse_p1_noun : 'p1 = dcg
    [ _ = kwds ["thing"; "things"] -> bool1#true_
    | p1 = parse_p1_default; _ = match "\\(-e?s\\)?" -> p1 ]
  method parse_p1_adj : 'p1 = dcg
    [ _ = kwd "belonging" -> a (Uri pseudo_p1_belongs) ]
  method parse_p1_verb : 'p1 = dcg
    [ _ = kwds ["exist"; "exists"] -> bool1#true_
    | _ = kwds ["belong"; "belongs"] -> a (Uri pseudo_p1_belongs) ]
  (*    | p1 = parse_p1_default -> p1 ] *)
  method parse_p1_imp : 'p1 = dcg
    [ _ = kwd "return" -> proc1 proc1_return
    | _ = kwd "list" -> proc1 proc1_return
    | _ = kwd "give"; _ = ws; _ = kwd "me" -> proc1 proc1_return ]

  method parse_p2_noun : 'p2 = dcg
    [ _ = kwd "number"; _ = ws; _ = kwd "of"; _ = ws; p2 = self#parse_p2_count_noun -> p2
    | p2 = parse_p2_default; _ = match "\\(-e?s\\)?" -> p2 ]
  method parse_p2_count_noun : 'p2 = Dcg.fail
  method parse_p2_adj : 'p2 = dcg
    [ _ = kwd "relating" -> rel (Uri pseudo_p2_relates)
    | p2 = parse_p2_default;
      ( "-ing" -> p2
      | "-ed"; _ = ws; _ = kwd "by" -> (fun x y -> p2 y x) ) ] 
  method parse_p2_adj_measure : 'p2_measure = Dcg.fail
  method parse_p2_adj_comparative : 'p2_measure = Dcg.fail
  method parse_p2_adj_superlative : 'p2_measure = Dcg.fail
  method parse_p2_verb : 'p2 = dcg
    [ _ = kwds ["relate"; "relates"] -> rel (Uri pseudo_p2_relates)
    | _ = be; "-"; p2 = parse_p2_default -> p2
    | p2 = parse_p2_default; _ = match "\\(-e?[sd]\\)?" -> p2 ]

  method parse_marker : 'str = dcg
    [ _ = kwd "to" -> "to"
    | _ = kwd "into" -> "into"
    | _ = kwd "at" -> "at" ]

  method is_kwd_norm s =
    super#is_kwd_norm s ||
    List.mem s
      [ "belong"; "belonged"; "belongs";
	"class";
	"exist"; "existed"; "exists";
	"give";
	"list";
	"me";
	"property";
	"relate"; "related"; "relates"; "resource"; "return";
	"thing"; "things";
      ]
end

let parse_user_var = dcg "var"
  [ "?"; s = match "[a-zA-Z0-9]+" as "long user variable" -> UserVar s
  | s = match "[A-Z][0-9]*" as "short user variable" -> UserVar s ]
(*
let parse_noun_ref = dcg "noun ref"
  [ uri = parse_uri -> Noun uri ]
*)
let parse_ref = dcg "ref"
  [ l = parse_user_var -> Ref l ]
(*  | _ = kwds ["this"; "these"]; _ = ws; l = parse_noun_ref -> Ref l ] *)

(* Boolean closure *)

let rec parse_bool bool parse_atom = dcg
    [ la = LIST1 parse_and bool parse_atom SEP [ _ = ws; _ = kwd "or"; _ = ws -> () ] ->
        match la with [a] -> a | _ -> bool#or_ la ]
and parse_and bool parse_atom = dcg
    [ la = LIST1 parse_maybe bool parse_atom SEP [ _ = ws; _ = kwd "and"; _ = ws -> () ] ->
        match la with [a] -> a | _ -> bool#and_ la ]
and parse_maybe bool parse_atom = dcg
    [ _ = kwd "maybe"; _ = ws; a1 = parse_not bool parse_atom -> bool#maybe_ a1
    | _ = kwd "if"; _ = ws; _ = kwd "defined"; _ = comma; a1 = parse_not bool parse_atom -> bool#maybe_ a1
    | a1 = parse_not bool parse_atom -> a1 ]
and parse_not bool parse_atom = dcg
    [ _ = kwd "not"; _ = ws; a = parse_atom -> bool#not_ a
    | _ = left; a = parse_bool bool parse_atom; _ = right -> a
    | a = parse_atom -> a ]

(* Expressions *)

let rec parse_expr bool parse_atom = dcg
    [ e = parse_add bool parse_atom -> e ]
and parse_add bool parse_atom = dcg
    [ e1 = parse_mult bool parse_atom; e = parse_add_aux bool parse_atom e1 -> e ]
and parse_add_aux bool parse_atom e1 = dcg
    [ op = parse_addop; e2 = parse_mult bool parse_atom;
      e = parse_add_aux bool parse_atom
	(fun k -> e1 (fun x1 -> e2 (fun x2 -> bool#the (bool#func op [x1; x2]) k)))
	-> e
    |  -> e1 ]
and parse_mult bool parse_atom = dcg
    [ e1 = parse_unary bool parse_atom; e = parse_mult_aux bool parse_atom e1 -> e ]
and parse_mult_aux bool parse_atom e1 = dcg
    [ op = parse_mulop; e2 = parse_unary bool parse_atom;
      e = parse_mult_aux bool parse_atom
	(fun k -> e1 (fun x1 -> e2 (fun x2 -> bool#the (bool#func op [x1; x2]) k)))
	-> e
    |  -> e1 ]
and parse_unary bool parse_atom = dcg
    [ op = parse_unop; e1 = parse_primary bool parse_atom ->
        (fun k -> e1 (fun x1 -> bool#the (bool#func op [x1]) k))
    | e1 = parse_primary bool parse_atom -> e1 ]
and parse_primary bool parse_atom = dcg
    [ _ = left; e = parse_add bool parse_atom; _ = right -> e
    | lit = parse_literal -> (fun k -> k lit)
    | l = parse_user_var; _ = match "[ \t\r\n]*=[ \t\r\n]*" as "="; e = parse_add bool parse_atom ->
        (fun k -> e (fun x1 -> bool#and_ [bool#label l x1; k x1]))
(*      |  -> (fun k -> k (Ref l)) ) *) (* redundant *)
    | op = parse_nulop -> (fun k -> bool#the (bool#func op []) k)
    | op = parse_func; _ = left; f = parse_args bool parse_atom; _ = right -> f op
    | e = parse_atom -> e ]
and parse_args bool parse_atom = dcg
    [ e1 = parse_add bool parse_atom; f = parse_args_aux bool parse_atom ->
        (fun op k -> e1 (fun x1 -> f op [x1] k))
    |  -> (fun op k -> bool#the (bool#func op []) k) ]
and parse_args_aux bool parse_atom = dcg
    [ _ = comma; ei = parse_add bool parse_atom; f = parse_args_aux bool parse_atom ->
        (fun op lx k -> ei (fun xi -> f op (lx@[xi]) k))
    |  -> (fun op lx k -> bool#the (bool#func op lx) k) ]
and parse_addop = dcg [ ?ctx; op = ctx#parse_addop -> op ]
and parse_mulop = dcg [ ?ctx; op = ctx#parse_mulop -> op ]
and parse_unop = dcg [ ?ctx; op = ctx#parse_unop -> op ]
and parse_nulop = dcg [ ?ctx; op = ctx#parse_nulop -> op ]
and parse_func = dcg [ ?ctx; op = ctx#parse_func -> op ]

(* Comparisons *)

let parse_comp_det parse_x = dcg
  [ x = parse_x -> pred2_eq, x
  | _ = kwd "exactly"; _ = ws; x = parse_x -> pred2_eq, x
  | _ = kwd "at"; _ = ws;
    ( _ = kwd "least"; _ = ws; x = parse_x -> pred2_geq, x
    | _ = kwd "most"; _ = ws; x = parse_x -> pred2_leq, x )
  | _ = kwd "more"; _ = ws; _ = kwd "than"; _ = ws; x = parse_x -> pred2_gt, x
  | _ = kwd "less"; _ = ws; _ = kwd "than"; _ = ws; x = parse_x -> pred2_lt, x ]

let parse_comp_between parse_x = dcg
  [ _ = kwd "between"; _ = ws; x1 = parse_x; _ = ws; _ = kwd "and"; _ = ws; x2 = parse_x -> x1, x2 ]

let parse_comp_np parse_x parse_y = dcg
  [ _ = kwd "more"; _ = ws; x = parse_x; _ = ws; _ = kwd "than"; _ = ws; y = parse_y -> pred2_gt, x, y
  | _ = kwd "less"; _ = ws; x = parse_x; _ = ws; _ = kwd "than"; _ = ws; y = parse_y -> pred2_lt, x, y
  | _ = kwd "as"; _ = ws; _ = kwd "many"; _ = ws; x = parse_x; _ = ws; _ = kwd "as"; _ = ws; y = parse_y -> pred2_eq, x, y ]

let parse_comp_p2_aux parse_x_ws parse_y = dcg
  [ _ = kwd "same"; _ = ws; x = parse_x_ws; _ = kwd "as"; _ = ws; y = parse_y -> pred2_eq, x, y
  | _ = kwd "equal"; _ = ws; x = parse_x_ws; _ = kwd "to"; _ = ws; y = parse_y -> pred2_eq, x, y
  | _ = kwd "other"; _ = ws; x = parse_x_ws; _ = kwd "than"; _ = ws; y = parse_y -> pred2_neq, x, y
  | _ = kwd "different"; _ = ws; x = parse_x_ws; _ = kwd "from"; _ = ws; y = parse_y -> pred2_neq, x, y
  | _ = kwds ["greater"; "higher"; "later"]; _ = ws;
    ( _ = kwd "or"; _ = ws; _ = kwd "equal"; _ = ws; x = parse_x_ws; _ = kwd "to"; _ = ws; y = parse_y -> pred2_geq, x, y
    | x = parse_x_ws; _ = kwd "than"; _ = ws; y = parse_y -> pred2_gt, x, y )
  | _ = kwds ["lesser"; "lower"; "earlier"]; _ = ws;
    ( _ = kwd "or"; _ = ws; _ = kwd "equal"; _ = ws; x = parse_x_ws; _ = kwd "to"; _ = ws; y = parse_y -> pred2_leq, x, y
    | x = parse_x_ws; _ = kwd "than"; _ = ws; y = parse_y -> pred2_lt, x, y ) ]
let parse_comp_p2_binary parse_x parse_y = dcg
  [ cmp,x,y = parse_comp_p2_aux (dcg [ x = parse_x; _ = ws -> x ]) parse_y -> cmp, x, y ]
let parse_comp_p2_unary parse_y = dcg
  [ cmp, _, y = parse_comp_p2_aux (dcg [ -> () ]) parse_y -> cmp, y ]


let kcomp1 comp1 d = exists (fun n -> bool0#and_ [d n; comp1 n])
let kcomp2 comp2 d1 d2 = exists (fun n1 -> exists (fun n2 -> bool0#and_ [d1 n1; d2 n2; comp2 n1 n2]))

(* syntactical constructs *)
let rec parse = dcg
    [ _ = OPT ws ELSE ""; f = parse_text; _ = OPT ws ELSE ""; EOF -> f ]

and parse_text = dcg
    [ lf = LIST1 parse_s SEP ws -> and_ lf ]

and parse_s = dcg
    [ _ = set_sentence_start; s = parse_s_whether;
      ( _ = dot -> tell s
      | _ = interro -> tell (whether s) ) ]
and parse_s_whether = dcg
    [ _ = kwd "whether"; _ = ws; s = parse_s_for -> whether s
    | s = parse_s_for -> s ]
and parse_s_for = dcg
    [ _ = kwd "if"; _ = ws; s1 = parse_s_for; _ = [ _ = comma -> () | _ = ws; _ = kwd "then"; _ = ws -> () ];
      s2 = parse_s_for;
      ( _ = ws; _ = kwd "else"; _ = ws; s3 = parse_s_for -> ifthenelse s1 s2 s3
      |  -> ifthen s1 s2 )
    | _ = kwd "for"; _ = ws; np = parse_np; _ = comma; s = parse_s_for -> np (fun x -> s)
    | _ = kwd "there"; _ = ws; _ = be; _ = ws; np = parse_np_gen parse_det_unary -> np (fun x -> bool0#true_)
    | s = parse_s_where -> s ]
and parse_s_where = dcg
    [ s1 = parse_s_pp;
      ( _ = ws; _ = kwd "where"; _ = ws; s2 = parse_s_for -> where s1 s2
      |  -> s1 ) ]
and parse_s_pp = dcg
    [ pp = parse_pp; _ = ws; s = parse_s_pp -> pp s
    | s = parse_s_bool -> s ]
and parse_s_bool = dcg
    [ s = parse_bool bool0 parse_s_atom -> s ]
and parse_s_atom = dcg
(*
    [ _ = what; _ = ws; _ = be; _ = ws; d = parse_npq_gen ["the"] ->
        which x bool1#true_ d (* redundant: to avoid use of 'unify' in frequent cases *)
*)
    [ _ = kwd "how"; _ = ws; pol, p2 = parse_p2_adj_measure; _ = ws; _ = be; _ = ws; np = parse_np ->
        np (fun x -> which bool1#true_ (p2 x))
    | _ = does; _ = ws; np = parse_np; _ = ws;
      ( vp = parse_vp_atom -> whether (np vp)
      | _ = kwd "have"; _ = ws; vp = parse_vp_have -> whether (np vp) )
    | _ = be; _ = ws;
      ( np = parse_np; _ = ws; vp = parse_vp_be -> whether (np vp)
      | _ = kwd "there"; _ = ws; np = parse_np_gen parse_det_unary -> whether (np bool1#true_) )
    | p1 = parse_p1_imp_atom; _ = ws; op = parse_op -> op p1
    | np = parse_np; _ = ws; 
	( _ = does; _ = ws; np1 = parse_np; _ = ws; p2 = parse_p2_verb; cp = parse_cp -> np (fun y -> np1 (fun x -> cp (p2 x y)))
        | _ = be; _ = ws; np1 = parse_np; _ = ws;
	  ( _ = a_the; _ = ws; m1 = parse_modif_opt; adj_opt = parse_p1_adj_opt; p2 = parse_p2_noun; _ = ws; _ = kwd "of" ->
	      np (fun x -> np1 (bool1#and_ [m1; adj_opt (p2 x)]))
	  | p2 = parse_p2_adj; cp = parse_cp -> np (fun y -> np1 (fun x -> cp (p2 x y))) )
        | vp = parse_vp -> np vp )
    | _ = kwd "which"; _ = ws; p2 = parse_ng2; rel_opt = parse_rel_opt; _ = ws;
      _ = does; _ = ws; np = parse_np; _ = ws; _ = kwd "have" ->
	np (fun x -> which (rel_opt bool1#true_) (p2 x))
    | np2 = parse_np2; _ = ws; _ = does; _ = ws; np = parse_np; _ = ws; _ = kwd "have"; rel_opt = parse_rel_opt ->
	np (fun x -> np2 x (rel_opt bool1#true_)) ]

and parse_np_gen parse_det = dcg
    [ lnp = LIST1 parse_np_gen_bool parse_det SEP comma -> bool1#and_ lnp ]
and parse_np_gen_bool parse_det = dcg
    [ np = parse_bool bool1 (parse_np_gen_expr parse_det) -> np ]
and parse_np_gen_expr parse_det = dcg
    [ e1 = parse_expr bool1
	(dcg [ np = parse_np_gen_atom parse_det -> (fun k1 d -> np (fun x -> k1 x d)) ]) ->
	  e1 (fun x1 d -> d x1) ]
and parse_np_gen_atom parse_det = dcg
    [ t = parse_term -> (fun d -> d t)
    | np = parse_np_gen_term (parse_np_gen_bool parse_det) -> np
    | np2 = parse_np2_gen parse_det; _ = ws; _ = kwd "of"; _ = ws; np = parse_np ->
        (fun d -> np (fun x -> np2 x d))
    | det = parse_det; _ = ws; p1 = parse_ng1 ->
        (fun d -> det (close_modif (init p1)) d)
    | detn = parse_det_numeric; _ = ws; p1c = parse_ng1_count ->
        (fun d -> detn pol_positive (p1c d))
    | op, p1c1, p1c2 = parse_comp_np parse_ng1_count parse_ng1_count ->
        (fun d -> kcomp2 (pred2 op) (p1c1 d) (p1c2 d))
    | d1 = parse_npq_gen ["which"] -> (fun d -> which d1 d)
    | _ = what -> (* = which thing *)
	(fun d -> which bool1#true_ d)
    | _ = kwd "whose"; _ = ws; p2 = parse_ng2 -> (* = the NG2 of what *)
	(fun d ->
	  which bool1#true_ (fun x ->
	    exists (bool1#and_ [init (p2 x); d]))) ]

and parse_np2_gen parse_det = dcg
    [ np2 = parse_bool bool2 (parse_np2_gen_expr parse_det) -> np2 ]
and parse_np2_gen_expr parse_det = dcg
    [ e1 = parse_expr bool2
	(dcg [ np2 = parse_np2_gen_atom parse_det ->
	  (fun k1 x d -> np2 x (fun y -> k1 y x d)) ]) ->
	    e1 (fun x1 x d -> d x1) ]
and parse_np2_gen_atom parse_det = dcg
    [ detn = parse_det_numeric; _ = ws; p2c = parse_ng2_count ->
        (fun x d -> detn pol_positive (p2c x d))
    | op, p2c1, p2c2 = parse_comp_np parse_ng2_count parse_ng2_count ->
        (fun x d -> kcomp2 (pred2 op) (p2c1 x d) (p2c2 x d))
    | op, p2c, np = parse_comp_np parse_ng2_count parse_np ->
        (fun x1 d -> np (fun x2 -> kcomp2 (pred2 op) (p2c x1 d) (p2c x2 d)))
    | det = parse_det; _ = ws; p2 = parse_ng2 ->
        (fun x d -> det (init (p2 x)) d) (* close_modif ? *)
    | p2 = parse_npq2_gen ["which"] ->
        (fun x d -> which d (init (p2 x))) ]

and parse_npq_gen kwds_det = dcg
    [ npq = parse_npq_gen_atom kwds_det -> npq
    | e1 = parse_expr bool0
	(dcg [ d = parse_npq_gen_atom kwds_det ->
	  (fun k0 -> exists (bool1#and_ [d; k0])) ]) ->
        (fun x -> e1 (fun x1 -> unify x1 x)) ]
and parse_npq_gen_atom kwds_det = dcg
    [ t = parse_term -> (fun x -> unify t x)
    | np = parse_np_gen_term
	(dcg [ d1 = parse_npq_gen kwds_det -> (fun d -> exists (bool1#and_ [d1; d])) ]) ->
        (fun x -> np (fun x1 -> unify x1 x))
    | p2 = parse_npq2_gen_atom kwds_det; _ = ws; _ = kwd "of"; _ = ws; np = parse_np ->
        (fun y -> np (fun x -> p2 x y))
    | _ = kwds kwds_det; _ = ws; p1 = parse_ng1 -> p1 ]

and parse_npq2_gen kwds_det = dcg
    [ npq2 = parse_npq2_gen_atom kwds_det -> npq2
    | e1 = parse_expr bool1
	(dcg [ p2 = parse_npq2_gen_atom kwds_det ->
	  (fun k1 x -> exists (fun y -> bool0#and_ [p2 x y; k1 y x])) ]) ->
	(fun x y -> e1 (fun y1 x -> unify y1 y) x) ]
and parse_npq2_gen_atom kwds_det = dcg
    [ _ = kwds kwds_det; _ = ws; p2 = parse_ng2 -> p2 ]

and parse_np_gen_term parse_np = dcg "np_term"
    [ _ = kwd "that"; _ = ws; s = parse_s_pp -> (fun d -> graph_literal s d)
    | "_" (* joker *) -> (fun d -> exists d)
    | _ = left_square; npl = parse_np_gen_list parse_np; _ = right_square -> npl
    | b = parse_b -> (fun d -> exists (bool1#and_ [b; d])) (* Turtle blank node: for Turtle compatibility *)
    | patt = parse_pattern -> (fun d -> exists (bool1#and_ [d; patt])) ]
and parse_np_gen_list parse_np = dcg "np_list"
    [ np = parse_np;
      ( _ = comma; npl = parse_np_gen_list parse_np ->
	(fun dl -> np (fun e -> npl (fun l -> dl (cons e l))))
      | _ = bar; npl = parse_np ->
	(fun dl -> np (fun e -> npl (fun l -> dl (cons e l))))
      |   ->
	(fun dl -> np (fun x -> dl (cons x nil))) )
    | "...";
      ( _ = comma; npl = parse_np_gen_list parse_np ->
	(fun dl -> npl (fun l -> exists (fun x -> bool0#and_ [triple x (Uri p2_sublist) l; dl x])))
      | _ = bar; npl = parse_np ->
	(fun dl -> npl (fun l -> exists (fun x -> bool0#and_ [triple x (Uri p2_sublist) l; dl x])))
      |  ->
        (fun dl -> exists dl) ) ]

and parse_term = dcg
    [ x = parse_ref -> x
    | lit = parse_literal -> lit
    | _ = left_square; _ = right_square -> nil
    | x = parse_e_np -> x ]

and parse_b = dcg
    [ _ = left_square; vp = OPT parse_vp ELSE bool1#true_; _ = right_square -> init vp ]

and parse_det_numeric = dcg
    [ op, n = parse_comp_det parse_literal ->
        (fun pol d -> exists (fun x -> bool0#and_ [d x; pred2 (pol op) x n]))
    | n1, n2 = parse_comp_between parse_literal ->
        (fun pol d -> exists (fun x -> bool0#and_ [d x; pred2 pred2_geq x n1; pred2 pred2_leq x n2]))
    | _ = kwd "how"; _ = ws; _ = kwds ["many"; "much"] ->
	(fun pol d -> which bool1#true_ d)
    | _ = kwd "the"; _ = ws; op_modif = parse_offset_limit_opt;
	( _ = kwd "most" ->
	  (fun pol d -> exists (fun x -> bool0#and_ [d x; open_modif (pol (`Mod { op_modif with order=`DESC })) [] x bool0#true_]))
        | _ = kwd "least" ->
	  (fun pol d -> exists (fun x -> bool0#and_ [d x; open_modif (pol (`Mod { op_modif with order=`ASC })) [] x bool0#true_])) ) ]

and parse_det_unary = dcg
    [ det1 = parse_det_unary_aux -> (fun d1 d2 -> det1 (bool1#and_ [d1; d2])) ]
and parse_det_unary_aux = dcg
    [ _ = kwd "some" -> (fun d -> exists d)
    | _ = kwd "no" -> (fun d -> bool0#not_ (exists d))
    | detn = parse_det_numeric -> (fun d -> detn pol_positive (a_number d))
    | _ = kwds ["a"; "an"];
      ( _ = ws; m1 = parse_modif_opt; op = parse_aggreg_adj; app_opt = parse_app_opt; rel_opt = parse_rel_opt ->
	(fun d -> exists (bool1#and_ [aggreg op 0 (fun y lz -> d y); m1; app_opt (rel_opt bool1#true_)]))
      |  -> (fun d -> exists d) ) ]

and parse_det = dcg
    [ det = parse_det_unary -> det
    | _ = kwds ["every"; "all"] -> (fun d1 d2 -> forall d1 d2)
    | _ = kwd "the" -> (fun d1 d2 -> the d1 d2) ]

and parse_np = dcg
    [ np = parse_np_gen parse_det -> np ]

and parse_np2 = dcg
    [ np2 = parse_np2_gen parse_det -> np2 ]

and parse_ng1 = dcg
    [ m1 = parse_modif_opt; p1 = parse_ng1_atom -> bool1#and_ [m1; p1] ]
and parse_ng1_atom = dcg
    [ adj_opt = parse_p1_adj_opt; app = parse_app; rel_opt = parse_rel_opt -> app (rel_opt (adj_opt bool1#true_))
    | adj_opt = parse_p1_adj_opt; p1 = parse_p1_noun; app_opt = parse_app_opt; rel_opt = parse_rel_opt ->
        app_opt (rel_opt (adj_opt p1))
    | op = parse_aggreg_noun; app_opt = parse_app_opt; n,g = parse_g'_noun -> app_opt (aggreg op n g)
    | op = parse_aggreg_adj; app_opt = parse_app_opt; n,g = parse_g'_adj -> app_opt (aggreg op n g) ]

and parse_ng1_count = dcg
    [ d1 = parse_ng1 -> (fun d -> a_number (bool1#and_ [d1; d])) ]

and parse_ng2 = dcg
    [ m1 = parse_modif_opt; p2 = parse_ng2_atom -> (fun x y -> bool0#and_ [m1 y; p2 x y]) ]
and parse_ng2_atom = dcg
    [ adj_opt = parse_p1_adj_opt; p2 = parse_p2_noun; app_opt = parse_app_opt -> (fun x -> app_opt (adj_opt (p2 x))) ]
(* creates ambiguities, e.g. "the average size of the doctors" (of all doctors OR of each doctor) *)
(*
    | op = parse_aggreg_noun; app_opt = parse_app_opt; lz,lr,y,r = parse_g2'_noun -> (fun x -> app_opt (aggreg op lz lr y (r x)))
    | op = parse_aggreg_adj; app_opt = parse_app_opt; lz,lr,y,r = parse_g2'_adj -> (fun x -> app_opt (aggreg op lz lr y (r x))) ]
*)

and parse_ng2_count = dcg
    [ p2 = parse_p2_count_noun -> (fun x d n ->
      bool0#if_true (d (Var "_"))
	(p2 x n)
	(bool0#fail "The individuals of 'numberOf' properties cannot be qualified"))
    | p2 = parse_ng2 -> (fun x d -> a_number (bool1#and_ [p2 x; d])) ]

and parse_app_opt = dcg
  [ _ = ws; app = parse_app -> app
  |  -> bool1#id ]
and parse_app = dcg
  [ l = parse_user_var -> (fun d -> bool1#and_ [label l; d]) ]

and parse_rel_opt = dcg
    [ _ = ws; rel = parse_rel -> (fun d -> bool1#and_ [d; rel])
    |  -> bool1#id ]
and parse_rel = dcg
    [ rel = parse_bool bool1 parse_rel_atom -> rel ]
and parse_rel_atom = dcg
    [ p1 = parse_p1_adj; cp = parse_cp -> init (fun x -> cp (p1 x))
    | p2 = parse_p2_adj; _ = ws; op = parse_op -> init (fun x -> op (p2 x))
    | f1 = [ _ = kwd "with" -> bool1#id | _ = kwd "without" -> bool1#not_ ];
      _ = ws; np2 = parse_np2; rel_opt = parse_rel_opt ->
	init (f1 (fun x -> np2 x (rel_opt bool1#true_)))
    | _ = kwds ["that"; "which"; "who"]; _ = ws; vp = parse_vp -> init vp
    | _ = kwds ["that"; "which"; "whom"]; _ = ws; np = parse_np; _ = ws; p2 = parse_p2_verb; cp = parse_cp ->
	init (fun x -> np (fun y -> cp (p2 y x)))
    | _ = kwd "such"; _ = ws; _ = kwd "that"; _ = ws; s = parse_s_for -> init (fun x -> s)
    | np2 = parse_np2; _ = ws; _ = kwd "of"; _ = ws; _ = kwd "which"; _ = ws; vp = parse_vp ->
	init (fun x -> np2 x vp)
    | _ = kwd "whose"; _ = ws; p2 = parse_ng2; _ = ws;
      ( _ = be; f1 = parse_aux_not_opt; _ = ws; np = parse_np ->
        init (fun x -> np (fun y -> p2 x y))
      | vp = parse_vp ->
        init (fun x -> exists (bool1#and_ [p2 x; vp])) )
    | mk = parse_marker; _ = ws; _ = kwd "which"; _ = ws; prep = parse_prep mk; _ = ws; s = parse_s_for ->
	init (fun z -> prep z s)
    | cmp, op = parse_comp_p2_unary parse_op -> (fun x -> op (fun y -> pred2 cmp x y))
    | op1, op2 = parse_comp_between parse_op -> (fun x -> op1 (fun x1 -> op2 (fun x2 -> bool0#and_ [pred2 pred2_geq x x1; pred2 pred2_leq x x2]))) ]

and parse_vp = dcg
    [ lvp = LIST1 parse_vp_pp SEP semicolon -> bool1#and_ lvp ]
and parse_vp_pp = dcg
    [ pp = parse_pp; _ = ws; vp = parse_vp_pp -> (fun x -> pp (vp x))
    | vp = parse_vp_bool -> vp ]
and parse_vp_bool = dcg
  [ vp = parse_bool bool1 parse_vp_aux -> vp ]
and parse_vp_aux = dcg
    [ _ = does; f1 = parse_aux_not_opt; _ = ws; vp = parse_vp_atom -> f1 vp
    | _ = be; f1 = parse_aux_not_opt; _ = ws; vp = parse_vp_be -> f1 vp
    | _ = have; f1 = parse_aux_not_opt; _ = ws; vp = parse_vp_have -> f1 vp
    | vp = parse_vp_atom -> vp ]

and parse_aux_not_opt = dcg
    [ f1 = parse_aux_not -> f1
    |  -> bool1#id ]
and parse_aux_not = dcg
    [ "n't" -> bool1#not_
    | _ = ws; _ = kwd "not" -> bool1#not_ ]

and parse_vp_atom = dcg
    [ _ = share; _ = ws; vp = parse_vp_share -> vp
    | p1 = parse_p1_verb; cp = parse_cp -> (fun x -> cp (p1 x))
    | p2 = parse_p2_verb; _ = ws; op = parse_op -> (fun x -> op (p2 x)) ]

and parse_vp_be = dcg
    [ _ = kwd "there" -> bool1#true_
    | _ = a_an; _ = ws; m1 = parse_modif_opt; adj_opt = parse_p1_adj_opt; p1 = parse_p1_noun; rel_opt = parse_rel_opt -> (* TODO: include in NPQ *)
	bool1#and_ [m1; rel_opt (adj_opt p1)]
    | _ = kwd "the"; _ = ws; m1 = parse_modif -> m1
    | _ = a_the; _ = ws; m1 = parse_modif_opt; adj_opt = parse_p1_adj_opt; p2 = parse_p2_noun; _ = ws; _ = kwd "of"; _ = ws; np = parse_np; cp = parse_cp -> (* TODO: include in NPQ *)
	(fun y -> np (fun x -> cp (bool1#and_ [m1; adj_opt (p2 x)] y)))
    | rel = parse_rel -> rel
    | d = parse_npq_gen ["a"; "an"; "the"] -> d (* close_modif ? *)
    | _ = what -> (fun x -> which bool1#true_ (unify x))
    | _ = kwd "whose"; _ = ws; p2 = parse_ng2 -> (* = the NG2 of what *)
        (fun y -> which bool1#true_ (fun x -> p2 x y)) ]
(*    | np = parse_np -> (fun x -> np (fun y -> unify x y)) ] (* this last case is sometimes problematic *) *)

and parse_vp_have = dcg
    [ _ = kwd "which"; _ = ws; p2 = parse_ng2; rel_opt = parse_rel_opt -> (* = P2 which thing Rel? *)
	(fun x -> which (rel_opt bool1#true_) (p2 x))
    | np2 = parse_np2; rel_opt = parse_rel_opt ->
	(fun x -> np2 x (rel_opt bool1#true_))
    | p2 = parse_p2_noun; _ = ws; op = parse_op ->
	(fun x -> op (fun y -> p2 x y))
    | p2 = parse_npq2_gen ["a"; "an"; "the"]; rel_opt = parse_rel_opt -> (* TODO: redundant? *)
        (fun x -> exists (rel_opt (p2 x))) (* close_modif ? *)
    | _ = a_the; _ = ws;
      ( cmp, p21, p22 = parse_comp_p2_binary parse_p2_noun parse_p2_noun ->
          (fun x -> kcomp2 (pred2 cmp) (p21 x) (p22 x))
      | cmp, p2, np = parse_comp_p2_binary parse_p2_noun parse_np ->
	  (fun x1 -> np (fun x2 -> kcomp2 (pred2 cmp) (p2 x1) (p2 x2))) ) ]

and parse_vp_share = dcg
    [ det = parse_det; _ = ws; p2 = parse_ng2; _ = ws; _ = kwd "with"; _ = ws; np = parse_np ->
        (fun x1 -> det (p2 x1) (fun y -> np (fun x2 -> p2 x2 y))) (* close_modif ? *)
    | _ = kwd "with"; _ = ws; np = parse_np; _ = ws; det = parse_det; _ = ws; p2 = parse_ng2 ->
	(fun x1 -> np (fun x2 -> det (p2 x1) (fun y -> p2 x2 y))) ] (* close_modif ? *)
(* TODO: add (diff x1 x2) INTO np *)

and parse_op = dcg
    [ pp = parse_pp; _ = ws; op = parse_op -> (fun d -> pp (op d))
    | op = parse_op_bool -> op ]
and parse_op_bool = dcg
    [ op = parse_bool bool1 parse_op_atom -> op ]
and parse_op_atom = dcg
    [ np = parse_np; cp = parse_cp -> (fun d -> np (fun y -> cp (d y))) ]

and parse_cp = dcg
    [ cp = parse_bool bool1 parse_cp_atom -> cp ]
and parse_cp_atom = dcg
    [ _ = ws; pp = parse_pp; cp = parse_cp_atom -> (fun s -> pp (cp s))
    |  -> (fun s -> s) ]

and parse_pp = dcg
    [ pp = parse_bool bool1 parse_pp_atom -> pp ]
and parse_pp_atom = dcg
    [ mk = parse_marker; _ = ws;
      ( prep = parse_prep_opt mk; np = parse_np ->
	  (fun s -> np (fun z -> prep z s))
      | det = parse_det; _ = ws; prep = parse_prep mk; app_opt = parse_app_opt; rel_opt = parse_rel_opt ->
	  (fun s -> det (close_modif (app_opt (rel_opt bool1#true_))) (fun z -> prep z s))
      | _ = kwd "which"; _ = ws; prep = parse_prep mk; app_opt = parse_app_opt; rel_opt = parse_rel_opt -> (* = at Prep which thing Rel? *)
	  (fun s -> which (app_opt (rel_opt bool1#true_)) (fun z -> prep z s)) ) ]

and parse_prep_opt (marker : string) = dcg
    [ when "" marker = "to" -> arg pseudo_prep_to
    | when "" marker = "into" -> arg pseudo_prep_into
    | prep = parse_prep marker; _ = ws -> prep ]
and parse_prep (marker : string) = dcg
    [ op = parse_context marker -> context op
    | uri = parse_uri re_word; when "'at' expected before preposition" marker = "at" -> arg uri ]

and parse_g'_noun = dcg
    [ d = parse_g'_of; n, dims = parse_dims -> n, (fun y lz -> bool0#and_ [d y; dims y lz])
    | n, dims = parse_dims; d = parse_g'_of -> n, (fun y lz -> bool0#and_ [d y; dims y lz]) ]
and parse_g'_adj = dcg
    [ _ = ws; p1 = parse_ng1; n, dims = parse_dims -> n, (fun y lz -> bool0#and_ [p1 y; dims y lz])
    | _ = ws; p2 = parse_ng2;
      ( d = parse_g'_of; n, dims = parse_dims -> n, (fun y lz -> exists (fun x -> bool0#and_ [d x; p2 x y; dims x lz]))
      | n, dims = parse_dims; d = parse_g'_of -> n, (fun y lz -> exists (fun x -> bool0#and_ [d x; p2 x y; dims x lz])) ) ]
and parse_g'_of = dcg
    [ _ = ws; _ = kwd "of"; _ = ws; d1 = parse_npq_gen ["the"] -> d1 ]

(*
and parse_g2'_noun = dcg (* TODO: add parse_per *)
    [ _ = ws; _ = kwd "of"; _ = ws; p2 = parse_ng2; y = new_var -> [], [], y, (fun x y -> p2 x y) ]
and parse_g2'_adj = dcg
    [ _ = ws; p2 = parse_ng2; y = new_var -> [], [], y, (fun x y -> p2 x y) ]
*)

and parse_dims = dcg
    [ _ = ws; _ = kwd "per"; _ = ws; dim = parse_dims_atom; n, dims = parse_dims_rest ->
       n+1, (fun y -> function z::lz -> bool0#and_ [dim y z; dims y lz] | _ -> assert false)
    |  -> 0, (fun y lz -> bool0#true_) ]
and parse_dims_rest = dcg
  [ _ = ws; _ = kwd "and"; n, dims = parse_dims -> n, dims
  |  -> 0, (fun y lz -> bool0#true_) ]
and parse_dims_atom = dcg
    [ p2 = parse_ng2 -> (fun y z -> p2 y z)
    | d = parse_npq_gen ["the"] -> (fun y z -> d z) ]

and parse_e_np = dcg [ ?ctx; x = ctx#parse_e_np -> x ]

and parse_p1_noun = dcg
  [ p1 = parse_bool bool1 ctx#parse_p1_noun -> p1 ]

and parse_p1_adj_opt = dcg
    [ p1_adj = parse_p1_adj; _ = ws -> (fun p1 -> bool1#and_ [p1; p1_adj])
    |  -> (fun p1 -> p1) ]
and parse_p1_adj = dcg
  [ p1 = parse_bool bool1 parse_p1_adj_atom -> p1 ]
and parse_p1_adj_atom = dcg
  [ detn = parse_det_numeric; _ = ws; _ = OPT [ _ = kwds ["unit"; "units"]; _ = ws -> () ] ELSE (); pol, p2 = parse_p2_adj_measure ->
      (fun x -> detn pol (p2 x))
  | ?ctx; p1 = ctx#parse_p1_adj -> p1 ]

and parse_p1_verb = dcg
  [ p1 = parse_bool bool1 parse_p1_verb_atom -> p1 ]
and parse_p1_verb_atom = dcg [ ?ctx; p1 = ctx#parse_p1_verb -> p1 ]

and parse_p1_imp_atom = dcg [ ?ctx; p1 = ctx#parse_p1_imp -> p1 ]

and parse_p2_noun = dcg
  [ p2 = parse_bool bool2 ctx#parse_p2_noun -> p2 ]

and parse_p2_count_noun = dcg [ ?ctx; p2 = ctx#parse_p2_count_noun -> p2 ]

and parse_p2_verb = dcg
  [ p2 = parse_bool bool2 parse_p2_verb_atom -> p2 ]
and parse_p2_verb_atom = dcg [ ?ctx; p2 = ctx#parse_p2_verb -> p2 ]

and parse_p2_adj = dcg
  [ p2 = parse_bool bool2 parse_p2_adj_atom -> p2 ]
and parse_p2_adj_atom = dcg
  [ p2, comp = parse_p2_adj_comp ->
      (fun x x' -> kcomp2 comp (p2 x) (p2 x'))
  | ?ctx; p2 = ctx#parse_p2_adj -> p2 ]
and parse_p2_adj_comp = dcg
  [ pol, p2 = parse_p2_adj_comparative; _ = ws; _ = kwd "than" ->
      p2, pred2 (pol pred2_gt) (*if pol then pred2 pred2_gt else pred2 pred2_lt*)
  | op = [ _ = kwd "more" -> pred2_gt | _ = kwd "less" -> pred2_lt | _ = kwd "as" -> pred2_eq ];
    _ = ws; pol, p2 = parse_p2_adj_measure; _ = ws; _ = kwds ["than"; "as"] ->
      p2, pred2 (pol op) (*if pol then pred2 op else bool2#inverse (pred2 op)*) ]

and parse_p2_adj_measure = dcg [ ?ctx; pol_p2 = ctx#parse_p2_adj_measure -> pol_p2 ]
and parse_p2_adj_comparative = dcg [ ?ctx; pol_p2 = ctx#parse_p2_adj_comparative -> pol_p2 ]
and parse_p2_adj_superlative = dcg [ ?ctx; pol_p2 = ctx#parse_p2_adj_superlative -> pol_p2 ]

and parse_marker = dcg [ ?ctx; mk = ctx#parse_marker -> mk ]
and parse_context marker = dcg [ ?ctx; op = ctx#parse_context marker -> op ]

and parse_aggreg_noun = dcg [ ?ctx; op = ctx#parse_aggreg_noun -> op ]
and parse_aggreg_adj = dcg [ ?ctx; op = ctx#parse_aggreg_adj -> op ]

and parse_modif_opt = dcg
    [ m1 = parse_modif; _ = ws -> m1
    |  -> bool1#true_ ]
and parse_modif = dcg
  [ m1 = parse_modif_order_offset_limit -> m1 ]
and parse_modif_order_offset_limit = dcg
  [ "decreasing" -> (fun x -> open_modif (`Mod { modif_default with order=`DESC }) [] x bool0#true_)
  | "increasing" -> (fun x -> open_modif (`Mod { modif_default with order=`ASC }) [] x bool0#true_)
  | op_modif = parse_offset_limit;
    ( _ = ws; m1 = parse_order op_modif -> m1
    |  -> (fun x -> open_modif (`Mod op_modif) [] x bool0#true_) )
  | m1 = parse_order { modif_default with limit=1 } -> m1 ]
and parse_offset_limit_opt = dcg
  [ op_modif = parse_offset_limit; _ = ws -> op_modif
  |  -> { modif_default with limit=1 } ]
and parse_offset_limit = dcg
  [ limit = parse_nat -> { modif_default with limit=limit }
  | ord1 = parse_ordinal;
    ( _ = ws; _ = kwd "to"; _ = ws;
      ( ord2 = parse_ordinal when "invalid modifier range" ord2 > ord1 -> { modif_default with offset=ord1-1; limit=ord2-ord1+1 }
      | _ = kwd "last" -> { modif_default with offset=ord1-1 } )
    |  -> { modif_default with offset=ord1-1; limit=1 } ) ]
and parse_order op_modif = dcg
  [ pol, p2 = parse_p2_adj_superlative ->
      (fun x -> exists (fun y -> open_modif (pol (`Mod { op_modif with order=`DESC })) [x] y (p2 x y)))
  | _ = kwd "first" -> (fun x -> open_modif (`Mod op_modif) [] x bool0#true_)
  | _ = kwds ["greatest"; "highest"; "latest"] -> (fun x -> open_modif (`Mod { op_modif with order=`DESC }) [] x bool0#true_)
  | _ = kwds ["least"; "lowest"; "earliest"] -> (fun x -> open_modif (`Mod { op_modif with order=`ASC }) [] x bool0#true_) ]
