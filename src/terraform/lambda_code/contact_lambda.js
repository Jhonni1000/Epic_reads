var aws = require("aws-sdk");
var ses = new aws.SES({ region: "eu-north-1" });

var RECEIVER = "epicreads7+1@gmail.com";
var SENDER = "epicreads7@gmail.com";

exports.handler = async function (event, context) {
  console.log("Received event:", event);
  console.log("In sendMail");

  var params = {
    Destination: {
      ToAddresses: [RECEIVER]
    },
    Message: {
      Body: {
        Text: {
          Data:
            "Full Name: " +
            event.name +
            "\nPhone: " +
            event.phone +
            "\nEmail: " +
            event.email +
            "\nMessage: " +
            event.message,
          Charset: "UTF-8"
        }
      },
      Subject: {
        Data: "Website Query Form: " + event.name,
        Charset: "UTF-8"
      }
    },
    Source: SENDER
  };

  try {
    await ses.sendEmail(params).promise();
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify({ result: "Success" })
    };
  } catch (error) {
    console.error("Error sending email:", error);
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify({ error: "Failed to send email" })
    };
  }
};