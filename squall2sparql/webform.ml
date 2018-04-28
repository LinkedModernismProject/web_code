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

open Eliom_pervasives
open HTML5.M
open Eliom_services
open Eliom_parameters
open Eliom_output.Html5


let sparql_of_squall = function squall ->
  let context = new Sparql.context in
  let _, sem =
    Dcg.once Syntax.parse context (Matcher.cursor_of_string Syntax.skip squall) in
  let sem = Semantics.validate sem in
  let cursor = Printer.cursor_of_formatter (Format.str_formatter) in
  Ipp.once Sparql.print (Sparql.transform sem) cursor context;
  Format.flush_str_formatter ()


let break_at_dot = function s ->
  let l = Str.full_split (Str.regexp_string " . ") s in
  let rec to_html l = match l with
    | Str.Text txt :: Str.Delim _ :: l' -> (pcdata (txt ^ " . ")) :: (br ()) :: (to_html l')
    | Str.Text txt :: [] -> [pcdata txt]
    | [] -> []
    | _ -> assert false
  in
  to_html l

let rec sparql_pp = function s ->
  let re = Str.regexp "\\([^{]*{\\)\\(.+\\)\\(}[^}]*\\)" in
  if Str.string_match re s 0 then
    let before = Str.matched_group 1 s in
    let middle = Str.matched_group 2 s in
    let after  = Str.matched_group 3 s in
    div ~a:[a_class ["indent"]] (List.concat [break_at_dot before;
                                              [sparql_pp middle];
                                              break_at_dot after])
  else
    div ~a:[a_class ["indent"]] (break_at_dot s)

let common_prologue =
  "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" ^
  "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" ^
  "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" ^
  "PREFIX owl: <http://www.w3.org/2002/07/owl#>\n"

let sparql_for_dbpedia sparql =
  common_prologue ^
  "PREFIX foaf: <http://xmlns.com/foaf/0.1/>\n" ^
  "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" ^
  "PREFIX res: <http://dbpedia.org/resource/>\n" ^
  "PREFIX dbo: <http://dbpedia.org/ontology/>\n" ^
  "PREFIX dbp: <http://dbpedia.org/property/>\n" ^
  "PREFIX : <http://dbpedia.org/ontology/>\n" ^
  sparql

(* ------------------------------------------------------------------ *)
(* Services *)

let main_service = Eliom_services.service ~path:[""] ~get_params:unit ()

let translate_service = Eliom_services.service
  ~path:["translate"]
  ~get_params:(Eliom_parameters.string "squall") ()

let query_form_service = Eliom_services.service ~path:["query_form"] ~get_params:unit ()

let query_service = Eliom_services.service
    ~path:["query"]
    ~get_params:(prod (string "endpoint")
		   (prod (string "output")
		      (prod (string "prologue")
			 (string "squall"))))
    ()

let examples_service = Eliom_services.service ~path:["examples"] ~get_params:unit ()

let squall_page = Eliom_services.external_service ~prefix:"http://www.irisa.fr" ~path:["LIS"; "softwares"; "squall"] ~get_params:unit ()
let bitbucket = Eliom_services.external_service ~prefix:"http://bitbucket.org" ~path:["sebferre"; "squall2sparql"] ~get_params:unit ()
let iswc04_paper = external_service ~prefix:"http://www.springerlink.com" ~path:["content"; "ftxy71qedrhb945v"] ~get_params:unit ()
let qald2 = external_service ~prefix:"http://greententacle.techfak.uni-bielefeld.de" ~path:["~cunger";"qald"] ~get_params:unit ()
let dbpedia_nsdecl = external_service ~prefix:"http://dbpedia.org" ~path:["sparql"] ~get_params:(string "nsdecl") ()
let dbpedia_sparql = external_service ~prefix:"http://dbpedia.org" ~path:["sparql"] ~get_params:(string "query") ()
let dbpedia_snorql = external_service ~prefix:"http://dbpedia.org" ~path:["snorql"] ~get_params:(string "query") ()

(* ------------------------------------------------------------------ *)
(* Some HTML that's repeated on every page *)
let menu =

  div ~a:[a_id "menu"]
    [ ul [ li [a ~service:main_service [pcdata "Translation form"] ()];
	   li [a ~service:query_form_service [pcdata "Query form"] ()];
           li [a ~service:examples_service  [pcdata "Examples"] ()];
           li [a ~service:bitbucket [pcdata "Download"] ()];
           li [a ~service:squall_page [pcdata "More information"] ()];
         ]
    ]

(* ------------------------------------------------------------------ *)
(* Handlers *)


(* This form is used by both handlers *)
let translate_form =
  let create_form = fun field_name ->
    [p [pcdata "Enter a SQUALL sentence: "; br ();
        string_input ~a:[a_size 100; a_autofocus `Autofocus] ~input_type:`Text ~name:field_name (); br ();
        string_input ~input_type:`Submit ~value:"Translate" ()]] in
  Eliom_output.Html5.get_form ~service:translate_service create_form

(* This form is used for querying distant SPARQL endpoints *)
let query_form =
  let create_form = fun (endpoint_name, (output_name, (prologue_name, squall_name))) ->
    [p [pcdata "Endpoint URL: "; br ();
	string_input ~a:[a_size 50; a_autofocus `Autofocus] ~input_type:`Text ~name:endpoint_name (); br ();
	pcdata "SPARQL Prologue: "; br ();
	textarea ~name:prologue_name ~rows:10 ~cols:100 ~value:common_prologue (); br ();
	pcdata "SQUALL sentence: "; br ();
	textarea ~name:squall_name ~rows:10 ~cols:100 (); br ();
	pcdata "Output: ";
	string_select ~name:output_name
	  (Option ([],"",None,false))
	  (List.map (fun (v,l) -> Option ([],v,Some (pcdata l),false))
	     ["xml", "XML";
	      "json", "JSON";
	      "text", "Text";
	      "csv", "CSV";
	      "tsv", "TSV"]);
	string_input ~input_type:`Submit ~value:"Get results" ()]] in
  Eliom_output.Html5.get_form ~service:query_service create_form

let webform_css =
  Eliom_output.Html5_forms.css_link
	~uri:(Eliom_output.Html5.make_uri (Eliom_services.static_dir ())
		    ["webform.css"]) ()


let translate_handler = fun (squall) () ->
  let sparql = sparql_of_squall squall in
  Lwt.return
   (html
    (head (title (pcdata "SQUALL to SPARQL Translator")) [webform_css])
    (body [menu;
           h1 [pcdata "SQUALL to SPARQL Translator"];
           h2 [pcdata "Your SQUALL sentence: "];
           p [pcdata squall];
           h2 [pcdata "The SPARQL translation: "];
           sparql_pp sparql;
           p [a ~service:dbpedia_sparql [pcdata "Run at DBpedia SPARQL endpoint"]
		(sparql_for_dbpedia sparql);
              pcdata " (assuming prefixes res: for resources, : and dbo: for ontology, and dbp: for properties in addition to ";
	      a ~service:dbpedia_nsdecl [pcdata "DBpedia namespace definitions"] "";
	      pcdata ")."];
           p [a ~service:dbpedia_snorql [pcdata "Load in DBpedia SPARQL Explorer"]
		(sparql_for_dbpedia sparql);
              pcdata " (assuming the same prefixes as above)."];
           hr ();
           translate_form]))

let query_handler = fun (endpoint, (output, (prologue, squall))) () ->
  let endpoint_prefix, endpoint_path =
    let n = String.length endpoint in
    try
      let i = String.rindex_from endpoint (n-2) '/' in
      String.sub endpoint 0 i, [String.sub endpoint (i+1) (n-i-1)]
    with Not_found ->
      endpoint, [] in
  let sparql = sparql_of_squall squall in
  let sparql = prologue ^ sparql in
  if output = ""
  then
    let external_service = external_service ~prefix:endpoint_prefix ~path:endpoint_path
	~get_params:(string "query") () in
    Lwt.return (preapply ~service:external_service sparql)
  else
    let external_service = external_service ~prefix:endpoint_prefix ~path:endpoint_path
	~get_params:(prod (string "output") (string "query")) () in
    Lwt.return (preapply ~service:external_service (output,sparql))
  

let main_handler = fun () () ->
  Lwt.return
    (html
       (head (title (pcdata "SQUALL to SPARQL Translator")) [webform_css])
       (body [menu;
              h1 [pcdata "SQUALL to SPARQL Translator"];
              p [pcdata "SQUALL (Semantic Query and Update High-Level Language) is a controlled natural language for querying and updating RDF graphs. SQUALL has a strong adequacy with RDF, and covers all constructs of SPARQL, and many of SPARQL 1.1."];
              p [pcdata "This demo page allows you to translate a SQUALL expression to SPARQL."];
              p [pcdata "SQUALL is designed and implemented by Sébastien Ferré. Please visit the ";
                 a ~service:squall_page [pcdata "official SQUALL web page"] ();
                 pcdata " for more information, source code and papers about SQUALL."];
              hr ();
              translate_form]))

let query_form_handler = fun () () ->
  Lwt.return
    (html
       (head (title (pcdata "SQUALL query form")) [webform_css])
       (body [menu;
	      h1 [pcdata "SQUALL query form"];
	      p [pcdata "This page allows you to query a SPARQL endpoint using the SQUALL language."];
	      p [pcdata "SQUALL is designed and implemented by Sébastien Ferré. Please visit the ";
                 a ~service:squall_page [pcdata "official SQUALL web page"] ();
                 pcdata " for more information, source code and papers about SQUALL."];
              hr ();
	      query_form]))


let examples_handler = fun () () ->
  let example_link txt = 
    if txt = "" || txt = "OUT OF SCOPE"
    then pcdata "OUT OF SCOPE"
    else a ~service:translate_service [pcdata txt] txt in
  let example_cell txt = dd [example_link txt] in
  let example_item txt = li [example_link txt] in
  let examples_section title sentences =
    let sentences = if sentences = [] then [""] else sentences in
    (dt [pcdata title], []),
    (example_cell (List.hd sentences),
     List.map example_cell (List.tl sentences)) in
  let examples_enum sentences =
    ol (List.map example_item sentences) in
  Lwt.return
    (html
       (head (title (pcdata "SQUALL to SPARQL Translator")) [webform_css])
       (body [menu;
              h1 [pcdata "SQUALL Examples"];
              h2 [pcdata "Language features"];
              p [pcdata "A number of the following examples were freely inspired by ";
                 em [a ~service:iswc04_paper [pcdata "A Comparison of RDF Query Languages"] ()];
                 pcdata " (Haase, Broekstra, Eberhart and Volz, ISWC'04)."];
              dl [ 
		examples_section "Path expressions" [
		  "What is the name of the author-s of PaperX?";
		];
                examples_section "Union" [
		  "What is the label of a topic or is the title of a publication?";
		];
                examples_section "Difference" [
		  "What is the label of a topic and is not the title of a publication?";
		];
                examples_section "Optional" [
		  "The author-s of a publication have which name and maybe have which email?";
		  "What is the name of an author X of a publication and if defined, what is the email of X ?";
		];
                examples_section "Quantification" [
		  "Which person is an author of every publication?";
		  "Which person is an author of at least 10 publication-s?";
		];
		examples_section "Modifiers" [
		  "Which mountain has the highest elevation ?";
		  "Which mountain has an elevation that is the 2nd highest ?";
		  "Which person-s have the 10 lowest age ?";
		  "Which person-s have a child whose age is the 3rd to 5th lowest ?";
		];
                examples_section "Aggregation" [
		  "How many person-s are an author of PaperX?";
		  "PaperX has how many author-s?";
		  "What is the number of author-s of PaperX?";
		  "Which publication has how many author-s?";
		  "Which publication has at least 3 author-s?";
		  "Which publication has between 2 and 3 author-s?";
		  "Which publication has the most author-s?";
		  "Who is the author of the most publication-s?";
		];
                examples_section "Grouping" [
		  "How many person-s have which affiliation ?";
		  "What is the number of person-s per affiliation ?";
		  "How many publication-s have an author that has which affiliation?";
		  "What is the number of publication-s X per the affiliation of an author of X ?";
		  "What is the number of publication-s whose author has some affiliation A per A ?";
		  "What is the average number of publication-s per author ?";
		  "For every journal J, give me the average number of publication-s that are-publishedIn J per author.";
		];
                examples_section "Recursion" [
		  "What is a subtopic+ of InformationSystems?";
		];
                examples_section "Entailment" [
		  "What is a publication?";
		  "What has a rdf:type that is-rdfs:subClassOf* the class publication?";
		];
		examples_section "Reifications of predicates ('relate(s)') and classes ('belong(s)')" [
		  "Which rdf:Property relates a publication to a person?";
		  "To which nationality an author of PaperX belongs?";
		];
                examples_section "Graphs and services" [
		  "In which graph whose source is SourceX every publication has at least 1 author?";
		  "Give me all researcher-s which from service Facebook have at least 10 friend-s.";
		  "In which graph PersonX know-s PersonY?";
		  "Which person knows PersonX in at least 3 graphs?";
		];
		examples_section "Patterns" [
		  "How many publication-s have topic 'Computer Science' ?";
		  "Which person whose rdfs:label is 'John Smith' is an author of PaperX ?";
		];
                examples_section "Namespaces" [
		  "Which organisation has a str that matches \"^http:/www.aifb.unikarlsruhe.de/\"?";
		  "The string of which organisation matches \"^http:/www.aifb.unikarlsruhe.de/\"?";
		];
                examples_section "Language" [
		  "What has language \"de\" and is the rdfs:label of the topic that has a rdfs:label whose str is \"Database Management\" and whose language is \"en\"?";
		];
                examples_section "Literals and Datatypes" [
		  "Which publication has pageNumber 8?";
		  "Which publication has a pageNumber whose str is \"08\"?";
		];
		examples_section "Expressions" [
		  "Which rectangle has the heigth * the width equal to 100 and has 2 * (the height + the width) equal to 40 ?";
		  "Return concat(\"Hello \", the foaf:firstName, \" \", the foaf:lastName, \" !\") of all person-s .";
		  "Which person has substr(the foaf:name,0,3) that contains \"Dr\" ?";
		  "Is every odd + every even an even ?";
		];
                examples_section "Collections" [
		  "Which publication-s have authorList [PersonA, PersonB, PersonC] ?";
		  "Which publication-s have authorList [PersonA, _, PersonC] ?";
		  "What is an rdf:element of the authorList of PaperX ?";
		  "PaperX has authorList [..., what, ...] ?";
		  "What is the rdf:last of the authorList of PaperX ?";
		  "PaperX has authorList [..., what] ?";
		];
		examples_section "Imperative questions" [
		  "Return the publication-s of PersonX .";
		  "List all author-s of PaperX .";
		  "Give me the title of the publication-s of PersonX .";
		];
                examples_section "Closed questions (ASK)" [
		  "Whether PubliX has an author that worksFor OrgY?";
		  "Does PaperX have an author that worksFor OrgY ?";
		];
		examples_section "Describe questions (DESCRIBE)" [
		  "Describe PaperX.";
		  "Describe every author of PaperX.";
		];
		examples_section "Graph literals as results (CONSTRUCT, N3 formulas)" [
		  "For every person X that shares a parent with a person Y, return that X has sibling Y and Y has sibling X.";
		  "For every person X, for S = concat(every firstname, \" \", every lastname) of X, return that X has fullname S.";
		  "If a person X shares a parent with a person Y then return that X has sibling Y and Y has sibling X.";
		];

                examples_section "Insertion" [
		  "BookX is a book whose title is \"A new book\" and whose author is PersonY.";
		];
                examples_section "Deletion" [
		  "In graph GraphA BookX has title \"Compiler Design\" and not \"Compiler desing\".";
		];
                examples_section "Group of updates" [
		  "For every book B that some P relates to some V and whose date < 2001-01-01, P does not relate B to V.";
		  "If a book B has at least 2 author-s then B is a CollaborativeWork.";
		];
		examples_section "Graph-level updates" [
		  "Load <http://example.org/data.rdf> into GraphA.";
		  "Move GraphA to the default graph.";
		  "Clear all named graphs.";
		  "Drop all graphs.";
		];
                examples_section "Copy" [
		  "Every P that relates some S to some V in graph GraphA relates S to V in graph GraphB.";
		];
                examples_section "Move" [
		  "Every P that relates some S to some V in graph GraphA relates S to V in graph GraphB and not GraphA.";
		];
              ];

              h2 [pcdata "About films in DBpedia"];
              p [pcdata "The following examples are valid queries for the DBpedia SPARQL endpoint. To get results to those queries from DBpedia, just click the first link after the SPARQL translation. To make the writing of queries more concise and natural, the following prefix declarations are added to those of the Dbpedia SPARQL endpoint:"];
	      p [pcdata "PREFIX : <http://dbpedia.org/ontology/>"; br ();
		 pcdata "PREFIX res: <http://dbpedia.org/resource/>"; br ();
		 pcdata "PREFIX dbo: <http://dbpedia.org/ontology/>"; br ();
		 pcdata "PREFIX dbp: <http://dbpedia.org/property/>"];
	      examples_enum [
		"List all Film-s.";
		"Which Film has director res:Tim_Burton and is-starring res:Johnny_Depp and res:Helena_Bonham_Carter ?";
		"Which Film whose releaseDate is greater or equal to 2010-01-01 has a director whose birthPlace is res:England or res:United_States ?";
		"Which Film has country res:France or has a director or starring or musicComposer whose birthPlace is res:France ?";
		"Which Person has birthPlace res:United_States and is the director of a Film that is-starring res:Johnny_Depp and whose releaseDate is what ?";
		"Which Person X is the director of a Film that is-starring X ?";
		"Which Film has which country X and has a director whose birthPlace is not X ?";
		"How many Film-s whose director is res:Tim_Burton are-starring which Person ?";
	      ];

	      h2 [pcdata "QALD-3 DBpedia training questions"];
	      p [pcdata "The following examples are SQUALL translations for the DBpedia training questions from the ";
		 a ~service:qald2 [pcdata "QALD challenge"] ();
		 pcdata ", co-located with CLEF 2013. Those SQUALL translations have been designed to conform to the SPARQL solutions, and therefore may not be the simplest translation of the original English questions. We here assume the same prefixes as above."];
	      examples_enum [
		"Give me all yago:RussianCosmonauts that are a yago:FemaleAstronauts.";
		"Give me the birthDate of the starring-s of res:Charmed.";
		"Who is the dbp:spouse of the child of res:Ingrid_Bergman?";
		"res:Brooklyn_Bridge crosses which River?";
		"How many yago:EuropeanCountries have governmentType 'monarchy'?";
		"What is the deathPlace of res:John_F._Kennedy?";
		"Is the spouse of res:Barack_Obama 'Michelle'?";
		"Which yago:StatesOfGermany have dbp:rulingParty 'SPD' or 'Social Democratic Party'?";
		"Which yago:StatesOfTheUnitedStates have dbp:mineral 'Gold'?";
		"What is the sourceCountry of res:Nile?";
		"Which Country is the location of more than 2 Cave-s?";
		"Is res:Proinsulin a Protein?";
		"What is the dbp:classis of 'tree frog'?";
		"What is the height of res:Claudia_Schiffer?";
		"Who is the creator of res:Goofy?";
		"Give me the capital-s of the yago:AfricanCountries.";
		"Give me all City-es that isPartOf res:New_Jersey and whose populationTotal is greater than 100000.";
		"What is the dbp:museum of res:The_Scream ?";
		"Is the largestCity of res:Egypt the capital of res:Egypt?";
		"What is the numberOfEmployees of res:IBM?";
		"What are the dbp:borderingstates of res:Illinois?";
		"What is the country of res:Limerick_Lake?";
		"Which TelevisionShow has creator res:Walt_Disney?";
		"Which Mountain has the highest elevation lesser than the elevation of res:Annapurna?";
		"Which Film has director res:Garry_Marshall and is-starring res:Julia_Roberts?";
		"Which Bridge shares a dbp:design with res:Manhattan_Bridge?";
		"Does res:Andrew_Jackson have a battle?";
		"Which yago:EuropeanCountries have governmentType res:Constitutional_monarchy?";
		"What are the dbp:awards of res:WikiLeaks?";
		"Which yago:StatesOfTheUnitedStates has the lowest dbp:densityrank?";
		"What is the currency of res:Czech_Republic?";
		"Which yago:EuropeanUnionMemberStates have dbp:currencyCode 'EUR'?";
		"What is the areaCode of res:Berlin?";
		"Which Country has more than 2 officialLanguage-s?";
		"Who is the owner of res:Universal_Studios?";
		"What are the dbp:country of res:Yenisei_River?";
		"What is the dbp:accessioneudate of res:Latvia?";
		"Which yago:MonarchsOfTheUnitedKingdom have a spouse whose birthPlace is res:Germany?";
		"What is the date of res:Battle_of_Gettysburg?";
		"Which Mountain that is-locatedInArea res:Australia has the highest elevation?";
		"Give me all SoccerClub whose dbp:ground is 'Spain'.";
		"What are the officialLanguage-s of res:Philippines?";
		"What is the leaderName of res:New_York_City?";
		"Who is the dbp:designer of res:Brooklyn_Bridge?";
		"Which Organisation-s whose dbp:industry is 'Telecommunication' have location res:Belgium?";
		"Does res:Frank_Herbert have no deathDate?";
		"What is the highestPlace of res:Karakoram?";
		"Give me the foaf:homepage of res:Forbes.";
		"Give me all Company-es whose dbp:industry is 'advertising'.";
		"What is the deathCause of res:Bruce_Carver?";
		"Give me all yago:SchoolTypes.";
		"Which President-s or yago:Presidents have birthDate '1945'?";
		"Give me all yago:PresidentsOfTheUnitedStates.";
		"Who is the spouse of res:Abraham_Lincoln?";
		"Who is the developer of res:World_of_Warcraft?";
		"What is the foaf:homepage of res:Tom_Cruise?";
		"List all TelevisionEpisode-s whose series is res:The_Sopranos and whose seasonNumber is 1.";
		"Who is the producer of the most Film-s?";
		"Give me all foaf:Person whose foaf:givenName is 'Jimmy'.";
		"Is there a VideoGame that is 'Battle Chess'?";
		"Which Mountain has a greater dbp:elevationM than res:Nanga_Parbat?";
		"Who is the author of res:Wikipedia?";
		"Who does 'Last Action Hero' be-starring?";
		"Which Software-s have developer an Organisation whose foundationPlace is res:California?";
		"Which Company has dbp:industry res:Aerospace and res:Nuclear_reactor_technology?";
		"Is res:Christian_Bale a starring of res:Batman_Begins?";
		"Give me the foaf:homepage of the Company-es whose dbp:numEmployees is greater than 500000.";
		"Which Actor-s have birthPlace res:Germany or a thing whose country is res:Germany?";
		"Which Cave-s have an dbp:entranceCount greater than 3?";
		"Give me all Film-s whose producer is res:Hal_Roach.";
		"Give me all VideoGame-s whose publisher is 'Mean Hamster Software'.";
		"What is a :language of res:Estonia or is-spokenIn res:Estonia?";
		"Who is the keyPerson of res:Aldi?";
		"Which yago:CapitalsInEurope are a yago:HostCitiesOfTheSummerOlympicGames?";
		"Who has orderInOffice '^5th President United States'?";
		"How many Film-s have producer res:Hal_Roach?";
		"What is the album of 'Last Christmas'?";
		"Give me all Book-s whose author is res:Danielle_Steel.";
		"Which Airport-s have location res:California ?";
		"Give me all RecordLabel-s whose genre is res:Grunge and whose country is res:Canada.";
		"Which Country has the most dbp:officialLanguages?";
		"What is the programmingLanguage of res:GIMP?";
		"Who are the producer-s of the Film-s that are-starring res:Natalie_Portman?";
		"Give me all Film-s that are-starring res:Tom_Cruise.";
		"Which Film-s are-starring res:Julia_Roberts and res:Richard_Gere?";
		"Give me all yago:FemaleHeadsOfGovernment whose dbp:office is res:Chancellor_of_Germany.";
		"Who is the author of res:The_Pillars_of_the_Earth?";
		"How many Film-s are-starring res:Leonardo_DiCaprio?";
		"Give me all SoccerClub-s whose league is res:Premier_League.";
		"What is the dbp:foundation of res:Capcom?";
		"Which Organisation-s have dbp:foundation or formationYear '1950'?";
		"Which Mountain has the highest elevation?";
		"Does res:Natalie_Portman have a birthPlace whose country is res:United_States?";
		"What is the budget of the Film whose director is 'Zdenek Sverak' and whose releaseDate is the earliest?";
		"How many Fire-s have location res:Paris and have period 'Middle Age'?";
		"Is 'Jen Friebe' a Vegan?";
		"How many divorce-s of 'Michael Jordan' are there?";
		"Which Painting has the highest beauty?";
		"Give me all Species whose livingPlace is 'Teutoburg Forest'.";
		"What is the releaseDateInNetherlands of 'Worst Case Scenario'?";
	      ];

	      h2 [pcdata "QALD-3 DBpedia test questions"];
	      p [pcdata "Same as above with DBpedia 'test' questions."];
	      examples_enum [
		"Which Town that has country res:Germany has a populationTotal greater than 250000?";
		"Who is the successor of res:John_F._Kennedy?";
		"Who is the leader of res:Berlin?";
		"What is the numberOfStudents of res:Vrije_Universiteit?";
		"Which Mountain has the 2nd highest elevation?";
		"Give me all Person-s whose occupation is res:Skateboarding and whose (nationality or birthPlace) is res:Sweden.";
		"What is the dbp:admittancedate of res:Alberta?";
		"What is a dbp:country of res:Himalayas?";
		"Give me all Person-s whose instrument is res:Trumpet and whose occupation is res:Bandleader.";
		"What is the dbp:strength of res:New_York_City_Fire_Department?";
		"Which FormulaOneRacer has the highest races?";
		"Give me all WorldHeritageSite whose dbp:year is between 2008 and 2013.";
		"Which SoccerPlayer whose team has league res:Premier_League has the latest birthDate?";
		"Give me all bandMember-s of res:Prodigy.";
		"Which River has the highest dbp:length?";
		"Does the TelevisionShow that is a dbp:tv of res:Battlestar_Galactica and with the latest releaseDate have a greater numberOfEpisodes than the TelevisionShow that is a dbp:tv of res:Battlestar_Galactica and with the earliest releaseDate?";
		"Give me all Automobile-s whose assembly is res:Germany.";
		"";
		"Give me all Person-s whose birthPlace is res:Vienna and whose deathPlace is res:Berlin.";
		"What is the height of res:Michael_Jordan?";
		"What is the capital of res:Canada?";
		"Who is the dbp:governor of res:Wyoming?";
		"Does 'Prince Harry' have the same dbp:mother as 'Prince William'?";
		"Who is the dbp:father of res:Elizabeth_II?";
		"Which yago:StatesOfTheUnitedStates has the latest dbp:admittancedate?";
		"How many officialLanguage-s of res:Seychelles are there?";
		"res:Sean_Parnell is the dbp:governor of which yago:StatesOfTheUnitedStates?";
		"Give me all Film-s whose director is res:Francis_Ford_Coppola.";
		"Give me all Person-s that are a starring of a Film whose director and starring is res:William_Shatner.";
		"What is the dbp:birthName of res:Angela_Merkel?";
		"Give me all yago:CurrentNationalLeaders whose dbp:religion is res:Methodism.";
		"How many spouse-s of res:Nicole_Kidman are there?";
		"Give me all Organisation-s whose type is res:Nonprofit_organization and whose location is res:Australia.";
		"What are the battle-s of res:T._E._Lawrence?";
		"Who is the developer of res:Minecraft?";
		"";
		"";
		"What is the populationTotal of res:Maribor?";
		"Give me all Company-es whose location is res:Munich.";
		"List all Game-s whose publisher is 'GMT'.";
		"Whom does res:Intel be-foundedBy?";
		"Who is the dbp:spouse of res:Amanda_Palmer?";
		"Give me all dbp:breed of res:German_Shepherd.";
		"What are the city-es of res:Weser?";
		"What are the country-es of res:Rhine?";
		"Who has occupation res:Surfing and has birthPlace res:Philippines?";
		"";
		"Which Place-s whose country is res:United_Kingdom is the headquarter of res:Secret_Intelligence_Service?";
		"Which Weapon shares the dbp:designer with res:Uzi?";
		"Does res:Cuban_Missile_Crisis have an earlier date than res:Bay_of_Pigs_Invasion?";
		"Give me all yago:FrisianIslands whose country is res:Netherlands.";
		"";
		"What is the dbp:leaderParty of res:Lisbon?";
		"What are the dbp:nickname of res:San_Francisco?";
		"Which yago:GreekGoddesses have dbp:abode res:Mount_Olympus?";
		"Which ?date do res:Hells_Angels be-dbp:founded?";
		"Give me all Astronaut-s whose mission is res:Apollo_14.";
		"What is the dbp:timezone of res:Salt_Lake_City?";
		"Which yago:StatesOfTheUnitedStates share the dbp:timezone with res:Utah?";
		"Give me all Lake-s whose country is res:Denmark.";
		"How many SpaceMission-s are there?";
		"Does res:Aristotle be-influencedBy res:Socrates?";
		"Give me all Film-s whose country is res:Argentina.";
		"Give me all LaunchPad-s whose operator is res:NASA.";
		"What are the instrument-s of res:John_Lennon?";
		"What has dbp:shipNamesake res:Benjamin_Franklin?";
		"Who are the parent-s of the spouse of 'Juan Carlos I'?";
		"What is the numberOfEmployees of res:Google?";
		"Does 'Tesla' have award 'Nobel Prize Physics'?";
		"Is res:Michelle_Obama the spouse of res:Barack_Obama?";
		"What is the dbp:beginningDate of res:Statue_of_Liberty?";
		"Which yago:StatesOfTheUnitedStates is the dbp:location of res:Fort_Knox?";
		"res:Benjamin_Franklin has how many child-s?";
		"What is the deathDate of res:Michael_Jackson?";
		"Which yago:DaughtersOfBritishEarls have the same deathPlace as birthPlace?";
		"List the child-s of res:Margaret_Thatcher.";
		"Who has dbp:nickname res:Scarface?";
		"Does res:Margaret_Thatcher have profession res:Chemist?";
		"Does res:Dutch_Schultz have dbp:ethnicity 'Jewish'?";
		"Give me all Book-s whose author is res:William_Goldman and whose numberOfPages is greater than 300.";
		"Which Book-s have author res:Jack_Kerouac and have publisher res:Viking_Press?";
		"Give me all yago:AmericanInventions.";
		"What is the elevation of res:Mount_Everest?";
		"Who is the creator of res:Captain_America?";
		"What is the populationTotal of the capital of res:Australia?";
		"What is the largestCity of res:Australia?";
		"Who is the musicComposer of res:Harold_and_Maude?";
		"Which Film-s have starring and director res:Clint_Eastwood?";
		"Which Place is the restingPlace of 'Juliana Netherlands'?";
		"What is the dbp:residence of res:Prime_Minister_of_Spain?";
		"Which yago:StatesOfTheUnitedStates has dbp:postalabbreviation 'MN'?";
		"Give me all Song-s whose artist is res:Bruce_Springsteen and whose releaseDate has a year between 1980 and 1990.";
		"Which Film-s have director res:Akira_Kurosawa and have a later releaseDate than 'Rashomon'?";
		"What is the dbp:foundation of the dbp:brewery of res:Pilsner_Urquell?";
		"Who is the dbp:author of the anthem of res:Poland?";
		"Give me all dbp:bSide of the Album-s whose artist is res:Ramones.";
		"Who is the dbp:artist of res:The_Storm_on_the_Sea_of_Galilee?";
		"What is the nationality of the creator of res:Miffy?";
		"What is the recordLabel of the Album whose artist is res:Elvis_Presley and whose releaseDate is the earliest?";
		"Who has product res:Orangina?";
	      ];
	      
            ]))


(* ------------------------------------------------------------------ *)
(* Registration of services *)

let _ =
  Eliom_output.Html5.register main_service main_handler;
  Eliom_output.Html5.register translate_service translate_handler;
  Eliom_output.Html5.register query_form_service query_form_handler;
  Eliom_output.Redirection.register ~service:query_service query_handler;
  Eliom_output.Html5.register examples_service examples_handler


(* ------------------------------------------------------------------ *)
(* Catch some exceptions and output an error message instead of eg. the
   uninformative "error 500" page *)

let _ = Eliom_output.set_exn_handler
  (fun exn ->
    match exn with
      | Dcg.SyntaxError (line, column, msg) ->
        let get_params = Eliom_request_info.get_get_params () in
        let squall = List.assoc "squall" get_params in
        Eliom_output.Html5.send
          (html
             (head (title (pcdata "SQUALL to SPARQL Translator")) [webform_css])
             (body [menu;
                    h1 [pcdata "SQUALL to SPARQL Translator"];
                    h2 [pcdata "Syntax error"];
                    p [pcdata "The SQUALL expression you just entered is not syntactically correct."];
                    p [pcdata ("Error occured at line " ^ (string_of_int line) ^ ", ");
                       pcdata ("column " ^ string_of_int column);
                       pcdata " in the following expression:"];
                    div ~a:[a_id "faulty_squall"]
                      [pre [pcdata squall];
                       pre [pcdata ((String.make (column - 1) '-') ^ "^")]];
                    p [pcdata "The complete error message is: ";
                       pcdata msg];
                    p [pcdata "Please check against any typo and try again."];
                    translate_form
                   ]))
      | Failure msg ->
        let get_params = Eliom_request_info.get_get_params () in
        let squall = List.assoc "squall" get_params in
        Eliom_output.Html5.send
          (html
             (head (title (pcdata "SQUALL to SPARQL Translator")) [webform_css])
             (body [menu;
                    h1 [pcdata "SQUALL to SPARQL Translator"];
                    h2 [pcdata "Semantic error"];
                    p [pcdata "The SQUALL expression you just entered is not semantically correct."];
                    p [pcdata "Error occured in the following expression:"];
                    div ~a:[a_id "faulty_squall"]
                      [pre [pcdata squall]];
                    p [pcdata "The complete error message is: ";
                       pcdata msg];
                    p [pcdata "Please correct your sentence and try again."];
                    translate_form
                   ]))
      | Assert_failure _ ->
        let post_params = Eliom_request_info.get_all_post_params () in
        let squall = (match post_params with
          | Some params -> List.assoc "squall" params
          | _ -> "") in
        Eliom_output.Html5.send
          (html
             (head (title (pcdata "SQUALL to SPARQL Translator")) [webform_css])
             (body [menu;
                    h1 [pcdata "SQUALL to SPARQL Translator"];
                    h2 [pcdata "Broken assertion"];
                    p [pcdata "You ran into some corner case that shouldn't have happened. ";
                       pcdata "Please send the following information to ferre@irisa.fr:"];
                    p [pcdata ("The following SQUALL query: " ^ squall);
                       pcdata (" raised " ^ (Printexc.to_string exn))];
                    translate_form
                   ]))

      | _ -> Lwt.fail exn)
