const {app, BrowserWindow, Menu} = require("electron");

let win;

const menu = Menu.buildFromTemplate(
  [
    {
      label: "Juxta",
      submenu: [
        {
          role: "about"
        },
        {
          type: "separator"
        },
        {
          role: "quit"
        }
      ]
    }
  ]
);

function createWindow() {

  win = new BrowserWindow({width: 800, height: 600});

  Menu.setApplicationMenu(menu);

  win.loadURL(`file://${__dirname}/index.html`);

  win.webContents.openDevTools();

  win.on("closed", () => {
    win = null;
  });
}

app.on("ready", createWindow);

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
  }
})

app.on("activate", () => {
  if (win === null) {
    createWindow();
  }
})
