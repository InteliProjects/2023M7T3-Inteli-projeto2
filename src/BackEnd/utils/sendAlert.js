const amqp = require('amqplib/callback_api');

const send = (message) => {
  amqp.connect("amqp://localhost:5672", function (err, conn) {
    conn.createChannel(function (err, ch) {
      var exchange = "topic_logs";
      var topic = "alert";

      ch.assertExchange(exchange, "topic", { durable: false });

      try {
        ch.publish(exchange, topic, Buffer.from(message));
      } catch (err) {
        console.log(err)
        return
      }

      console.log("[x] Sent '%s' to topic '%s'", message, topic);

      setTimeout(function () {
        conn.close();
      }, 500);
    });
  });
};

module.exports = {
  send
}
