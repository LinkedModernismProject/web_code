

function nl2SPARQL(words){
  var natural = require('natural');
  natural.PorterStemmer.attach();

  
  var query = words.tokenizeAndStem();

}
