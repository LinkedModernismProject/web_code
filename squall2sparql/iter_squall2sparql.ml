(*
   Reads squall sentences from input, one per line.
   Prints their SPARQL translation, one per line.
*)

let _ =
  try 
    while true do
      let line = read_line () in
      print_endline line;
      if line <> "" then begin
	let code = Sys.command ("./squall2sparql \"" ^ String.escaped line ^ "\"") in
	if code <> 0
	then begin
	  prerr_newline ();
	prerr_endline line;
	exit 1 end
	else begin
	  prerr_string ".";
	  flush stderr
	end
      end
    done
  with
    | End_of_file -> prerr_newline ()
