const fs = require("fs");
const express = require("express");
const app = express();
const bodyParser = require("body-parser");
const cors = require("cors");
const log4js = require("log4js");

app.use(bodyParser.json());
app.use(bodyParser.raw({ type: "audio/mp4", limit: "150mb" }));

//Configurando Log de Usuários
log4js.configure({
  appenders: {
    multi: {
      type: "multiFile",
      base: "logs/",
      property: "categoryName",
      extension: ".log",
    },
  },
  categories: {
    default: { appenders: ["multi"], level: "debug" },
  },
});

//Import Cors
app.use(cors());

//Import Routes
const chatRoute = require("./routes/chat");
const userRoute = require("./routes/user");
// const urlRoute = require("./routes/url");

//Use Routes
app.use("/v1/chat", chatRoute);
app.use("/v1/user", userRoute);
// app.use("/v1/url", urlRoute);

app.get("/", (req, res) => {
  res.send({
    message: "Health check completed!",
    status: 200,
  });
});

app.get("/audio", (req, res) => {
  let audio = fs.readFileSync("./audio/audio-file.flac");

  res.writeHead(200, {
    "Content-Type": "audio/flac",
    "Content-Length": audio.length,
  }).end(audio);
});

app.listen(3001, () => {
  console.log("Server is running on port 3001");
});
