#!/bin/sh

echo Running $BASH_SOURCE
set | egrep GIT
echo PWD is $PWD

# Adapted from:
# http://www.hiddentao.com/archives/2013/12/26/automated-deployment-with-docker-lessons-learnt/

# if data-only container does not already exist
EXISTS=$(docker ps -a | grep 'tn_data')
if [ $? -eq 1 ];
  then
  echo '>>> Creating/starting new (data-only) container'
  docker run -v /data --name tn_data busybox
fi

echo '>>> Get old container id'
CID=$(docker ps | grep "iconix/tn" | awk '{print $1}')
echo $CID

echo '>>> Building new image'
# Analyzing log files, since I don't want skipped unknown instructions to cause build to fail with error (see https://github.com/docker/docker/issues/6338)
docker build -t iconix/tn github.com/iconix/tn | tee /tmp/docker_build_result.log
RESULT=$(cat /tmp/docker_build_result.log | tail -n 1)
if [[ "$RESULT" != *Successfully* ]];
then
  exit -1
fi

echo '>>> Stopping old container'
if [ "$CID" != "" ];
  then
  docker stop $CID
fi

echo '>>> Restarting docker'
service docker restart
sleep 5

# We remove any container which:
#   1) is not the data-only container and
#   2) has exited
echo '>>> Cleaning up containers'
docker ps -a | grep -v "tn_data" | grep "Exit" | awk '{print $1}' | while read -r id ; do
  docker rm $id
done

echo '>>> Creating/starting new container based on new image'
docker run -p 8080:8080 -d --volumes-from tn_data --name tn_app --env-file ../docker_env iconix/tn
