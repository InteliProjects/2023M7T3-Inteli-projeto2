const { validationResult } = require("express-validator");
require("express-async-errors");

const service = require("../services/url");

const handleErrors = (res, error) => {
  console.error(error);
  res.status(500).json({ message: error.message });
};

const addUrl = async (req, res) => {
  const { url: urlInput } = req.body;

  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: errors.errors[0].msg,
    });
  }

  try {
    const result = await service.Url.create(urlInput);
    res.send(result);
  } catch (err) {
    handleErrors(res, err);
  }
};

const removeUrl = async (req, res) => {
  const { url: urlInput } = req.params;
  console.log("aq")

  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: errors.errors[0].msg,
    });
  }

  try {
    const result = await service.Url.remove(urlInput);
    res.send(result);
  } catch (err) {
    handleErrors(res, err);
  }
};

const getAll = async (req, res) => {
  console.log("aq2")
  try {
    const result = await service.Url.getAll();
    res.send(result);
  } catch (err) {
    handleErrors(res, err);
  }
};

module.exports = {
  addUrl,
  removeUrl,
  getAll,
};
