const { Configuration, OpenAIApi } = require("openai");
require("dotenv").config();
//Configurando Log
const log4js = require("log4js");

const loggerChat = log4js.getLogger("chat");

const configuration = new Configuration({
	apiKey: process.env.OPENAI_API_KEY,
});

const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const openai = new OpenAIApi(configuration);

let conversations = {};

async function sendToGPT(text, chatId, mode) {
	let messages = [];

	let start = new Date().getTime();

	if (mode === "SalesTracker") {
		messages.push({
			role: "system",
			content:
				"Você é um assistente de bate-papo que têm como função ajudar usuários que trabalham na área de vendas de uma empresa, e portanto suas informações devem ajudar o usuário em seu trabalho. Tente dar uma resposta sucinta e objetiva.",
		});
	} else if (mode === "MarketTracker") {
		messages.push({
			role: "system",
			content:
				"Você é um assistente de bate-papo que têm como função ajudar usuários que trabalham na área de marketing de uma empresa, e portanto suas informações devem ajudar o usuário em seu trabalho. Tente dar uma resposta sucinta e objetiva.",
		});
	}

	const chat = await prisma.chat.findUnique({
		where: {
			id: chatId,
		},
		include: {
			messages: true,
		},
	});

	if (chat && chat.messages.length > 0) {
		chat.messages.forEach((message) => {
			if (message.isUser) {
				messages.push({
					role: "user",
					content: message.content,
				});
			} else {
				messages.push({
					role: "assistant",
					content: message.content,
				});
			}
		});
	}

	messages.push({
		role: "user",
		content: text,
	});

	console.log(messages);

	try {
		const completion = await openai.createChatCompletion({
			model: "gpt-3.5-turbo",
			messages: messages,
		});

		loggerChat.debug(
			"Chat finalizado!",
			completion.data.choices[0].message.content
		);
		loggerChat.info("Chat finalizado com sucesso!");

		let end = new Date().getTime();
		let time = end - start;

		loggerChat.info(
			"Tempo de resposta para gerar texto com GPT: " + time + "ms"
		);

		return completion.data.choices[0].message.content;
	} catch (error) {
		let end = new Date().getTime();
		let time = end - start;

		loggerChat.info(
			"Tempo de resposta para gerar texto com GPT: " + time + "ms"
		);

		console.error("Error completing chat:", error);
		loggerChat.error("Error completing chat", error.status);
		throw new Error("Error completing chat");
	}
}

async function recordChatOfUser(answer, question, userName) {
	const chat = {
		question: question,
		answer: answer,
	};

	if (conversations[userName]) {
		conversations[userName].push(chat);
	} else {
		conversations[userName] = [chat];
	}
}

function getActualChat(userName) {
	return conversations[userName];
}

module.exports = {
	sendToGPT,
	recordChatOfUser,
	getActualChat,
};
