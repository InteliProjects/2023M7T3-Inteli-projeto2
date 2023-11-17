const { PrismaClient } = require("@prisma/client");
const uuid = require("uuid").v4;
const http = require("http");
const validUrl = require("valid-url");

const prisma = new PrismaClient();

class Url {
  static async getAll() {
    try {
      const urls = await prisma.url.findMany();
      return urls;
    } catch (error) {
      throw new Error("Error getting urls:: " + error.message);
    }
  }

  static async create(url) {
    // Valide a URL antes de prosseguir com a inserção
    if (!validUrl.isWebUri(url)) {
      throw new Error("Invalid url");
    }

    const urlAlreadyAdded = await prisma.url.findUnique({
      where: {
        url: url,
      },
    });

    if (urlAlreadyAdded) {
      throw new Error("url is already added to the database");
    }

    const newUrl = await prisma.url.create({
      data: {
        id: uuid(),
        url: url,
      },
    });

    try {
      const flaskUrl = "http://13b8-35-237-57-249.ngrok-free.app/call_external_api";
      http.get(flaskUrl, (response) => {
        let data = "";
        response.on("data", (chunk) => {
          data += chunk;
        });
        response.on("end", () => {
          console.log("GET request to the NLP API successful");
        });
      });
    } catch (error) {
      console.error("Error making GET request to the NLP API:", error);
    }

    return newUrl;
  }

  static async remove(url_bd) {
    const removeUrl = await prisma.url.findUnique({
      where: {
        url: url_bd,
      },
    });

    if (!removeUrl) {
      throw new Error("url is not in this database");
    }

    await prisma.url.delete({
      where: {
        url: url_bd,
      },
    });

    return {
      message: "Url removed successfully",
    };
  }
}

module.exports = {
  Url,
};
