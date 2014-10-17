// http://fideloper.com/node-github-autodeploy

var portNum = 9001;

var gith = require('gith').create( portNum ); // Listen on port 9001
var execFile = require('child_process').execFile; // Import execFile, to run our bash script

var bunyan = require('bunyan');
var log = bunyan.createLogger({
  name: 'gith_deployer',
  serializers: {
    err: bunyan.stdSerializers.err
  }
});

var repoName = 'iconix/tn';
var events = 'all';

gith({
  repo: repoName
}).on( events, function( payload ) {
  if( payload.branch === 'master' )
  {
    var start = Date.now();
    log.info({repo: payload.repo}, 'Auto-deploying master branch...');

    // Increase maxBuffer from 200*1024 to 1024*1024
    var execOptions = {
         maxBuffer: 1024 * 1024 // 1mb
    }

    execFile('./hook.sh', execOptions, function(error, stdout, stderr) {
      // Log success in some manner

      console.log(stdout);

      var end = Date.now();
      log.info({deploy_time_s: ((end - start)/1000)}, 'Deployment complete.');
    });
  } else {
    log.info({branch: payload.branch}, 'Payload was not for master, aborting.');
  }
});

process.on('uncaughtException', function (e) {
  log.fatal({err: e, type: 'UncaughtException'});
  process.abort();
});

log.info({port_number: portNum, repo: repoName, events: events}, 'Gith is now listening.');
