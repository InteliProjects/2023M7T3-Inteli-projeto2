const express = require("express");
const router = express.Router();
const { body, param, validationResult } = require("express-validator");

const chatController = require("../controllers/chat");

router.post(
	"/create/:userId",
	param("userId", "ID é necessário").exists({ checkFalsy: true }),
	chatController.create
);

router.get(
	"/get/:userId",
	param("userId", "ID é necessário").exists({ checkFalsy: true }),
	chatController.getAll
);

router.get(
	"/getOne/:userId/:chatId",
	param("userId", "ID é necessário").exists({ checkFalsy: true }),
	param("chatID", "ID é necessário").exists({ checkFalsy: true }),
	chatController.get
);

router.delete(
	"/delete/:userId/:chatId",
	param("userId", "ID é necessário").exists({ checkFalsy: true }),
	param("chatId", "ID é necessário").exists({ checkFalsy: true }),
	chatController.remove
);

router.get(
	"/getAudio/:messageId",
	param("messageId", "ID da mensagem é necessário").exists({
		checkFalsy: true,
	}),
	chatController.getAudio
);

router.post("/ask/:mode/:chatId", chatController.ask);

router.get("/getAllMessages", chatController.getAllMessages);
//Exporta o ROUTER
module.exports = router;
