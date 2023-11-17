const mongoose = require('mongoose');
require('dotenv').config();

// Conecte-se ao banco de dados MongoDB
mongoose.connect(process.env.MONGO_URL, { useNewUrlParser: true, useUnifiedTopology: true });

// Defina um esquema para o documento que você deseja salvar
const Schema = mongoose.Schema;
const schemaAudios = new Schema({
  messageId: String,
  base64: String,
});

// Crie um modelo com base no esquema
const model = mongoose.model('audios', schemaAudios);

async function createAudio(messageId, base64) {
    const audio = new model({
        messageId: messageId,
        base64: base64,
    });
    
    try {
        await audio.save();
    } catch (err) {
        console.log(err)
        throw new Error("Error saving audio");
    }
}

async function getAudio(messageId) {
    try {
        const audio = model.find({ messageId: messageId });

        return audio.base64;

    } catch (err) {
        console.log(err)
        throw new Error("Error getting audio");
    }
}

module.exports = {
    createAudio,
    getAudio,
}