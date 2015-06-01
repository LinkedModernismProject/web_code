function inArr(str, strArray) {
	for(var i=0;i<strArray.length;i++) {
		if(strArray[i].match(str)) return true;
	}
	return false;
}
function isEmpty (val_arr, total, data_arr) {
	//data_arr[0] = {subj: val_arr[0], pred_obj: []}
	data_arr[0] = {subj: val_arr[0] ,pred_obj: [[val_arr[1], val_arr[2]]]};	//pred_obj = 2D arr
	console.log('INisEmpty');
	console.log(data_arr[0]);
	console.log(data_arr[0].pred_obj);
	console.log(data_arr[0].pred_obj[0][0]);
	console.log(data_arr[0].pred_obj[0][1]);
}

function compare_subjects (val_arr, data_arr, val_i, s_p) {
	for (var i = 0; i < data_arr.length; i++) {
		console.log(data_arr[i].s_p);
		console.log(val_arr[val_i]);
		if(val_arr[val_i]==data_arr[i].s_p) {
			return [true, i];
		}
	}
	return [false, 'No existing subj index:'+i.toString()];
}

function compare_subjects2 (val_arr, data_arr, val_i) {	//May be able to just compare against the index that matches the subj (i.e. parent)
	for (var i = 0; i < data_arr.length; i++) {
		console.log(data_arr[i].pred_obj[i][0]);
		console.log(val_arr[val_i]);
		if(val_arr[val_i]==data_arr[i].pred_obj[i][0]) {
			return [true, i];
		}
	}
	return [false, 'No existing subj index:'+i.toString()];
}

function isA_spo (val_arr, total, data_arr) {
	if(data_arr.length==0){
		isEmpty(val_arr, total, data_arr);
	} else {
		comp_subj_bool = compare_subjects(val_arr, data_arr, 0, "subj")[0];
		comp_subj_index = compare_subjects(val_arr, data_arr, 0, "subj")[1];
		comp_pred_bool = compare_subjects2(val_arr, data_arr, 1)[0];//, "pred_obj[i][0]")[0];
		comp_pred_index = compare_subjects2(val_arr, data_arr, 1)[1];//, "pred_obj[i][0]")[1]
		console.log("the length is:"+data_arr.length.toString());
		if(comp_subj_bool) {
			console.log("IN SPO:");
			console.log(comp_subj_index);
			exit();
		} else {	//Subjects are different
			console.log("IN SPO2:"+comp_subj_bool.toString());
			console.log(comp_subj_index);
			console.log(comp_pred_bool);
			console.log(comp_pred_index);
			data_arr.push({subj: val_arr[0], pred_obj: [[val_arr[1], val_arr[2]]]});

			for (var i = 0; i < data_arr.length; i++) {
				console.log('IN_FOR');
				console.log(data_arr[i]);
				console.log(data_arr[i].pred_obj);
				console.log(data_arr[i].pred_obj[0]);
				console.log(data_arr[i].pred_obj[1]);
				console.log(typeof(data_arr[i].pred_obj[0]));
				console.log(typeof(data_arr[i].pred_obj));
				console.log((data_arr[i].pred_obj)[i][0]);	//WON'T ACCEPT AS ARRAY
				console.log(data_arr[i].pred_obj[i][1]);
				console.log(data_arr[i].pred_obj[i][2]);
				console.log(data_arr[i].pred_obj[i][3]);
			};



			//exit();
			//if(compare_subjects(val_arr, data_arr, 1, "pred[i][0]")[0]) {
				//For the pred value comparision HERE

			//}

		}
		
		//data_arr.push({subj: val_arr[0], pred_obj: [[val_arr[1], val_arr[2]]]});
		
	}
}
function isA_po (val_arr, total, data_arr) {
	if(data_arr.length==0){
		isEmpty(val_arr, total, data_arr);
	}
}
function isA_o (val_arr, total, data_arr) {
	if(data_arr.length==0){
		isEmpty(val_arr, total, data_arr);
	}
}

//Grab values and place them into corresponding array or object unless duplicate then try add to another obj.
function grabValues (line, total, data_arr) {
	//var values = line.match(/value": (.*)\s([^\}]+)\}/g);
	var values = line.match(/(value":.*?)\s\}/g);  // /\s([^\}]+)\}/g);
	console.log("total= "+total.toString());
	for (var i = 0; i < total; i++) {
		values[i] = values[i].replace(/value\"\:[\s+]/, '');	//Works now //(/[^\"]*?/ig, '');
		values[i] = values[i].replace(/[\s+]\}/, '');
	};
	console.log(values);
	console.log(values[0]);	//"http://www.openlinksw.com/virtrdf-data-formats#default-iid"
	console.log(values[1]);
	console.log(values[2]);	//"http://www.openlinksw.com/schemas/virtrdf#QuadMapFormat"
	if(total==1) {
		isA_o(values, total, data_arr);
	} else if(total==2) {
		isA_po(values, total, data_arr);
	} else {
		isA_spo(values, total, data_arr);
	}



	console.log('HELLLLOOOOOOO');

}
function convert(json) {
	console.log('HELLLLOOOOOOO');
	console.log(typeof(json));
	newJson = '{\n\t';
	arrayOfLines = json.match(/[^\r\n]+/g);	//Puts json into lines of strings
	var s = '';
	var p = '';
	var o = '';
	var totVars = 0;	//Used to keep track of total vars in query
	var sub = 'testing';
	var pre = [''];
	var obj = [];
	var spo_object = {	//Might not need
		subject: sub,
		predicate: pre,
		object: obj
	}
	var data_arr = [];	//data_arr[0] = new Object();
	//data_arr[0] = {subj: sub, predy: pred, ob: obj}
	//Use pred_obj because will be able to keep track of connecting data between the same pred and objects

	
	//Get array index value		console.log(spo.subject[1]);
	//Add to array				spo.subject.push('kiwi');
	//Print whole array			console.log(spo.subject);

	console.log(arrayOfLines);
	console.log(typeof(arrayOfLines));
	console.log(typeof(arrayOfLines[0]))


	for(var a=0; a<arrayOfLines.length;a++){
		//First line: need spo's
		if (a==0) {
			//var re = /\[([^\]]+)\]/;	Other way to get object into lines is shorter and more efficient
			//var extract = re.exec(arrayOfLines[a]);
			try {	//Incase invalid input
				var extrac = arrayOfLines[a].match(/\[([^\]]+)\]/);		//"s", "p", "o"     type:obj
				console.log(extrac);
				var s_p_o = extrac[1].replace(/\"/g,'');	//s, p, o
				var s_p_o = s_p_o.replace(/\s+/g, '');
				var s_p_o_Arr =  s_p_o.split(',');			//3
			}
			catch(err) {
				alert("Error with parsing JSON file:"+ err.message);
			}
			console.log(s_p_o_Arr);
			console.log(s_p_o);
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
			console.log(s);
			console.log(p);
			console.log(o);
		//Second line: uneeded data
		} else if(a==1) {//End of if a==0
			continue;	//For the distinct and ordered settings; no data
		//Lines after: All the data
		} else {
			grabValues(arrayOfLines[a], totVars, data_arr);

		}
		//console.log(arrayOfLines[a]);
	}//End of for loop through arrayOfLines

//"s", "p", "o"

//var textArea = document.getElementById("my-text-area");
//var arrayOfLines = textArea.value.split("\n"); // 
	//console.log(json)
	return 'HELLLLOOOOOOO'
}//End of convert()
