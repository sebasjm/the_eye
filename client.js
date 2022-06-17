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
      if (event.type === "BUILDING") {
        const block = document.createElement('div')
        block.style.position = "absolute"
        block.style.width = "100%"
        block.style.height = "100%"
        block.style.backgroundColor = "rgba(0,0,0,0.5)"
        block.style.color = "white"
        block.style.display = "flex"
        block.style.justifyContent = "center"
        block.style.top = 0
        block.style.left = 0
        document.body.appendChild(block)
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
