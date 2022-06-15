#!/bin/bash
SERVER_KEY=258EAFA5-E914-47DA-95CA-C5AB0DC85B11

DIR="$(dirname -- "${BASH_SOURCE[0]:-$0}")"

# incoming connection starts with something like this
#
#    HTTP/1.1 101 Switching Protocols
#    Upgrade: websocket
#    Connection: Upgrade
#    Sec-WebSocket-Accept: <random-client-key>
#
# and a lot of more headers, so we get the client key 
# and throw everything else

while read line; do
  LINE=$(echo $line | tr -d '\r')
  case $LINE in 
    Sec-WebSocket-Key:*)
      CLIENT_KEY="${LINE:19}"
      export WS_ACCEPT=$( echo -n $CLIENT_KEY$SERVER_KEY | sha1sum | xxd -r -p | base64 )
      ;;
     "") break ;;
  esac
done

# reply with a usual ws content and the server calculation
cat $DIR/ws_reply | sed 's/$'"/`echo \\\r`/" | envsubst '$WS_ACCEPT'

# listen any command and send it to the standard output
tail -n 0 -F /tmp/send_signal 2> /dev/null

