function convertResponse (response) {
	console.log("in convertResponse.js " + typeof(response));
	var resp = response;
	console.log(resp);
	console.log(resp[0] +' '+ resp[3] +' '+ resp[17] +' '+ resp[36]);
	console.log(resp[29]+'|'+resp[30]+'|'+resp[31]+'|'+resp[32]+'|'+resp[33] +'|'+ resp[34] +'|'+ resp[35] +'|'+ resp[36] +'|'+ resp[37]+'|');	//33 is a newline 34&35 are spaces
	console.log("Resp: "+ typeof(resp));
	arrOfLines = resp.match(/.+?\n/g);
	console.log(arrOfLines);
	console.log(arrOfLines[0]);
	console.log(arrOfLines[1]);
	console.log(arrOfLines[2]);
	console.log(arrOfLines[arrOfLines.length-2]);
	console.log(arrOfLines[arrOfLines.length-1]);
	console.log(arrOfLines[arrOfLines.length]);


	console.log("going back to Index.html")
	return resp;
}