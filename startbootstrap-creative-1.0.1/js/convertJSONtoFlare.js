function inArr(str, strArray) {
	for(var i=0;i<strArray.length;i++) {
		if(strArray[i].match(str)) return true;
	}
	return false;
}
function convert(json) {
	console.log('HELLLLOOOOOOO')
	console.log(typeof(json))
	newJson = '{\n\t'
	arrayOfLines = json.match(/[^\r\n]+/g);	//Puts json into lines of strings
	var s = '';
	var p = '';
	var o = '';
	var totVars = 0;	//Used to keep track of total vars in query
	var sub = 'test';
	var pred = [''];
	var obj = [];
	var spo_object = {	//Might not need
		subject: sub,
		predicate: pred,
		object: obj
	}
	var data_arr = [];
	//data_arr[0] = new Object();
	
	//Get array index value		console.log(spo.subject[1]);
	//Add to array				spo.subject.push('kiwi');
	//Print whole array			console.log(spo.subject);

	console.log(arrayOfLines);
	console.log(typeof(arrayOfLines));
	console.log(typeof(arrayOfLines[0]))


	for(var a=0; a<arrayOfLines.length;a++){
		if (a==0) {
			//var re = /\[([^\]]+)\]/;	Other way to get object into lines is shorter and more efficient
			//var extract = re.exec(arrayOfLines[a]);
			try {
				var extrac = arrayOfLines[a].match(/\[([^\]]+)\]/);		//"s", "p", "o"     type:obj
				var s_p_o = extrac[1].replace(/\"/g,'');	//s, p, o
				var s_p_o_Arr =  s_p_o.split(',');			//3
			}
			catch(err) {
				alert("Error with parsing JSON file:"+ err.message);
			}
			console.log(s_p_o_Arr);
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
			//for (var i = 0; i < s_p_o_Arr.length; i++) {
			//	May use for selecting the proper spo from query
			//};

		}//End of if a==0
		console.log(arrayOfLines[a]);
	}//End of for loop through arrayOfLines


	//for(var b=0;b<s_p_o_Arr.length;b++) {
	//	console.log('InHERE');
	//	for (var c=0;c<data_arr.length;c++) {
	//		console.log('InHERE2');
	//		if (inArr ("hello", data[0].subj) ) { console.log("yes")}
	//		else { console.log("no")}
	//	};
	//	if(inArr(s_p_o_Arr[b], data_arr)) {
	//		//add to subj				
	//	}
	//}

//"s", "p", "o"

//var textArea = document.getElementById("my-text-area");
//var arrayOfLines = textArea.value.split("\n"); // 
	//console.log(json)
	return 'HELLLLOOOOOOO'
}//End of convert()