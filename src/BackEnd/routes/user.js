const express = require("express");
const router = express.Router();
const { body, param, validationResult } = require("express-validator");

const userController = require("../controllers/user");
const { unsureAuthenticated } = require("../middlewares/unsureAuthenticated");

//Middlewares
//const unsureAuthenticated = require("../middlewares/unsureAuthenticated");

router.post(
    "/sub",
    [body("name", "Nome é necessário").exists({ checkFalsy: true })],
    [body("email", "Email é necessário").exists({ checkFalsy: true })],
    [body("password", "Senha é necessária").exists({ checkFalsy: true })],
    userController.subscribe
);

router.post(
    "/auth",
    [body("email", "Email é necessário").exists({ checkFalsy: true })],
    [body("password", "Senha é necessária").exists({ checkFalsy: true })],
    userController.authenticate
);

router.get(
    "/",
    // unsureAuthenticated
    userController.getCalling
);

router.get(
    "/:id",
    [param("id", "ID é necessário").exists({ checkFalsy: true })],
    // unsureAuthenticated
    userController.get
);

router.get(
    "/getAll",
    // unsureAuthenticated
    userController.getAll
);

router.put(
    "/:id",
    [param("id", "ID é necessário").exists({ checkFalsy: true })],
    // unsureAuthenticated
    userController.update
);

router.delete(
    "/:id",
    [param("id", "ID é necessário").exists({ checkFalsy: true })],
    // unsureAuthenticated
    userController.remove
);

//Exporta o ROUTER
module.exports = router;