let Elm = require("./juxta");

let app = Elm.Juxta.fullscreen();

let mysql = require("mysql");

let packets = require("mysql/lib/protocol/packets");

let connection;

app.ports.connect.subscribe(params => {
  connection = mysql.createConnection(
    {
      host: params.hostAndPort[0],
      port: params.hostAndPort[1],
      user: params.user,
      password: params.password,
      database: params.database
    }
  );

  connection.connect(error => {
    if (error) {
      app.ports.connectionFailed.send(error.message);
      return;
    }

    app.ports.connectionEstablished.send([params, connection.threadId]);
  });
});

app.ports.close.subscribe(threadId => {
  connection.end(error => {
    if (error) {
      app.ports.closeConnectionFailed.send([threadId, error.message]);
      return;
    }

    app.ports.connectionClosed.send(threadId);
  });
});

app.ports.runQuery.subscribe(([threadId, sql]) => {
  let query = connection.query(sql);

  query.on("error", error => app.ports.queryFailed.send([threadId, error.message]));

  query.on(
    "fields",
    fields => app.ports.receiveColumns.send(
      [
        threadId,
        fields.map(field => new Object({name: field.name, typeNum: field.type, length: field.length}))
      ]
    )
  );

  query.on("result", packet => {
    if (packet instanceof packets.RowDataPacket) {

      let columns = Object.getOwnPropertyNames(packet);

      let row = [];

      for (let column of columns) {
        let value = packet[column];
        row.push([column, value !== null && value !== undefined ? String(value) : ""]);
      }

      app.ports.receiveRow.send([threadId, row]);

    } else if (packet instanceof packets.OkPacket) {
      app.ports.receiveResult.send([threadId, packet]);
    }
  });

  query.on("end", () => app.ports.receiveEnd.send(threadId));
});

app.ports.runCodemirror.subscribe(id => {

  let observer = new MutationObserver(mutations => {
    mutations.forEach(mutation => {
      if (mutation.addedNodes.length > 0 && mutation.addedNodes[0].className === "editor") {

        observer.disconnect();

        let editor = CodeMirror.fromTextArea(document.getElementById(id), {lineNumbers: true, mode: "sql"});

        editor.setOption("extraKeys", {
          "Cmd-R": () => app.ports.pressRunInCodemirror.send("")
        });

        app.ports.requestTextFromCodemirror.subscribe(() => {
          app.ports.receiveTextFromCodemirror.send(editor.getValue());
        });
      }
    });
  });

  observer.observe(document.body, {childList: true, characterData: true, subtree: true});
});
