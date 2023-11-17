const express = require("express");
const router = express.Router();
const { body, param } = require("express-validator");

const userController = require("../controllers/url");

router.post(
    "/addurl",
    [body("url", "url is required to proceed").exists({ checkFalsy: true })],
    userController.addUrl
);

router.get(
    "/getall",
    userController.getAll
);

router.delete(
    "/delete/:url",
    [param("url", "url is required to proceed").exists({ checkFalsy: true })],
    userController.removeUrl
);

module.exports = router;