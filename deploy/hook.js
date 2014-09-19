// http://fideloper.com/node-github-autodeploy

var gith = require('gith').create( 9001 ); // Listen on port 9001
var execFile = require('child_process').execFile; // Import execFile, to run our bash script

gith({
  repo: 'iconix/tn'
}).on( 'all', function( payload ) {
  console.log('Payload: ' + payload);
  if( payload.branch === 'master' )
  {
    var start = Date.now();
    console.log( '[' + Date(start) + '] Auto-deploying master branch of repo ' + payload.repo + '...' );

    // Increase maxBuffer from 200*1024 to 1024*1024
    var execOptions = {
         maxBuffer: 1024 * 1024 // 1mb
    }

    execFile('hook.sh', execOptions, function(error, stdout, stderr) {
      // Log success in some manner
      var end = Date.now();
      console.log( '[' + Date(end) + '] Deployment complete.' );
      console.log('Deployment completed in ' + (end - start)/1000 + 's');
    });
  } else {
    console.log( '[' + Date(start) + '] Payload was not for master, aborting.' );
  }
});

console.log('Gith is now listening.');
