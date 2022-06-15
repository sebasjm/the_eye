(() => {
      function setupLiveReload() {
        const socketPath = `ws://localhost:8003/socket`;
        console.log("connecting to ", socketPath)
        const ws = new WebSocket(socketPath);
        ws.onmessage = (message) => {
          const event = JSON.parse(message.data);
          if (event.type === "LOG") {
            console.log(event.message);
          }
          if (event.type === "RELOAD") {
            window.location.reload();
          }
        };
        ws.onerror = (error) => {
          console.error(error);
        };
        ws.onclose = (e) => {
          setTimeout(setupLiveReload, 500)
        };
      }
      setupLiveReload();

})();
