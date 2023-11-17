const { PrismaClient } = require("@prisma/client");

const fs = require("fs");
const uuid = require("uuid").v4;

const ibmUtils = require("../utils/ibm");
const gptUtils = require("../utils/gpt");
const ffmpegUtils = require("../utils/ffmpeg");

//Configurando Log
const log4js = require("log4js");
const loggerChat = log4js.getLogger("chat");

const prisma = new PrismaClient();

const axios = require("axios");
const { createAudio } = require("../utils/mongo");

require("dotenv").config();

const storeAudio = async (audioFile) => {
	loggerChat.debug("Storing audio...");
	return "url-sample";
};

class Chat {
	async Ask(content, mode, chatId) {
		loggerChat.debug("Starting Ask method...");

		let start = new Date().getTime();

		if (!content) {
			loggerChat.error("Audio is required");
			throw new Error("Audio is required");
		}

		if (!mode) {
			loggerChat.error("Mode is required");
			throw new Error("Mode is required");
		}

		if (!chatId) {
			loggerChat.debug("ChatId is required - Not storing...");
		}

		loggerChat.debug("Receiving audio...");
		loggerChat.info("Audio Received");

		//Save in a file the audio
		try {
			fs.writeFileSync("audios/receiving.m4a", content);
			loggerChat.info("Audio saved");
		} catch (err) {
			console.error("Error saving audio:", err);
			loggerChat.error("Error saving audio:", err);
			throw new Error("Error saving audio");
		}

		//Convert audio to flac
		try {
			await ffmpegUtils.convertToFlac(
				"audios/receiving.m4a",
				"audios/receiving.flac"
			);
			loggerChat.info("Audio converted to flac");
		} catch (error) {
			console.error("Error converting audio:", error);
			loggerChat.error("Error converting audio:", error);

			let end = new Date().getTime();
			let time = end - start;

			loggerChat.info("Tempo de resposta para rodar ASK: " + time + "ms");

			throw new Error("Error converting audio");
		}

		//Read the audio file
		const audioFlac = fs.readFileSync("audios/receiving.flac");

		try {
			const text = await ibmUtils.generateText(audioFlac);
			loggerChat.debug(text);

			const responseChat = await gptUtils.sendToGPT(text, chatId, mode);
			// const responseChat = "This is a mock of a response.";
			loggerChat.debug(responseChat);

			const audio = await ibmUtils.generateSpeech(responseChat);
			loggerChat.debug(audio);

			const question = {
				text: text.charAt(0).toUpperCase() + text.slice(1),
				audio: audioFlac.toString("base64"),
			};

			const answer = {
				text: responseChat,
				audio: audio.toString("base64"),
			};

			const response = {
				question: question,
				answer: answer,
			};

			//Remove all files with audio suffix on this path
			try {
				fs.readdirSync("audios").forEach((file) => {
					if (
						file.includes("receiving") ||
						file.includes("sending")
					) {
						fs.unlinkSync("audios/" + file);
					}
				});
			} catch (err) {
				let end = new Date().getTime();
				let time = end - start;

				loggerChat.info(
					"Tempo de resposta para rodar ASK: " + time + "ms"
				);

				console.error("Error removing audio files:", err);
				loggerChat.error("Error removing audio files:", err);
				throw new Error("Error removing audio files");
			}

			loggerChat.info(`Response sent - ${responseChat}`);

			if (chatId) {
				// create message with first user audio
				const questionMessage = await prisma.message.create({
					data: {
						id: uuid(),
						isUser: true,
						chatId: chatId,
						audio: audioFlac.toString("base64"),
						audioUrl: "",
						content: text,
					},
				});

				// Store response
				const responseMessage = await prisma.message.create({
					data: {
						id: uuid(),
						isUser: false,
						chatId: chatId,
						audio: response.answer.audio,
						audioUrl: "",
						content: response.answer.text,
					},
				});

				let end = new Date().getTime();
				let time = end - start;

				loggerChat.info(
					"Tempo de resposta para rodar ASK: " + time + "ms"
				);

				return {
					question: {
						text: questionMessage.content,
						audio: questionMessage.audio,
					},
					answer: {
						text: responseMessage.content,
						audio: responseMessage.audio,
					},
				};
			}

			return response;
		} catch (error) {
			loggerChat.error(error);

			let end = new Date().getTime();
			let time = end - start;

			loggerChat.info("Tempo de resposta para rodar ASK: " + time + "ms");

			throw new Error("Error recognizing audio");
		}
	}

	async Create(userId) {
		loggerChat.debug("Starting Create method...");

		try {
			const chat = await prisma.chat.create({
				data: {
					id: uuid(),
					userId: userId,
				},
			});

			return chat.id;
		} catch (error) {
			throw new Error(error);
		}
	}

	async GetAll(userId) {
		loggerChat.debug("Starting GetAll method...");

		try {
			const chats = await prisma.chat.findMany({
				where: {
					userId: userId,
				},
				include: {
					messages: {
						take: 1,
						orderBy: {
							createdAt: "desc",
						},
					},
				},
			});

			return chats;
		} catch (error) {
			throw new Error(error);
		}
	}

	async Get(chatId, userId) {
		loggerChat.debug("Starting Get method...");

		try {
			const chat = await prisma.chat.findUnique({
				where: {
					id: chatId,
					userId: userId,
				},
				include: {
					messages: true,
				},
			});

			if (!chat) {
				throw new Error("Chat not found");
			}

			const chatToLog = JSON.parse(JSON.stringify(chat));
			chatToLog.messages.forEach((message) => {
				message.audio = "audio-base64";
			});

			loggerChat.debug(chatToLog);

			return chat;
		} catch (error) {
			throw new Error(error);
		}
	}

	async Delete(userId, chatId) {
		loggerChat.debug(`Deleting chat ${chatId} from user ${userId}`);

		const chatAlreadyExists = await prisma.chat.findUnique({
			where: {
				id: chatId,
				userId: userId,
			},
		});

		loggerChat.debug(
			`chatAlreadyExists: ${JSON.stringify(chatAlreadyExists)}`
		);

		if (!chatAlreadyExists || chatAlreadyExists.userId !== userId) {
			loggerChat.error("Chat not found");
			throw new Error("Chat not found");
		}

		loggerChat.debug(`Chat ${chatId} found in user ${userId}`);

		try {
			// Delete messages associated with the chat
			await prisma.message.deleteMany({
				where: {
					chatId: chatId,
				},
			});

			// Now delete the chat
			await prisma.chat.delete({
				where: {
					id: chatId,
				},
			});

			loggerChat.info("Chat removed successfully");

			return "Chat and associated messages deleted successfully";
		} catch (err) {
			loggerChat.error(`Server problems - ${err}`);
			throw new Error(`Server problems - ${err}`);
		}
	}

	async Update(id, userId, data) {
		loggerChat.debug("Starting Update method...");

		const chatAlreadyExists = await prisma.chat.findUnique({
			where: {
				id: id,
				userId: userId,
			},
		});

		if (!chatAlreadyExists) {
			throw new Error("Chat not found");
		}

		try {
			const chat = await prisma.chat.update({
				where: {
					id: id,
					userId: userId,
				},
				data,
			});

			return {
				message: "User updated successfully",
				chat: chat,
			};
		} catch {
			throw new Error("Coudn't update your chat");
		}
	}

	async getAudio(messageId) {
		loggerChat.debug("Starting getAudio method...");

		try {
			const audio = await getAudio(messageId);

			if (!audio) {
				throw new Error("Chat not found");
			}

			return audio;
		} catch (error) {
			throw new Error(error);
		}
	}

	async getLengthAllMessages() {
		loggerChat.debug("Starting getLengthAllMessages method...");

		try {
			const messages = await prisma.message.findMany({});

			const chats = await prisma.chat.findMany({});

			const result = {
				messages: Number(messages.length),
				chats: Number(chats.length),
			};

			return result;
		} catch (err) {
			console.log(err);
			throw new Error("Error getting audio");
		}
	}
}

module.exports = {
	Chat,
};
