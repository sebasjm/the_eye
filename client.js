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
          if (event.type === "UPDATE") {
            document.body.removeChild(document.getElementById("container"))
            const d = document.createElement('div')
            d.setAttribute('id',"container")
            d.setAttribute('class',"anastasis-container");
            document.body.appendChild(d)
            const s = document.createElement('script')
            s.setAttribute('id',"code")
            s.setAttribute('type',"application/javascript");
            s.textContent = atob(event.content)
            document.body.appendChild(s)
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
