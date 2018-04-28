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

let ws = Syntax.ws
let kwd = Syntax.kwd
let kwds = Syntax.kwds

class ['s1,'p1,'p2,'p2_measure,'str,'p] context =
  object (self)
    inherit ['s1,'p1,'p2,'p2_measure,'str] Syntax.context as super

    method parse_p1_noun = dcg
      [ "URI" -> pred1 (`Appl "isURI")
      | "IRI" -> pred1 (`Appl "isIRI")
      | "blank"; _ = ws; "node" -> pred1 (`Appl "isBLANK")
      | "literal" -> pred1 (`Appl "isLITERAL")
      | "number" -> pred1 (`Appl "isNumeric")
      | p1 = super#parse_p1_noun -> p1 ]
    method parse_p1_adj = dcg
      [ "blank" -> pred1 (`Appl "isBLANK")
      | "numeric" -> pred1 (`Appl "isNumeric")
      | p1 = super#parse_p1_adj -> p1 ]
    method parse_p1_imp : 'p1 = dcg
        [ _ = kwd "describe" -> proc1 `Describe
	| _ = kwd "load" -> proc1 `Load
	| _ = kwd "clear" -> proc1 `Clear
	| _ = kwd "drop" -> proc1 `Drop
	| _ = kwd "create" -> proc1 `Create
	| _ = kwd "add" -> proc1 `Add
	| _ = kwd "move" -> proc1 `Move
	| _ = kwd "copy" -> proc1 `Copy
	| p1 = super#parse_p1_imp -> p1 ]

    method parse_p2_noun = dcg
      [ "prefix" -> pred2 (`Appl "strStarts")
      | "suffix" -> pred2 (`Appl "strEnds")
      | "substring" -> pred2 (`Appl "contains")
      | "pattern" -> pred2 (`Appl "REGEX")
      | _ = match "str\\(ings?\\)?" as "str(ing)" -> func1 (`Appl "str")
      | _ = match "lang\\(uages?\\)?" as "lang(uage)" -> func1 (`Appl "lang")
      | _ = match "datatypes?" as "datatype(s)" -> func1 (`Appl "datatype")
      | _ = match "lengths?" as "length(s)" -> func1 (`Appl "strlen")
      | _ = match "u\\(pper\\)?case" as "u(pper)case" -> func1 (`Appl "ucase")
      | _ = match "l\\(ower\\)?case" as "l(ower)case" -> func1 (`Appl "lcase")
      | _ = match "years?" as "year(s)" -> func1 (`Appl "year")
      | _ = match "months?" as "month(s)" -> func1 (`Appl "month")
      | _ = match "days?" as "day(s)" -> func1 (`Appl "day")
      | _ = match "hours" as "hours" -> func1 (`Appl "hours")
      | _ = match "minutes" as "minutes" -> func1 (`Appl "minutes")
      | _ = match "seconds" as "seconds" -> func1 (`Appl "seconds")
      | _ = match "timezones?" as "timezone(s)" -> func1 (`Appl "timezone" )
      | _ = match "tz" as "tz" -> func1 (`Appl "tz")
      | p2 = super#parse_p2_noun -> p2 ]
    method parse_p2_verb = dcg
      [ "=" -> pred2 `Eq
      | "!=" -> pred2 `Neq
      | ">" -> pred2 `Gt
      | "<" -> pred2 `Lt
      | ">=" -> pred2 `Geq
      | "<=" -> pred2 `Leq
      | _ = match "starts?[ \t\n\r]+with" as "start(s) with" -> pred2 (`Appl "strStarts")
      | _ = match "ends?[ \t\n\r]+with" as "end(s) with" -> pred2 (`Appl "strEnds")
      | _ = match "contains?" as "contain(s)" -> pred2 (`Appl "contains")
      | _ = match "match\\(es\\)?" as "match(es)" -> pred2 (`Appl "REGEX")
      | p2 = super#parse_p2_verb -> p2 ]
    method parse_p2_adj = dcg
      [ "starting"; _ = ws; "with" -> pred2 (`Appl "strStarts")
      | "ending"; _ = ws; "with" -> pred2 (`Appl "strEnds")
      | "containing" -> pred2 (`Appl "contains")
      | "matching" -> pred2 (`Appl "REGEX")
      | p2 = super#parse_p2_adj -> p2 ]

    method parse_addop : 'p = dcg
	[ _ = match "[ \t]+[+][ \t]+" as " + " -> `Infix "+"
	| _ = match "[ \t]+[-][ \t]+" as " - " -> `Infix "-" ]
    method parse_mulop : 'p = dcg
	[ _ = match "[ \t]+[*][ \t]+" as " * " -> `Infix "*"
	| _ = match "[ \t]+[/][ \t]+" as " / " -> `Infix "/" ]
    method parse_unop : 'p = dcg
	[ _ = match "+[ \t]*" as "+" -> `Prefix "+"
        | _ = match "-[ \t]*" as "-" -> `Prefix "-" ]
    method parse_nulop : 'p = dcg
        [ "now" -> `Appl "now"
	| "a"; _ = ws; "random"; _ = ws; "number" -> `Appl "RAND"
	| "a"; _ = ws; "new"; _ = ws; "node" -> `Appl "BNODE" ]
    method parse_func : 'p = dcg
        [ s = match "[A-Za-z_]+[0-9]*" as "func";
	    when "unknown function" List.mem (String.lowercase s)
	      [ "str"; "lang"; "datatype"; "strlen"; "ucase"; "lcase";
		"year"; "month"; "day"; "hours"; "minutes"; "timezone"; "tz";
		"uri"; "iri"; "bnode"; "strdt"; "strlang";
		"strlen"; "substr"; "strbefore"; "strfater"; "encode_for_uri"; "concat"; "replace";
		"abs"; "round"; "ceil"; "floor"; "rand";
		"md5"; "sha1"; "sha256"; "sha384"; "sha512";
		"BNODE"; "RAND"; "now";
	      ]
	    -> `Appl s
	| uri = Syntax.parse_uri Syntax.re_local -> `Appl uri ]

    method parse_marker : 'str = dcg
      [ _ = kwd "in" -> "in"
      | _ = kwd "from" -> "from"
      | mk = super#parse_marker -> mk ]

    method parse_context (marker : string) : 'p = dcg
        [ _ = kwds ["graph"; "graphs"]; when "'in' expected before 'graph'" marker = "in" -> `GRAPH
	| _ = kwds ["service"; "services"]; when "'from' expected before 'service'" marker = "from" -> `SERVICE ]

    method parse_aggreg_noun : 'p = dcg
	[ _ = kwd "count" -> `Appl "COUNT"
	| _ = kwds ["min"; "minimum"] -> `Appl "MIN"
	| _ = kwds ["max"; "maximum"] -> `Appl "MAX"
	| _ = kwd "sum" -> `Appl "SUM"
	| _ = kwd "average" -> `Appl "AVG"
	| _ = kwd "sample" -> `Appl "SAMPLE"
	| _ = kwds ["concat"; "concatenation"] -> `Appl "GROUP_CONCAT" ]
    method parse_aggreg_adj : 'p = dcg
        [ _ = kwd "number"; _ = ws; _ = kwd "of" -> `Appl "COUNT"
	| _ = kwd "minimum" -> `Appl "MIN"
	| _ = kwd "maximum" -> `Appl "MAX"
	| _ = kwd "total" -> `Appl "SUM"
	| _ = kwd "average" -> `Appl "AVG"
	| _ = kwd "sample" -> `Appl "SAMPLE"
	| _ = kwd "concatenated" -> `Appl "GROUP_CONCAT" ]

    method is_kwd_norm s =
      super#is_kwd_norm s ||
	List.mem s [
	  "add"; "average";
	  "blank"; "bound";
	  "clear"; "concat"; "concatenation"; "concatenated"; "contain"; "containing"; "contains"; "copy"; "count"; "create";
	  "datatype"; "datatypes"; "day"; "days"; "decreasing"; "defined"; "describe"; "drop";
	  "earliest"; "end"; "ending"; "ends";
	  "first";
	  "graph"; "greatest";
	  "highest"; "hours";
	  "increasing"; "IRI";
	  "lang"; "language"; "languages"; "last"; "latest"; "lcase"; "least"; "length"; "lengths"; "lowercase"; "lowest"; "literal"; "load";
	  "match"; "matching"; "matches"; "max"; "maximum"; "min"; "minimum"; "minutes"; "month"; "months"; "move";
	  "new"; "node"; "now"; "number"; "numeric";
	  "pattern"; "prefix";
	  "random";
	  "sample"; "seconds"; "service"; "start"; "starting"; "starts"; "str"; "string"; "strings"; "substring"; "suffix"; "sum";
	  "timezone"; "timezones"; "to"; "total"; "tz";
	  "ucase"; "unbound"; "undefined"; "uppercase"; "URI";
	  "with";
	  "year"; "years";
	]
  end

let rec transform = function
  | `And lf -> List.flatten (List.map transform lf)
  | `Select ([],f1) -> [`ASK f1]
  | `Select (xs,f1) -> [`SELECT (xs,f1)]
  | f -> transform_u f
and transform_u = function
  | `True -> []
  | `And lf1 -> List.filter ((<>) `NOP) (List.flatten (List.map transform_u lf1))
  | `Proc1 (op,x,args) -> transform_u (`Forall (`True, `Proc1 (op,x,args)))
  | `Forall (f1, `Proc1 (`Return, GraphLiteral (_lv,lt), [])) ->
      [`CONSTRUCT (lt,f1)]
  | `Forall (f1, `Proc1 (`Return, x, [])) ->
      let xs, f1 =
	match f1 with
	| `Exists (xs,f1) -> xs, f1
	| _ -> [], f1 in
      let xs1 = if List.mem x xs then xs else xs@[x] in
      [`SELECT (xs1,f1)]
  | `Forall (f1, `Proc1 (`Describe, x, [])) -> [`DESCRIBE ([x],f1)]
  | `Forall (`True, `Proc1 (`Load, Uri x, [])) -> [`LOAD (x, None)]
  | `Forall (`True, `Proc1 (`Load, Uri x, [("into", Uri y)])) -> [`LOAD (x, Some y)]
  | `Forall (`True, `Proc1 (`Clear, Uri x, [])) -> [`CLEAR x] (* missing NAMED, ALL *)
  | `Forall (`True, `Proc1 (`Drop, Uri x, [])) -> [`DROP x] (* idem *)
  | `Forall (`True, `Proc1 (`Create, Uri x, [])) -> [`CREATE x]
  | `Forall (`True, `Proc1 (`Add, Uri x, [("to", Uri y)])) -> [`ADD (x,y)]
  | `Forall (`True, `Proc1 (`Move, Uri x, [("to", Uri y)])) -> [`MOVE (x,y)]
  | `Forall (`True, `Proc1 (`Copy, Uri x, [("to", Uri y)])) -> [`COPY (x,y)]
  | `Forall (_, `Proc1 _) -> invalid_arg "This procedure call is not translatable to SPARQL"
  | `Forall (f1,f2) ->
      let i, d = transform_not f2 in
      [`MODIFY (i, d, f1)]
  | f ->
      match transform_not f with
      | `True, `True -> []
      | `True, d -> [`DELETE d]
      | i, `True -> [`INSERT i]
      | i, d -> [`INSERT i; `DELETE d]
and transform_not = function
  | `Context (kind, x, `True) -> transform_not `True
  | `Context (kind, x, `And lf1) ->
      let i, d = transform_not (`And lf1) in
      apply_context kind x i, apply_context kind x d
  | `Context (kind, x, `Not f1) ->
      let i, d = transform_not (`Not f1) in
      apply_context kind x i, apply_context kind x d
  | `True -> `True, `True
  | `And lf1 ->
      let li, ld = List.split (List.map transform_not lf1) in
      and_ li, and_ ld
  | `Not f1 -> `True, transform_quads f1
  | f -> transform_quads f, `True
and transform_quads = function
  | `True -> `True
  | `And lf1 -> and_ (List.map transform_quads lf1)
  | `Exists (xs,f1) -> `Exists (xs, transform_quads f1)
  | `Context (kind,x,f1) ->
      let i = transform_triples f1 in
      apply_context kind x i
  | f -> transform_triples f
and apply_context kind x = function
  | `True -> `True
  | f -> `Context (kind, x, f)
and transform_triples = function
  | `True -> `True
  | `And lf1 -> and_ (List.map transform_triples lf1)
  | `Exists (xs,f1) -> `Exists (xs, transform_triples f1)
  | `Triple _ as f -> f

  | `Func _
  | `Pred _
  | `Proc1 _
  | `Aggreg _ -> failwith "built-ins and aggregations are not allowed in updates"
  | `Modif _ -> failwith "solution modifiers are not allowed in updates"
  | `Context _ -> failwith "nested graphs and services are not allowed in updates"
  | `Forall _ -> failwith "nested universals are not allowed in updates"
  | `Not _ -> failwith "nested negations are not allowed in updates"
  | `Or _ -> failwith "disjunctions are not allowed in updates"
  | `Option _ -> failwith "optionals are not allowed in updates"
  | _ -> failwith "invalid update"


(* generation of SPARQL *)

let space = ipp [ _ -> " " ]
let dot = ipp [ _ -> " . " ]
let print_int = ipp [ i -> '(string_of_int i) ]
let rec print_term = ipp
    [ Var "" -> "[]"
    | Var s -> "?"; 's
    | Ref l -> '(failwith "some references are unresolved")
    | Uri s -> 's
    | Literal s -> 's
    | GraphLiteral _ -> '(failwith "graph literals are not supported in SPARQL")
    | Cons (e,l) -> "[ rdf:first "; print_term of e; " ; rdf:rest "; print_term of l; " ]" ]

let rec print = ipp
    [ ls -> LIST0 print_s SEP "\n" of ls; EOF ]
and print_s = ipp
(*
    [ `ASK (`Not (`Exists (x::_, f))) -> "ASK { OPTIONAL { "; print_g of f; "} FILTER (!BOUND("; print_term of x; ")) }"
    | `ASK (`Exists (_, `Modif (`Mod { boundness },x,f))) -> "ASK { "; print_g_boundness of boundness, x, f; "}"
    | `ASK (`Modif (`Mod { boundness },x,f)) -> "ASK { "; print_g_boundness of boundness, x, f; "}"
*)
    [ `ASK f -> "ASK { "; print_g of f; "}"
    | `SELECT (xs, (`Modif (op,lz,x,f))) -> print_modif of `Modif (op,xs,x,f)
    | `SELECT (xs, `Exists (_, (`Modif (op,lz,x,f)))) -> print_modif of `Modif (op,xs,x,f)
    | `SELECT (_, (`Aggreg _ as f)) -> print_aggreg of f
    | `SELECT (_, `Exists (_, (`Aggreg _ as f))) -> print_aggreg of f
    | `SELECT (xs, f) -> "SELECT DISTINCT "; LIST1 print_term SEP " " of xs; " WHERE { "; print_g of f; "}"
    | `CONSTRUCT (lt, f) -> "CONSTRUCT { "; MANY print_triple of lt; "} WHERE { "; print_g of f; "}"
    | `DESCRIBE (xs, f) -> "DESCRIBE "; LIST1 print_term SEP " " of xs; [ `True ->  | f -> " WHERE { "; print_g of f; "}" ] of f
    | `LOAD (x,None) -> "LOAD "; 'x
    | `LOAD (x, Some y) -> "LOAD "; 'x; " INTO GRAPH "; 'y
    | `CLEAR x -> "CLEAR "; print_graph_ref_all of x
    | `DROP x -> "DROP "; print_graph_ref_all of x
    | `CREATE x -> "CREATE GRAPH "; 'x
    | `ADD (x,y) -> "ADD "; 'x; " TO "; 'y
    | `MOVE (x,y) -> "MOVE "; 'x; " TO "; 'y
    | `COPY (x,y) -> "COPY "; 'x; " TO "; 'y
    | `INSERT i -> "INSERT DATA { "; print_g of i; "} "
    | `DELETE d -> "DELETE DATA { "; print_g of d; "} "
    | `MODIFY (i,d,g) ->
	[ d -> when d <> `True; "DELETE { "; print_g of d; "} " | _ -> ] of d;
	[ i -> when i <> `True; "INSERT { "; print_g of i; "} " | _ -> ] of i;
	[ g -> when g <> `True; "WHERE { "; print_g of g; "}" | _ -> ] of g ]
and print_graph_ref_all = ipp
    [ "ALL" -> "ALL"
    | "NAMED" -> "NAMED"
    | "DEFAULT" -> "DEFAULT"
    | uri -> "GRAPH "; 'uri ]
and print_g = ipp
    [ `Triple (s, Uri "rdf:element", o) -> print_triple of (s, Uri "rdf:rest*/rdf:first", o)
    | `Triple (s, Uri "rdf:last", o) -> print_term of s; space; print_term of (Uri "rdf:rest*"); space; "("; print_term of o; ")"; dot
    | `Triple (s,p,o) -> print_triple of (s,p,o)
    | `Matches (x,lre) ->
	"FILTER ("; LIST1 [ x, re -> "REGEX(str("; print_term of x; "),'"; 're; "','i')" ] SEP " && " of List.map (fun re -> (x,re)) lre; ")"; dot
(*	"FILTER (REGEX(str("; print_term of x; "),"; 're; ",'i') || EXISTS { "; print_term of x; " rdfs:label ?llsquall . FILTER REGEX(str(?llsquall),"; 're; ",'i') })"; dot *) (* requires Sparql 1.1: EXISTS *)
    | `Func (`Id, [Uri _ as x], (Var _ as y)) -> "VALUES "; print_term of y; " { "; print_term of x; " }"; dot
    | `Func (`Id, [Cons (e,l)], y) -> print_term of y; " rdf:first "; print_term of e; " ; rdf:rest "; print_term of l; dot
    | `Func (op,lx, (Var _ as y)) -> "BIND ("; print_expr of (op,lx); " AS "; print_term of y; ")"; dot
    | `Func (op,lx,y) -> "FILTER ("; print_expr of (op,lx); " = "; print_term of y; ")"; dot
    | `Pred (op,lx) -> "FILTER "; print_pred of op, lx; dot
    | `Context (kind,x,f) -> print_context_kind of kind; " "; print_term of x; " { "; print_g of f; "} "
    | `Aggreg _ as f -> "{ "; print_aggreg of f; "} "
    | `Modif _ as f -> "{ "; print_modif of f; "} "
    | `Exists (xs,f) -> print_g of f
    | `Forall (f1,f2) -> print_g of `Not (`And [f1; `Not f2])
    | `True -> 
    | `Not f -> "FILTER NOT EXISTS { "; print_g of f; "} "
    | `And lf -> MANY print_g of lf
    | `Or lf -> LIST1 [ f -> "{ "; print_g of f; "} " ] SEP "UNION " of lf
    | `Option f -> "OPTIONAL { "; print_g of f; "} " ]
and print_triple = ipp
    [ (s,p,o) -> print_term of s; space; print_predicate of p; space; print_term of o; dot ]
and print_predicate = ipp
    [ Uri "rdf:type" -> "a"
    | p -> print_term of p ]
and print_pred = ipp
    [ `Appl f, lx -> 'f; "("; LIST0 print_term SEP "," of lx; ")"
    | `Infix f, [x; y] -> "("; print_term of x; space; 'f; space; print_term of y; ")"
    | `Eq, lx -> print_pred of `Infix "=", lx
    | `Neq, lx -> print_pred of `Infix "!=", lx
    | `Geq, lx -> print_pred of `Infix ">=", lx
    | `Leq, lx -> print_pred of `Infix "<=", lx
    | `Gt, lx -> print_pred of `Infix ">", lx
    | `Lt, lx -> print_pred of `Infix "<", lx ]
and print_expr = ipp
    [ `Id, [x] -> print_term of x
    | `Prefix f, lx -> 'f; LIST0 print_term SEP " " of lx
    | `Infix f, lx -> let sep = " " ^ f ^ " " in LIST1 print_term SEP 'sep of lx
    | `Appl f, lx -> 'f; "("; LIST0 print_term SEP "," of lx; ")" ]
and print_aggreg = ipp
    [ `Aggreg (op, x, y, lz, f) ->
        "SELECT DISTINCT "; LIST0 print_term SEP " " of lz;
        " ("; print_aggreg_op of op; print_term of y; ") AS "; print_term of x;
        ") WHERE { "; print_g of f; "} ";
        [ [] ->  | lz -> "GROUP BY "; LIST0 print_term SEP " " of lz; space ] of lz ]
and print_aggreg_op = ipp
    [ `Count -> "COUNT(DISTINCT "
    | `Appl "COUNT" -> "COUNT(DISTINCT "
    | `Appl g -> 'g; "(" ]
and print_modif = ipp
    [ `Modif (op,xs,x,f) ->
      "SELECT DISTINCT "; LIST1 print_term SEP " " of (if List.mem x xs then xs else xs@[x]);
      " WHERE { "; print_modif_op of (op,x,f) ]
and print_modif_op = ipp
    [ `Mod { order; offset; limit }, x, f -> 
        print_g of f; "} "; print_order of order, x; print_offset of offset; print_limit of limit ]
(*
and print_g_boundness = ipp
    [ `NONE, x, f -> print_g of f
    | `BOUND, x, f -> print_g of f (* merge NONE and BOUND ? *)
    | `UNBOUND, x, f -> "OPTIONAL { "; print_g of f; "} FILTER ("; "!BOUND("; print_term of x; ")) " ]
*)
and print_order = ipp
    [ `NONE, x -> 
    | order, x -> "ORDER BY "; [ `DESC -> "DESC" | `ASC -> "ASC" ] of order; "("; print_term of x; ") " ]
and print_offset = ipp
    [ 0 -> 
    | offset -> "OFFSET "; print_int of offset; " " ]
and print_limit = ipp
    [ -1 -> 
    | limit -> "LIMIT "; print_int of limit ]
and print_context_kind = ipp
    [ `GRAPH -> "GRAPH"
    | `SERVICE -> "SERVICE SILENT" ]
