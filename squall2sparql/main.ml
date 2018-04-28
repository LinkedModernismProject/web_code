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

let rec list_rev_undup = function
  | [] -> []
  | x::xs ->
    if List.mem x xs
    then list_rev_undup xs
    else x::list_rev_undup xs

let print_sem context sem =
  let _ = Ipp.once Semantics.print sem (Printer.cursor_of_formatter Format.std_formatter) context in
  print_newline ()

let step () =
  let line = read_line () in
  if List.mem line ["exit"; "quit"]
  then false
  else
    try
      let context = new Sparql.context (*Dbpedia.context*) in
      let sols =
	if Array.length Sys.argv > 1 && Sys.argv.(1) = "all"
	then Dcg.all Syntax.parse context (Matcher.cursor_of_string Syntax.skip line)
	else [Dcg.once Syntax.parse context (Matcher.cursor_of_string Syntax.skip line)] in
      let sols = List.map snd sols in
      let sols = list_rev_undup sols in
      List.iter
	(fun sem ->
	  print_sem context sem;
	  let sem = Semantics.validate sem in
	  print_sem context sem;
	  let sparql =
	    let cursor = Printer.cursor_of_formatter (Format.str_formatter) in
	    Ipp.once Sparql.print (Sparql.transform sem) cursor context;
	    Format.flush_str_formatter () in
	  print_string "SPARQL > ";
	  print_endline sparql)
	sols;
      true
    with exn ->
      print_endline (Printexc.to_string exn);
      true

let prompt () = print_string "squall < "

let _ =
  prompt ();
  while step () do
    prompt ()
  done

