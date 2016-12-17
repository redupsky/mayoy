let Elm = require("./mayoy");
let mysql = require("mysql");
let packets = require("mysql/lib/protocol/packets");

let app = Elm.Mayoy.fullscreen();

let connection;
let editor;

const historyStorageKey = "mayoy_connection_history";
const editorHistoryStorageKey = "mayoy_editor_history";

const codemirrorOptions = {lineNumbers: true, mode: "sql", autofocus: true, lineNumbers: false};

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
      app.ports.connectionFailed.send(error.message.replace(/^[A-Z_]+:\s+/, ""));
      return;
    }

    app.ports.connectionEstablished.send([params, connection.threadId]);
  });
});

app.ports.close.subscribe(threadId => {
  connection.end(error => {
    if (error) {
      app.ports.closeConnectionFailed.send([threadId, error.message]);
    } else {
      app.ports.connectionClosed.send(threadId);
    }

    editor.toTextArea(); // Fucking magic destroy of Codemirror
  });
});

app.ports.getEditorLastValueFromLocalStorage.subscribe(name => {
  let history = JSON.parse(localStorage.getItem(editorHistoryStorageKey));

  if (history !== null && history[name]) {
    app.ports.receiveEditorLastValueFromLocalStorage.send(String(history[name]));
  }
});

app.ports.runQuery.subscribe(([threadId, sql]) => {

  let query = connection.query(sql);
  let start = new Date();

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

  query.on("end", () => {
    let stop = new Date();
    app.ports.receiveEnd.send([threadId, (stop - start) / 1000]);
  });
});

app.ports.saveConnectionParamsToLocalStorage.subscribe(([name, params]) => {
  let history = JSON.parse(localStorage.getItem(historyStorageKey));

  if (history === null) {
    history = {};
  }

  history[name] = params;

  localStorage.setItem(historyStorageKey, JSON.stringify(history));
});

app.ports.getConnectionHistoryFromLocalStorage.subscribe(() => {
  const history = JSON.parse(localStorage.getItem(historyStorageKey));

  if (history !== null) {
    app.ports.receiveConnectionHistoryFromLocalStorage.send(Object.keys(history).map(key => history[key]));
  }
});

app.ports.changeTitle.subscribe(title => document.title = title);

app.ports.runCodemirror.subscribe(id => {
  let observer = new MutationObserver(mutations => {
    mutations.forEach(mutation => {
      if (mutation.addedNodes.length > 0 && (mutation.addedNodes[0].id === id ||
        mutation.addedNodes[0].className === id)
      ) {
        observer.disconnect();

        editor = CodeMirror.fromTextArea(document.getElementById(id), codemirrorOptions);

        editor.setOption("extraKeys", {
          "Cmd-R": () => app.ports.pressRunInCodemirror.send("")
        });

        editor.on("change", () => app.ports.receiveTextFromCodemirror.send(editor.getValue()));

        editor.on("cursorActivity", () => {
          let text = editor.getSelection();
          app.ports.selectText.send(text !== "" ? text : null);
        });

        editor.on("cursorActivity", () => {
          let {line} = editor.getCursor();
          let text = editor.getLine(line);
          app.ports.receiveTextInCurrentLineFromCodemirror.send(text !== "" ? text : null);
        });
      }
    });
  });

  observer.observe(document.body, {childList: true, characterData: true, subtree: true});
});
