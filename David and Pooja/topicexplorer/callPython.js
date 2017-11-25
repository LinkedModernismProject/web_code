var spawn = require('child_process').spawn,
    py    = spawn('python', ['demo.py']),
    data = [1,2,3,4,5,6,7,8,9],
    dataString = '';

// py.stdout.on('data', function(data){
//   dataString += data.toString();
// });
// py.stdout.on('end', function(){
//   console.log('Sum of numbers=',dataString);
// });
process.stdout.on('data', function (data){
// Do something with the data returned from python script
});
py.stdin.write("done");
py.stdin.end();