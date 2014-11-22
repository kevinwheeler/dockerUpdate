#!/bin/bash
#given a path to the distributed runtime jar on your computer, will copy it into the accumulo docker into the correct directory, however you must specifiy the file name that will be used in that output directory.
USAGE="Usage: ./script inputDistRuntimeFilename outputDisRuntimeFilename"
if [ $# -ne 2 ]
  then
  echo $USAGE
  exit 0
fi

if [ -a $1 ]
  then
    echo 'Found input file.'
  else
    echo 'Didnt find input file'
    exit 0 
fi

CONTAINER_ID=$(docker ps | grep tests-accumulo)
CONTAINER_ID=${CONTAINER_ID:0:12}
echo $CONTAINER_ID
if [ -z "$CONTAINER_ID" ]
  then
  echo Error: Couldnt find  'tests-accumulo' container.
  exit 0
fi

FULL_ID=$(docker inspect -f \{\{\.Id\}\} $CONTAINER_ID)
echo $FULL_ID

if [ -z "$FULL_ID" ]
  then
  echo Error expanding abbreviated container id to full id.
  exit 0
fi

ACCUMULO_HOME=/opt/accumulo/accumulo-1.5.2
cp $1 /var/lib/docker/aufs/mnt/$FULL_ID/$2 #opt/accumulo/accumulo-1.5.2/lib/ext
docker exec tests-accumulo mv /$2 $ACCUMULO_HOME/lib/ext/$2
docker exec tests-accumulo $ACCUMULO_HOME/bin/stop-all.sh
docker exec tests-accumulo $ACCUMULO_HOME/bin/start-all.sh
