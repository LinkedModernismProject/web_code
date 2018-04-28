
let namespaces =
  [ "dbo:", "http://dbpedia.org/ontology/";
    "dbp:", "http://dbpedia.org/property";
    "res:", "http://dbpedia.org/resource/";
    "yago:", ""; (* TODO *)
  ]

(* morphology *)

let ws = Syntax.ws
let kwd = Syntax.kwd
let kwds = Syntax.kwds

let noun_s root = dcg [ _ = kwd root; suf = match "s?" -> suf ]
let noun_es root = dcg [ _ = kwd root; suf = match "\\(es\\)?" -> suf ]
let noun_y_ies root = dcg [ _ = kwd root; suf = match "\\(y\\|ies\\)" -> suf ]

let adj_prep adj prep = dcg [ _ = kwd adj; _ = ws; _ = kwd prep -> () ]

let verb_s_ed root = dcg [ _ = kwd root; suf = match "\\(s\\|ed\\)?" -> suf ]
let verb_s_d root = dcg [ _ = kwd root; suf = match "\\(s\\|d\\)?" -> suf ]

let prefix lw p = dcg
  [ _ = kwds lw; _ = ws; s = p -> s ]

let prefix_opt lw p = dcg
  [ _ = kwds lw; _ = ws; s = p -> s
  | s = p -> s ]

let rec prefix_many llw p =
  match llw with
    | [] -> dcg [ s = p -> s ]
    | lw::llw1 -> dcg [ _ = kwds lw; _ = ws; s = prefix_many llw1 p -> s ]

let rec parse_proper_noun = dcg
    [ ws = parse_proper_noun_words 3 -> "res:" ^ String.concat "_" ws ]
and parse_proper_noun_words nmax = dcg
    [ w = parse_proper_noun_word;
      (  -> [w]
      | when "" nmax>1; _ = ws; ws = parse_proper_noun_words (nmax-1) -> w::ws ) ]
and parse_proper_noun_word = dcg
    [ @cursor; ?ctx;
      w = match "[A-Z][A-Za-z]*\\([-'._][A-Za-z0-9]+\\)*" as "proper noun word";
	when '("reserved keyword: " ^ w) not (ctx#is_kwd cursor#coord w) -> w
    | w = match "[A-Z][.]" as "initial" -> w ]

let re_underscore = Str.regexp_string "_"
let rec parse_common_noun_class = dcg
    [ ws = parse_common_noun_words 3 -> "dbo:" ^ String.concat "" (List.map String.capitalize ws) ]
and parse_common_noun_prop = dcg
    [ ws = parse_common_noun_words 2 ->
      ( match ws with
	| [] -> assert false
	| w::ws1 -> "dbo:" ^ w ^ String.concat "" (List.map String.capitalize ws1) ) ]
and parse_common_noun_words nmax = dcg
    [ ws1 = parse_common_noun_word;
      (  -> ws1
      | when "" nmax>1; _ = ws; ws2 = parse_common_noun_words (nmax-1) -> ws1 @ ws2 ) ]
and parse_common_noun_word = dcg
    [ @cursor; ?ctx;
      w = match "[A-Za-z][a-z]+\\(_[A-Za-z]+\\)*" as "common noun word";
	when '("reserved keyword: " ^ w) not (ctx#is_kwd cursor#coord w) -> Str.split re_underscore w ]

(* semantics *)

open Semantics

let bool1_type uri x = triple x (Uri "a") (Uri uri)
let bool1_has_object r uri x = r x (Uri uri)
let bool1_has_value r lit x = r x (Literal lit)
let bool1_has_some r x = exists (fun y -> r x y)

let bool2_prop uri x y = triple x (Uri uri) y
let bool2_prop_inv uri x y = triple y (Uri uri) x
let bool2_extends r1 r2 x y = bool2#or_ [r1; bool2#compose r1 r2] x y

let p2_location x y =
  bool2#or_
    [bool2_prop "dbo:location";
     bool2_prop "dbo:country";
     bool2_prop "dbo:locationCity";
     bool2_prop "dbo:locationCountry";
     bool2_prop "dbp:country";
     bool2_prop "dbo:headquarter"]
    x y

let p2_country x y =
  bool2#or_
    [bool2_prop "dbo:locationCountry";
     bool2_prop "dbp:country";
     bool2#compose (bool2_prop "dbo:location") (bool2_prop "dbo:country")]
    x y

let p2_birthPlace x y = bool2_extends (bool2_prop "dbo:birthPlace") p2_location x y
let p2_deathPlace x y = bool2_extends (bool2_prop "dbo:deathPlace") p2_location x y
let p2_restingPlace x y = bool2_extends (bool2_prop "dbo:restingPlace") p2_location x y

let p2_releaseDate x y =
  bool2#or_
    [bool2_prop "dbo:releaseDate";
     bool2_prop "dbp:released"]
    x y

let p2_date x y =
  bool2#or_
    [bool2_prop "dbo:date";
     bool2_prop "dbp:year";
     p2_releaseDate]
    x y

let p2_artist x y =
  bool2#or_
    [bool2_prop "dbo:artist";
     bool2_prop "dbo:musicalArtist";
     bool2_prop "dbp:artist"]
    x y

let p2_from x y =
  bool2_prop "dbo:origin"
    x y


(* lexicon *)

class ['s1,'p1,'p2,'p2_measure,'str,'p] context =
  object (self)
    inherit ['s1,'p1,'p2,'p2_measure,'str,'p] Sparql.context as super

    method parse_e_np = dcg
      [ _ = kwd "the"; _ = ws; uri = parse_proper_noun -> Uri uri
      | uri = parse_proper_noun -> Uri uri
      | t = super#parse_e_np -> t ]

    method parse_p1_noun = dcg
      [ _ = noun_s "town" -> bool1_type "dbo:Town"
      | _ = noun_y_ies "cit" -> bool1_type "dbo:Town"
      | _ = noun_s "place" -> bool1_type "dbo:Place"
      | _ = noun_s "lake" -> bool1_type "dbo:Lake"
      | _ = noun_s "mountain" -> bool1_type "dbo:Mountain"
      | _ = prefix_opt ["professional"] (noun_s "skateboarder") -> bool1_has_object (bool2_prop "dbo:occupation") "res:Skateboarding"
      | _ = prefix_opt ["professional"] (noun_s "surfer") -> bool1_has_object (bool2_prop "dbo:occupation") "res:Surfing"
      | _ = noun_s "bandleader" -> bool1_has_object (bool2_prop "dbo:occupation") "res:Bandleader"
      | _ = noun_s "chemist" -> bool1_has_object (bool2_prop "dbo:profession") "dbo:Chemist"
      | _ = noun_s "jew" -> bool1_has_value (bool2_prop "dbp:ethnicity") "\"Jewish\"@en"
      | _ = noun_s "car" -> bool1_type "dbo:Automobile"
      | _ = kwds ["person"; "persons"; "people"] -> bool1_type "dbo:Person"
      | _ = noun_s "film" -> bool1_type "dbo:Film"
      | _ = noun_s "movie" -> bool1_type "dbo:Film"
      | _ = noun_s "U.S. state" -> bool1_type "yago:StatesOfTheUnitedStates"
      | _ = noun_y_ies "compan" -> bool1_type "dbo:Company"
      | _ = noun_s "game" -> bool1_type "dbo:Game"
      | _ = noun_s "weapon" -> bool1_type "dbo:Weapon"
      | _ = noun_s "book" -> bool1_type "dbo:Book"
      | _ = noun_s "song" -> bool1_type "dbo:Song"
      | _ = noun_s "album" -> bool1_type "dbo:Album"
      | _ = prefix ["space"] (noun_s "mission") -> bool1_type "dbo:SpaceMission"
      | _ = prefix ["launch"] (noun_s "pad") -> bool1_type "dbo:LaunchPad"
      | _ = prefix ["nonprofit"] (noun_s "organization") -> bool1_has_object (bool2_prop "dbo:type") "res:Nonprofit_organization"
      | _ = prefix ["Greek"] (noun_es "goddess") -> bool1_type "yago:GreekGoddesses"
      | _ = prefix ["American"] (noun_s "invention") -> bool1_type "yago:AmericanInventions"
      | _ = prefix ["Frisian"] (noun_s "island") -> bool1_type "yago:FrisianIslands"
      | _ = prefix_many [["current"]; ["national"]] (noun_s "leader") -> bool1_type "yago:CurrentNationalLeaders"
      | _ = prefix_many [["Formula"]; ["1"]; ["race"]] (noun_s "driver") -> bool1_type "dbo:FormulaOneRacer"
      | _ = prefix_many [["world"]; ["heritage"]] (noun_s "site") -> bool1_type "dbo:WorldHeritageSite"
      | uri = parse_proper_noun; _ = ws;
	  ( _ = noun_s "player" -> bool1_has_object (bool2_prop "dbo:instrument") uri
	  | _ = noun_s "astronaut" -> bool1#and_ [bool1_type "dbo:Astronaut"; bool1_has_object (bool2_prop "dbo:mission") uri]
          | _ = kwd "series" -> bool1#and_ [bool1_type "dbo:TelevisionShow"; bool1_has_object (bool2_prop "dbp:tv") uri] )
      | uri = parse_common_noun_class -> bool1_type uri
      | p1 = super#parse_p1_noun -> p1 ]
    method parse_p1_adj = dcg
      [ _ = kwd "German" -> bool1_has_object p2_country "res:Germany"
      | _ = kwds ["UK"; "British"] -> bool1_has_object p2_country "res:United_Kingdom"
      | _ = kwds ["Danish"] -> bool1_has_object p2_country "res:Denmark"
      | _ = kwds ["Argentine"] -> bool1_has_object p2_country "res:Argentina"
      | _ = kwds ["Australian"] -> bool1_has_object p2_country "res:Australia"
      | _ = kwd "Methodist" -> bool1_has_object (bool2_prop "dbp:religion") "res:Methodism"
      | _ = kwd "dead" -> bool1_has_some (bool2_prop "dbo:deathDate")
      | _ = kwd "alive" -> bool1#not_ (bool1_has_some (bool2_prop "dbo:deathDate"))
      | p1 = super#parse_p1_adj -> p1 ]

    method parse_p2_noun = dcg
      [ _ = noun_s "date" -> p2_date
      | _ = noun_s "mayor" -> bool2_prop "dbo:leader"
      | _ = noun_s "origin" -> bool2#or_ [p2_birthPlace; bool2_prop "dbo:nationality"]
      | _ = noun_y_ies "countr" -> p2_country
      | _ = noun_s "player" -> bool2_prop_inv "dbo:instrument"
      | _ = noun_s "member" -> bool2_prop "dbo:bandMember" (* or ... *)
      | _ = noun_s "governor" -> bool2_prop "dbp:governor"
      | _ = noun_s "parent" -> bool2_prop "dbo:parent"
      | _ = kwds ["child"; "children"] -> bool2_prop "dbo:child"
      | _ = noun_s "mother" -> bool2_prop "dbp:mother"
      | _ = noun_s "father" -> bool2_prop "dbp:father"
      | _ = noun_s "spouse" -> bool2_prop "dbo:spouse"
      | _ = kwds ["wife"; "wives"] -> bool2_prop "dbo:spouse"
      | _ = noun_s "husband" -> bool2_prop "dbo:spouse"
      | _ = kwd "series" -> bool2_prop "dbp:tv"
      | _ = noun_s "breed" -> bool2_prop_inv "dbp:breed"
      | _ = noun_y_ies "cit" -> bool2_prop "dbo:city"
      | _ = noun_s "residence" -> bool2_prop "dbp:residence"
      | _ = noun_s "designer" -> bool2_prop "dbp:designer"
      | _ = noun_s "artist" -> p2_artist
      | _ = kwds ["ruling"; "leader"]; _ = ws; _ = noun_y_ies "part" -> bool2_prop "dbp:leaderParty"
      | _ = noun_s "nickname" -> bool2_prop "dbp:nickname"
      | _ = noun_s "B-side" -> bool2_prop "dbp:bSide"
      | _ = noun_s "battle" -> bool2_prop "dbo:battle"
      | _ = noun_s "strength" -> bool2_prop "dbp:strength"
      | _ = prefix ["admittance"] (noun_s "date") -> bool2_prop "dbp:admittancedate"
      | _ = prefix ["official"] (noun_s "language") -> bool2_prop "dbo:officialLanguage"
      | _ = prefix ["ship"] (noun_s "namesake") -> bool2_prop "dbp:shipNamesake"
      | _ = prefix ["foundation"; "founding"; "beginning"] (dcg [ s = noun_s "date" -> s | s = noun_s "year" -> s ]) ->
        bool2#or_ [bool2_prop "dbp:founded";
		   bool2_prop "dbp:foundation";
		   bool2_prop "dbp:beginningDate"]
      | _ = prefix ["time"] (noun_s "zone") -> bool2_prop "dbp:timezone"
      | _ = noun_s "abbreviation" -> bool2_prop "dbp:postalabbreviation"
      | _ = prefix ["release"] (noun_s "date") -> p2_releaseDate
      | _ = prefix ["birth"] (noun_s "place") -> p2_birthPlace
      | _ = prefix ["birth"] (noun_s "name") -> bool2_prop "dbp:birthName"
      | _ = noun_y_ies "brewer" -> bool2_prop "dbp:brewery"
      | uri = parse_common_noun_prop -> bool2_prop uri
      | p2 = super#parse_p2_noun -> p2 ]
    method parse_p2_count_noun = dcg
      [ _ = noun_s "inhabitant" -> bool2_prop "dbo:populationTotal"
      | _ = kwd "people" -> bool2_prop "dbo:populationTotal"
      | _ = noun_s "student" -> bool2_prop "dbo:numberOfStudents"
      | _ = noun_s "page" -> bool2_prop "dbo:numberOfPages"
      | _ = noun_s "episode" -> bool2_prop "dbo:numberOfEpisodes"
      | _ = noun_s "employee" -> bool2_prop "dbo:numberOfEmployees"
      | _ = noun_s "race" -> bool2_prop "dbo:races" ]
    method parse_p2_adj = dcg
      [ _ = adj_prep "produced" "in" -> bool2_prop "dbo:assembly"
      | _ = adj_prep "born" "in" -> p2_birthPlace
      | _ = adj_prep "buried" "in" -> p2_restingPlace
      | _ = adj_prep "directed" "by" -> bool2_prop "dbo:director"
      | _ = adj_prep "playing" "in" -> bool2_prop "dbo:league"
      | _ = adj_prep "starring" "in" -> bool2_prop_inv "dbo:starring"
      | _ = kwd "starring" -> bool2_prop "dbo:starring"
      | _ = adj_prep "located" "in" -> p2_location
      | _ = adj_prep "published" "by" -> bool2_prop "dbo:publisher"
      | _ = adj_prep "authored" "by" -> bool2_prop "dbo:author"
      | _ = adj_prep "written" "by" -> bool2_prop "dbo:author"
      | _ = adj_prep "recorded" "by" -> p2_artist
      | _ = adj_prep "founded" "by" -> bool2_prop "dbo:foundedBy"
      | _ = adj_prep "influenced" "by" -> bool2_prop "dbo:influencedBy"
      | _ = adj_prep "operated" "by" -> bool2_prop "dbo:operator"
      | _ = kwd "called" -> bool2_prop "dbp:nickname"
      | p2 = super#parse_p2_adj -> p2 ]
    method parse_p2_adj_measure = dcg
      [ _ = kwd "young" -> pol_positive, bool2_prop "dbo:birthDate"
      | _ = kwd "old" -> pol_negative, bool2_prop "dbo:birthDate"
      | _ = kwd "new" -> pol_positive, p2_releaseDate
      | _ = kwd "old" -> pol_negative, p2_releaseDate
      | _ = kwd "tall" -> pol_positive, bool2_prop "dbo:height"
      | _ = kwd "small" -> pol_negative, bool2_prop "dbo:height"
      | _ = kwd "high" -> pol_positive, bool2_prop "dbo:elevation"
      | _ = kwd "low" -> pol_negative, bool2_prop "dbo:elevation"
      | _ = kwd "long" -> pol_positive, bool2_prop "dbp:length"
      | _ = kwd "short" -> pol_negative, bool2_prop "dbp:length" ]
    method parse_p2_adj_comparative = dcg
      [ _ = kwd "younger" -> pol_positive, bool2_prop "dbo:birthDate"
      | _ = kwd "older" -> pol_negative, bool2_prop "dbo:birthDate"
      | _ = kwd "newer" -> pol_positive, p2_releaseDate
      | _ = kwd "older" -> pol_negative, p2_releaseDate
      | _ = kwd "taller" -> pol_positive, bool2_prop "dbo:height"
      | _ = kwd "smaller" -> pol_negative, bool2_prop "dbo:height"
      | _ = kwd "longer" -> pol_positive, bool2_prop "dbp:length"
      | _ = kwd "shorter" -> pol_negative, bool2_prop "dbp:length"
      | _ = kwd "earlier" -> pol_positive, p2_date
      | _ = kwd "later" -> pol_negative, p2_date ]
    method parse_p2_adj_superlative = dcg
      [ _ = kwd "youngest" -> pol_positive, bool2_prop "dbo:birthDate" (* should compute age *)
      | _ = kwd "newest" -> pol_positive, p2_releaseDate
      | _ = kwd "oldest" ->
	pol_negative,
	bool2#or_ [bool2_prop "dbo:birthdate";
		   p2_releaseDate]
      | _ = kwd "tallest" -> pol_positive, bool2_prop "dbo:height"
      | _ = kwd "smallest" -> pol_negative, bool2_prop "dbo:height"
      | _ = kwd "highest" -> pol_positive, bool2_prop "dbo:elevation"
      | _ = kwd "lowest" -> pol_positive, bool2_prop "dbo:elevation"
      | _ = kwd "longest" -> pol_positive, bool2_prop "dbp:length"
      | _ = kwd "shortest" -> pol_negative, bool2_prop "dbp:length"
      | _ = kwd "earliest" -> pol_positive, p2_date
      | _ = kwd "latest" -> pol_negative, p2_date ]
    method parse_p2_verb = dcg
      [ _ = verb_s_ed "play" -> bool2_prop "dbo:instrument"
      | _ = verb_s_d "die"; _ = ws; _ = kwd "in" -> p2_deathPlace
      | _ = verb_s_ed "develop" -> bool2_prop_inv "dbo:developer"
      | _ = verb_s_ed "found" -> bool2_prop_inv "dbo:foundedBy"
      | _ = kwds ["dwelt"]; _ = ws; _ = kwd "on" -> bool2_prop "dbp:abode"
      | _ = verb_s_d "influence" -> bool2_prop_inv "dbo:influencedBy"
      | _ = kwds ["wins"; "win"; "won"] -> bool2_prop "dbo:award"
      | _ = verb_s_ed "direct" -> bool2_prop_inv "dbo:director"
      | _ = verb_s_d "create" -> bool2_prop_inv "dbo:creator"
      | _ = kwds ["writes"; "write"; "wrote"] -> bool2_prop_inv "dbo:author"
      | _ = verb_s_d "produce" -> bool2_prop "dbo:product"
      | _ = verb_s_ed "paint" -> bool2_prop_inv "dbo:artist"
      | p2 = super#parse_p2_verb -> p2 ]
  end
