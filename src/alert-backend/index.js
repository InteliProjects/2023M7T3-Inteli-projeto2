var amqp = require("amqplib/callback_api");
require("dotenv").config()

amqp.connect("amqp://localhost:5672", function (err, conn) {
  conn.createChannel(function (err, ch) {
    var exchange = "topic_logs";
    ch.assertExchange(exchange, "topic", { durable: false });

    // Crie uma fila anônima exclusiva para receber mensagens
    ch.assertQueue("", { exclusive: true }, function (err, q) {
      if (err) throw err;

      // Bind a fila à troca com um padrão de roteamento específico
      var topic = "alert";
      ch.bindQueue(q.queue, exchange, topic);

      ch.prefetch(1);
      console.log(
        " [*] Waiting for messages with topic '%s'. To exit press CTRL+C",
        topic
      );
      ch.consume(
        q.queue,
        function (msg) {
          console.log(" [x] Received %s", msg.content.toString());

          payload = JSON.stringify({
            content: "",
            embeds: [
              {
                title: "Alerta Recebido",
                description: `${msg.content.toString()}`,
                color: 16711680,
              },
            ],
          });

          //Gerando as opções da requisição que irá disparar o alerta
          const options = {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: payload,
          };

          //Enviando o alerta
          try {
            const response = fetch(process.env.URL_WEBHOOK, options);
          } catch (err) {
            console.log(err);
          }
        },
        { noAck: true }
      );
    });
  });
});
