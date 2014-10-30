echo '>>> Updating deploy files'
curl https://raw.githubusercontent.com/iconix/tn/master/deploy/hook.js > hook.js
curl https://raw.githubusercontent.com/iconix/tn/master/deploy/hook.sh > hook.sh
curl https://raw.githubusercontent.com/iconix/tn/master/deploy/package.json > package.json

echo '>>> Pulling pre-built logspout router'
docker pull progrium/logspout

echo '>>> Creating/starting logspout to monitor Docker Unix socket'
docker run -p 8000:8000 -d -v=/var/run/docker.sock:/tmp/docker.sock -h $HOSTNAME progrium/logspout syslog://logs2.papertrailapp.com:24683