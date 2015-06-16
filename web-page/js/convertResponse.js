function convertResponse (response) {
	console.log("in convertResponse.js " + typeof(response));
	var resp = response;
	console.log(resp);
	arrOfLines = resp.match(/.+?\n/g);	//Matches everything until the last newline
	console.log(arrOfLines);
	console.log(arrOfLines[0]);
	console.log(arrOfLines[1]);
	console.log(arrOfLines[2]);
	console.log(arrOfLines[arrOfLines.length-2]);
	console.log(arrOfLines[arrOfLines.length-1]);
	console.log(arrOfLines[arrOfLines.length]);
	for(x in arrOfLines) {
		console.log(x+':'+arrOfLines[x]);
		//var s = arrOfLines[x].match(/\<td\>[.*?]\>/g);
		var line_arr = arrOfLines[x].split(">htt");
		if(line_arr[1]) {
			var line = line_arr[1].split("/");
			line = line[line.length-3];
			line = line.slice(0,-1);
			if(line.indexOf("#") != -1) {
				var hash = line.split("#");
				console.log(hash);
				line = hash[1];
			}
			arrOfLines[x] = line_arr[0]+'>'+line+'</a></td>\n';	//May need <br> or \n at the end
		}
	}
	//Do for loop to get the data into a string
	var s = '';
	for (var i = 0; i < arrOfLines.length; i++) {
		s = s.concat(arrOfLines[i]);
	};
	s = s.concat('</table>');
	console.log(s);

	console.log("going back to Index.html")
	return resp;
}