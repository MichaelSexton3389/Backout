// BACKEND URL TO ACCESS DB, HOSTED REMOTELY SO YOU DO NOT NEED TO RUN LOCALLY:
// https://backout-server-952120514384.us-central1.run.app



const express = require("express");
const mongoose = require("mongoose");
const http= require("http");
const { Server } = require("socket.io");

const authRouter = require("./routes/auth");
const cors = require("cors");
const clubRouter = require("./routes/club");
const membershipRouter = require("./routes/membership");
const activityRouter = require("./routes/acitivity");
const attendanceRouter = require("./routes/attendance");
const userRouter= require("./routes/user");
const { messageRouter, setupMessageSocket } = require("./routes/messages");

const PORT = process.env.PORT || 5000;
const app = express();
const server= http.createServer(app);
const io= new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET","POST"]
    }
})

app.use(express.json());
app.use(cors());  
app.use(authRouter);
app.use(activityRouter)
app.use(attendanceRouter);
app.use(clubRouter);
app.use(membershipRouter);
app.use('/api/user', userRouter);
app.use(messageRouter);

setupMessageSocket(io);

app.get("/", (req, res) => {
  res.send("Hello from the backend server!");
});


const DB = "mongodb+srv://mise3389:Qtx2MwOzzmxEya8w@cluster1.d6p3k.mongodb.net/?retryWrites=true&w=majority&appName=Cluster1";

mongoose
  .connect(DB)
  .then(() => {
    console.log("Connected to MongoDB");
  })
  .catch((err) => {
    console.error("Error connecting to MongoDB:", err.message);
  });

// app.listen(PORT, "0.0.0.0", () => {
//     console.log(`connected at port ${PORT}`);
// });

io.on("connection", (socket) => {
    console.log("User connected:", socket.id);
  
    socket.on("sendMessage", (data) => {
      console.log("Message received:", data);
      io.emit("receiveMessage", data); // Broadcast message to all connected users
    });
  
    socket.on("disconnect", () => {
      console.log("User disconnected:", socket.id);
    });
  });

  server.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on port ${PORT}`);
  });
