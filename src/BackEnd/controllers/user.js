const { validationResult } = require("express-validator");
require("express-async-errors");

const service = require("../services/user");

const user = new service.User();

const subscribe = async (req, res) => {
  const { email, name, password } = req.body;

  //Valida se algum paremetro é inválido
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: errors.errors[0].msg,
    });
  }

  //Chamada para o service
  try {
    //Tratamento das respostas do método da classe
    const result = await user.Create(email, name, password);
    res.send(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const authenticate = async (req, res) => {
  const { email, password } = req.body;

  //Valida se algum paremetro é inválido
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: errors.errors[0].msg,
    });
  }

  //Chamada para o service
  try {
    //Tratamento das respostas do método da classe
    const result = await user.Authenticate(email, password);
    res.send(result);
  } catch (err) {
    res.status(500).send({
      message: err.message,
    });
  }
};

const update = async (req, res) => {
  const { id } = req.params;

  //Valida se algum paremetro é inválido
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: errors.errors[0].msg,
    });
  }

  //Chamada para o service
  try {
    //Tratamento das respostas do método da classe
    const result = await user.Update(id, req.body);
    res.send(result);
  } catch (err) {
    res.status(500).send(err.message);
  }
};

const remove = async (req, res) => {
  const { id } = req.params;

  //Valida se algum paremetro é inválido
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: errors.errors[0].msg,
    });
  }

  //Chamada para o service
  try {
    //Tratamento das respostas do método da classe
    const result = await user.Remove(id);
    res.send(result);
  } catch (err) {
    res.status(500).send(err.message);
  }
};

const getCalling = async (req, res) => {
  //Chamada para o service
  try {
    //Tratamento das respostas do método da classe
    const result = await user.Get(req.id);
    res.send({result});
  } catch (err) {
    res.status(500).send(err.message);
  }
};

const get = async (req, res) => {
  const { id } = req.params;

  //Valida se algum paremetro é inválido
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      message: errors.errors[0].msg,
    });
  }

  //Chamada para o service
  try {
    //Tratamento das respostas do método da classe
    const result = await user.Get(id);
    res.send(result);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

const getAll = async (req, res) => {
  //Chamada para o service
  try {
    //Tratamento das respostas do método da classe
    const result = await user.GetAll();
    res.send(result);
  } catch (err) {
    res.status(500).send(err.message);
  }
}



//Exporta as funções do controller para o ROUTER
module.exports = {
  subscribe,
  authenticate,
  update,
  remove,
  getCalling,
  get,
  getAll
};
