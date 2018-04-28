function inArr(str, strArray) {
	for(var i=0;i<strArray.length;i++) {
		if(strArray[i].match(str)) return true;
	}
	return false;
}
function isEmpty (val_arr, total, data_arr) {
	data_arr[0] = {subj: val_arr[0] ,pred_obj: [[val_arr[1], val_arr[2]]]};	//pred_obj = 2D arr
	console.log(data_arr);
	//console.log((val_arr[0]));
	//console.log((val_arr[2]));
}

function compare_subjects (val_arr, data_arr, val_i) {
	console.log(data_arr.length);
	for (var i = 0; i < data_arr.length; i++) {
		console.log(val_arr[val_i]);
		console.log(data_arr[i].subj);
		if(val_arr[val_i]==data_arr[i].subj) {
			return [true, i];
		}
	}
	return [false, 'No existing subj index:'+i.toString()];
}

function compare_preds (val_arr, data_arr, val_i, comp_subj_index) {	//May be able to just compare against the index that matches the subj (i.e. parent)
	//console.log(data_arr);
	console.log(val_arr);
	console.log((data_arr.length));
	//for (var i = 0; i < data_arr.length; i++) {
	//	console.log((data_arr[i]));
	//	console.log((i));
		////console.log(data_arr[i].pred_obj[i][0]);
		//Adding inner for for the pred_obj length so it doesn't mess with the other loops
		//console.log(data_arr[i].pred_obj.length);
		console.log(data_arr[comp_subj_index].pred_obj.length);
		for (var j = 0; j < data_arr[comp_subj_index].pred_obj.length; j++) {
			console.log(j);
			console.log(data_arr[comp_subj_index].pred_obj[j][0]);
			if(val_arr[val_i]==data_arr[comp_subj_index].pred_obj[j][0]) {
				return [true, comp_subj_index];
			}
 		};

		//if(val_arr[val_i]==data_arr[i].pred_obj[i][0]) {
		//	return [true, i];
		//}
	//}
	return [false, 'No existing subj index:'+comp_subj_index.toString()];
}

function isA_spo (val_arr, total, data_arr) {
	if(data_arr.length==0){
		console.log("in empty");
		isEmpty(val_arr, total, data_arr);
	} else {
		console.log("inElse is spo");
		/*if(data_arr.length==2) {
			console.log(data_arr);
			exit();
		}*/
		//Could fix this vars into arrays so would only compute once instead of twice
		comp_subj_bool = compare_subjects(val_arr, data_arr, 0)[0];
		console.log(comp_subj_bool);
		comp_subj_index = compare_subjects(val_arr, data_arr, 0)[1];
		console.log(comp_subj_index);
		//if(data_arr.length==2) {
		//	console.log(data_arr);
		//	exit();
		//}
		if(comp_subj_bool) {
			comp_pred_bool = compare_preds(val_arr, data_arr, 1, comp_subj_index)[0];
			console.log(comp_pred_bool);
			comp_pred_index = compare_preds(val_arr, data_arr, 1, comp_subj_index)[1];
			console.log(comp_pred_index);
		}
		//if(data_arr.length==2) {
		//	console.log(data_arr);
		//	exit();
		//}
		//Isssue: 1) Where subj and pred are true. 2) However what if they are from different elements. Come up with a way to condition if(pred's are the same) then check and if not in then continue. Maybe send the index into the compare_preds, or the bool possibly.
		if(comp_subj_bool) {	//Subjects are the same, check for same pred
			console.log("subj_bool:true");
			if(comp_pred_bool) {	//Same preds, adding obj that corresponds
				console.log("pred_bool:true");
				data_arr[comp_subj_index].pred_obj[comp_pred_index][data_arr[comp_pred_index].pred_obj[comp_pred_index].length] = val_arr[2];
			} else {	//Diff preds
				//if(data_arr[1].pred_obj.length==2) {
					console.log(("diff preds"+comp_subj_index));
					data_arr[comp_subj_index].pred_obj.push([val_arr[1], val_arr[2]]);
					console.log(data_arr);
					//exit();
			}
		} else {	//Subjects are different, thus no need to check for same pred
			console.log('diff subj');
			console.log(val_arr[0]+'???'+val_arr[1]+'???'+val_arr[2]);
			data_arr.push({subj: val_arr[0], pred_obj: [[val_arr[1], val_arr[2]]]});
			console.log(data_arr);
		}
	}
}
function isA_po (val_arr, total, data_arr) {
	console.log("in inA_po");
	if(data_arr.length==0){
		isEmpty(val_arr, total, data_arr);
	}
}
function isA_o (val_arr, total, data_arr) {
	console.log("in isA_o");
	if(data_arr.length==0){
		isEmpty(val_arr, total, data_arr);
	}
}

//Grab values and place them into corresponding array or object unless duplicate then try add to another obj.
function grabValues (line, total, data_arr) {
	//console.log(data_arr);
	var values = line.match(/(value":.*?)\s\}/g);
	//console.log(values);
	for (var i = 0; i < total; i++) {
		values[i] = values[i].replace(/value\"\:[\s+]/, '');
		//console.log(values);
		values[i] = values[i].replace(/[\s+]\}/, '');
		//console.log(values);
		var val_split = values[i].split('/');
		//console.log(val_split);
		val_split = val_split[val_split.length-1];
		console.log(val_split);
		if(val_split.indexOf('#') != -1) {	//If there is a hash get the value part
			var hash = val_split.split('#');
			val_split = hash[1];
		}
		
		////if(val_split[0]=='"' && val_split[val_split.length-1]=='"') {
		////	console.log('had quote in front');
		////	val_split.slice(1, val_split.length) = '';
		////} else {
		////	console.log('doesnt yet');
		//val_split.replace('"','');
		//val_split = '"'+val_split;
		console.log(val_split);
		val_split = val_split.replace(/\"*(.*?)\"*/g, '$1');
		val_split = val_split.replace(/\\*(.*?)\\*/g, '$1');
		console.log(val_split);
		val_split = '"'+val_split+'"';
		console.log(val_split);

		//var v = val_split.replace('"',"'");
		//console.log(v);
		//TEST//if(val_split=="\"1831-1840\"") {
		//TEST//	exit();
		//TEST//}

		/////val_split = '"' + val_split;
		//}
		
		console.log(val_split);
		//console.log(total);
		//console.log(data_arr);
		values[i] = val_split;
	};
	console.log(values);

	if(total==1) {
		isA_o(values, total, data_arr);
	} else if(total==2) {
		isA_po(values, total, data_arr);
	} else {
		console.log("going into isAspo");
			//console.log(values' || '+total);
			//console.log(data_arr);
			//exit();
		isA_spo(values, total, data_arr);
	}
}

//Converting the JSON data to FlareJSON
function toFlare(data_arr, s, p, o, total) {
	var name = '"name": ';
	var child = '"children": ';
	var size = '"size": ';
	var defaultsize = 500;
	var emptySubj = false;
	var emptyPred = false;
	var newJson = '{\n\t';
	//To determine the root node(i.e. The query)
	if(total==1) {
		var query = '"'+o+'"';
	} else if(total==2) {
		var query = '"'+p+', '+o+'"';
	} else {
		var query = '"'+s+', '+p+', '+o+'"';
	}
	newJson += name+query+',\n\t'+child+'[{';	//#

	for (var i = 0; i < data_arr.length; i++) {
		if(data_arr[i].hasOwnProperty('subj')) {
			//Deal with next subj case
			if(emptySubj) {
				newJson += '\n\t\t}]\n\t}, {'
				emptySubj = false;
			} else if(i>0) {	//Going onto another subjects; reset cursor
				newJson += ']\n\t\t}]\n\t}, {'	//@
			}
			newJson += '\n\t\t'+name+data_arr[i].subj+',\n\t\t'+child+'[{';	//$
			if(data_arr[i].hasOwnProperty('pred_obj')) {
				for (var j = 0; j < data_arr[i].pred_obj.length; j++) {
					if(0 < data_arr[i].pred_obj[j].length) {	//Tests to see if there are any preds/objects in the 2D arrays (if they are empty)
						if(emptyPred==true) {
							newJson += ', {';	//`
							emptyPred = false;	//CURR
						} else if(j>0) {	//If there is another pred
							newJson += ']\n\t\t}, {';	//*
						}
						for (var k = 0; k < data_arr[i].pred_obj[j].length; k++) {
							//Check for if there is obj's and not just pred's
							if(1 < data_arr[i].pred_obj[j].length) {	//If there is more than just pred
								if(k>1) {	//If there is more than one pred
									newJson += ', {';	//&
								}
								if(k==0) {	//Puts the pred in
									newJson += '\n\t\t\t'+name+data_arr[i].pred_obj[j][k]+',\n\t\t\t'+child+'[{';	//%
								} else {//For the obj's (if it is after the pred)
									//Using defaultsize* the array length for average size
									newJson += '\n\t\t\t\t'+name+data_arr[i].pred_obj[j][k]+',\n\t\t\t\t'+size+(defaultsize*data_arr[i].pred_obj[j].length)+'\n\t\t\t}';	//^
								}
							} else {
								//Case where there is only a pred and no obj's
								newJson += '\n\t\t\t'+name+data_arr[i].pred_obj[j][k]+',\n\t\t\t'+size+(defaultsize*data_arr[i].pred_obj[j].length)+'\n\t\t}'	//!
								emptyPred = true;
							}
						}//End of obj FOR
					} else {//else case for if 0 !< data.length; only subjects
						emptySubj = true;
					}
				}
			}//End of if pred
		}
	}//End of FOR for all converting
	//Determine if the ending was of obj's or pred's
	if(emptySubj) {
		newJson += '\n\t\t}]\n\t}]\n}';
	} else if(emptyPred) {
		newJson += ']\n\t}]\n}';
	} else {
		newJson += ']\n\t\t}]\n\t}]\n}';
	}

	return newJson;
}//End of toFlare

function convert(json) {
	arrayOfLines = json.match(/[^\r\n]+/g);	//Puts json into lines of strings
	var s = '';
	var p = '';
	var o = '';
	var totVars = 0;	//Used to keep track of total vars in query
	var sub = 'testing';
	var data_arr = [];	//Array for full data
	//TESTS BELOW
	//////////data_arr[0] = {subj: sub, pred_obj: [[]]}
	////////////Use pred_obj because will be able to keep track of connecting data between the same /////pred and objects
	//////////console.log(data_arr[0].subj);	//To access a data_arr subject
	//////////console.log(data_arr[0].hasOwnProperty('pred_obj'));
	//////////var a = "nothng";
	//////////var b = "nothngb";
	//////////if(data_arr[0].pred_obj.length>0){a = 'something'}	//There is an array in the  pred_obj /////array
	//////////if(data_arr[0].pred_obj[0].length>0){b = 'somethingb'} //This is an item in the array /////inside
	//////////console.log(a);
	//////////console.log(b);
	//////////exit();
	//END OF TESTS


	for(var a=0; a<arrayOfLines.length;a++){
		//First line: need spo's
		if (a==0) {
			//var re = /\[([^\]]+)\]/;
			//var extract = re.exec(arrayOfLines[a]);
			//Other way to get object into lines is shorter and more efficient
			try {	//Incase invalid input
				var extrac = arrayOfLines[a].match(/\[([^\]]+)\]/);		//"s", "p", "o"     type:obj
				var s_p_o = extrac[1].replace(/\"/g,'');	//s, p, o
				var s_p_o = s_p_o.replace(/\s+/g, '');
				var s_p_o_Arr =  s_p_o.split(',');			//3
			}
			catch(err) {
				console.log/*alert*/("Error with parsing JSON file:"+ err.message);
			}
			totVars = s_p_o_Arr.length;
			if(s_p_o_Arr.length==1){
				o = s_p_o_Arr[0];
			} else if(s_p_o_Arr.length==2){
				p = s_p_o_Arr[0]
				o = s_p_o_Arr[1];
			} else if (s_p_o_Arr.length==3){
				s = s_p_o_Arr[0];
				p = s_p_o_Arr[1];
				o = s_p_o_Arr[2];
			}
		//Second line: uneeded data
		} else if(a==1) {//End of if a==0
			continue;	//For the distinct and ordered settings; no data
		//Lines after: All the data
		} else {
			//console.log(arrayOfLines[a]+' | '+totVars+ ' | '+data_arr);
			if(a==10) {	//a is one ahead of what is being tested
				console.log(data_arr);
				//exit();
			} else if(a==9) {
					console.log('A==9');
					console.log(data_arr);
					//exit();
			} else {
				console.log(data_arr);
			}
			grabValues(arrayOfLines[a], totVars, data_arr);
		}
	}//End of for loop through arrayOfLines
	
	var flare = toFlare(data_arr, s, p, o, totVars);
	console.log(flare);
	return flare;
}//End of convert()
