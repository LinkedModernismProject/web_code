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

(*
   Command line version of SQUALL2SPARQL.
   Usage: read a SQUALL sentence on stdin, and write a SPARQL sentence on stdout.
*)

let _ =
  try
    let context = new Sparql.context (*Dbpedia.context*) in
    let _, sem =
      let cursor =
	try Matcher.cursor_of_string Syntax.skip Sys.argv.(1)
	with _ -> Matcher.cursor_of_channel Syntax.skip stdin in
      Dcg.once Syntax.parse context cursor in
    let sem = Semantics.validate sem in
    let sparql =
      let cursor = Printer.cursor_of_formatter Format.std_formatter in
      Ipp.once Sparql.print (Sparql.transform sem) cursor context;
      Format.print_newline () in
    exit 0
  with exn ->
    prerr_string (Printexc.to_string exn);
    exit 1
