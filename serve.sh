#!/bin/bash

LOCK=/var/lock/the_eye_watcher

exec 4>$LOCK
flock -xn 4
[ "$?" != "0" ] && echo another watch running, remove $LOCK if not && exit 1

function cleanup {
 trap - SIGHUP SIGINT SIGTERM SIGQUIT
 flock -u $LOCK
 exec 4<&-
 echo -n "Cleaning up... "
 kill $SERVER_PID
 kill -- -$$
 exit 1
}
trap cleanup SIGHUP SIGINT SIGTERM SIGQUIT

WATCH_DIRECTORY=$1
TRIGGER_SCRIPT=$2
DIR="$(dirname -- "${BASH_SOURCE[0]:-$0}")"

[[ ! -d "$1" ]] && echo "directory missing or doesnt exists" && exit 1 
[[ ! -f "$2" ]] && echo "script missing or is not exec-able" && exit 1 
shift
shift

set -e

#build once
bash "$TRIGGER_SCRIPT" $@

#setup the server that will replay incoming connections
echo server up on 8003
socat TCP-LISTEN:8003,fork,reuseaddr,keepalive EXEC:"$DIR/reply.sh" &
SERVER_PID=$!

#watch fro filechanges and then:
# * add a log entry
# * run the build script
# * notify the browser about the change
echo watching $WATCH_DIRECTORY for changes
inotifywait -e close_write -e delete -e moved_from -r $WATCH_DIRECTORY -q -m | while read line; do
    $DIR/send.sh '{"type":"BUILDING"}'
    echo -n $(date "+%D %T") $line " "
    /usr/bin/time -f %E bash $TRIGGER_SCRIPT $@
    $DIR/send.sh '{"type":"RELOAD"}'
done;

