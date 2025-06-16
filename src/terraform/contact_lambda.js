var aws = require("aws-sdk");

var ses = new aws.SES({ region: "eu-north-1" });

var RECEIVER = "epicreads7+1@gmail.com";
var SENDER = "epicreads7@gmail.com";

var response = {
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  },
  "isBase64Encoded": false,
  "body": "{ \"result\": \"Success\" \n}"
};

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

  await ses.sendEmail(params).promise();
};