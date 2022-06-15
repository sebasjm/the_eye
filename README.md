# THE EYE

Reload the browser using inotifywait, socat and websockets

## Requirements

**socat**: listen TCP connections, reply Websocket handshake, send reload command

**inotifywait**: listen for filesystem changes

```
apt install socat inotify-tools -y
```

## Usage

The html should start a websocket client connection to the server and listen to the "RELOAD" command. You can use the `client.js` for reference.

The server can be started like this

```
./serve.sh <directory> <executable file> <...args>
```

 * **directory**: the script will watch any *close_write* event on the directory and subdirectories
 * **exec file**: this will be called at the start and for any change
 * **args**: every arg after the executable will be sent to the exec call

Messages to all the browser can be send

```
./send "<json content>"
```

Currently the client.js will trigger a ```location.reload()``` after a ```'{"type":"RELOAD"}'``` message.

