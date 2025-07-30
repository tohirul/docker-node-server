const express = require("express");
const dotenv = require("dotenv");
const morgan = require("morgan");
const cors = require("cors");
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());
app.use(morgan("dev"));
dotenv.config({ path: "./.env", quiet: true });

app.get("/", (req, res) => {
  res.status(200).send({
    success: true,
    message: "Server is online!!!",
  });
});

app.get("/test", (req, res) => {
  res.status(200).send({
    success: true,
    message: "Test route is working!!!",
  });
});

app.get("/health", (req, res) => {
  res.status(200).send({
    success: true,
    message: "Server is healthy!!!",
  });
});

app.get("/user", (req, res) => {
  res.status(200).send({
    success: true,
    message: "User route is working!!!",
    data: [
      {
        name: "John Doe",
        email: "johndoe@gmail.com",
      },
      {
        name: "John Doe",
        email: "johndoe@gmail.com",
      },
      {
        name: "Tohirul Islam",
        email: "tohirul.islam164@gmail.com",
      },
    ],
  });
});

app.listen(process.env.CONTAINER_PORT, () => {
  console.log(
    `Server is running on CONTAINER_PORT: ${process.env.CONTAINER_PORT} LOCAL_PORT: ${process.env.LOCAL_PORT}`
  );
  console.log(`URI: http://localhost:${process.env.LOCAL_PORT}`);
});
