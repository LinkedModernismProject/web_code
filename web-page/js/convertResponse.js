function convertResponse(response) {
	var resp = response;
	arrOfLines = resp.match(/.+?\n/g);	//Matches everything until the last newline
	for(x in arrOfLines) {
		var line_arr = arrOfLines[x].split(">htt");
		if(line_arr[1]) {	//Grabs value that is to be presented
			var line = line_arr[1].split("/");
			line = line[line.length-3];
			line = line.slice(0,-1);
			if(line.indexOf("#") != -1) {	//If there is a hash with 
				var hash = line.split("#");
				line = hash[1];
			}
			arrOfLines[x] = line_arr[0]+'>'+line+'</a></td>\n';
		}
	}
	var s = '';
	for (var i = 0; i < arrOfLines.length; i++) {
		s = s.concat(arrOfLines[i]);
	};
	s = s.concat('</table>');	
	return s;
}