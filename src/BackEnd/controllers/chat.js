const { validationResult } = require("express-validator");
//const preSub = require('../services/preSub')
require("express-async-errors");

const service = require("../services/chat");

const chat = new service.Chat();

const ask = async (req, res) => {
	const { mode, chatId } = req.params;

	//Validação dos campos
	const errors = validationResult(req);

	if (!errors.isEmpty()) {
		return res.status(400).json({ errors: errors.array() });
	}

	//Chamada para o service
	try {
		//Tratamento das respostas do método da classe
		const result = await chat.Ask(req.body, mode, chatId);
		res.send(result);
	} catch (err) {
		res.status(500).send(err.message);
	}
};

const create = async (req, res) => {
	const { userId } = req.params;

	console.log(userId);

	const errors = validationResult(req);

	if (!errors.isEmpty()) {
		return res.status(400).json({ errors: errors.array() });
	}

	//Chamada para o service
	try {
		//Tratamento das respostas do método da classe
		const result = await chat.Create(userId);
		res.send(result);
	} catch (err) {
		res.status(500).send(err.message);
	}
};

const getAll = async (req, res) => {
	const { userId } = req.params;

	//Chamada para o service
	try {
		//Tratamento das respostas do método da classe
		const result = await chat.GetAll(userId);
		res.send(result);
	} catch (err) {
		res.status(500).send(err.message);
	}
};

const get = async (req, res) => {
	const { chatId, userId } = req.params;

	//Chamada para o service
	try {
		//Tratamento das respostas do método da classe
		const result = await chat.Get(chatId, userId);
		res.send(result);
	} catch (err) {
		res.status(500).send(err.message);
	}
};

const remove = async (req, res) => {
	const { userId, chatId } = req.params;

	//Chamada para o service
	try {
		const result = await chat.Delete(userId, chatId);
		res.send(result);
	} catch (err) {
		res.status(500).send(err.message);
	}
};

const getAudio = async (req, res) => {
	const { messageId } = req.params;

	//Chamada para o service
	try {
		const result = await chat.GetAudio(messageId);
		res.send(result);
	} catch (err) {
		res.status(500).send(err.message);
	}
};

const getAllMessages = async (req, res) => {
	//Chamada para o service
	try {
		const result = await chat.getLengthAllMessages();
		res.send(result);
	} catch (err) {
		res.status(500).send(err.message);
	}
};

//Exporta as funções do controller para o ROUTER
module.exports = {
	ask,
	create,
	getAll,
	get,
	remove,
	getAudio,
	getAllMessages,
};
