const ffmpeg = require("fluent-ffmpeg");
const pathToFfmpeg = require("ffmpeg-static");

const log4js = require("log4js");
const loggerChat = log4js.getLogger("chat");

ffmpeg.setFfmpegPath(pathToFfmpeg);

async function convertToFlac(origin, destination) {
  return new Promise((resolve, reject) => {
    ffmpeg(origin)
      .output(destination)
      .on("end", function () {
        loggerChat.debug("Conversion ended");
        resolve();
      })
      .on("error", function (err) {
        loggerChat.error(err) / loggerChat.error("error: ", err.code, err.msg);
        reject("Error converting audio");
      })
      .run();
  });
}

module.exports = {
  convertToFlac,
};
