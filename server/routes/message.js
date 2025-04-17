const express = require("express");
const router = express.Router();
const Message = require("../models/message");
const { uploadImage } = require("../services/storage");

// Use consistent naming and exports
module.exports = {
  messageRouter: router,
  setupMessageSocket
};

// Then in your main server file (e.g., app.js or server.js), import correctly:
// const { messageRouter, setupMessageSocket } = require('./routes/message');
// app.use('/api', messageRouter);

// ✅ API route to send a message
router.post("/sendMessage", async (req, res) => {
  try {
    const { sender, receiver, message, isImage } = req.body;

    // Save the message to MongoDB
    const newMessage = new Message({
      sender,
      receiver,
      message,
      isImage: isImage || false,
      timestamp: new Date().toISOString(),
    });

    const savedMessage = await newMessage.save();
    console.log("Message saved via API:", savedMessage._id);

    res.status(201).json(savedMessage);
  } catch (error) {
    console.error("Error saving message via API:", error);
    res.status(500).json({ error: "Failed to send message" });
  }
});

// GET messages between two users
router.get("/messages/:sender/:receiver", async (req, res) => {
  const { sender, receiver } = req.params;

  try {
    const messages = await Message.find({
      $or: [
        { sender, receiver },
        { sender: receiver, receiver: sender },
      ],
    }).sort({ timestamp: 1 });

    console.log(`Fetched ${messages.length} messages between ${sender} and ${receiver}`);
    res.json(messages);
  } catch (error) {
    console.error("Error fetching messages:", error);
    res.status(500).json({ error: "Failed to fetch messages" });
  }
});

// ✅ WebSocket message handling function
function setupMessageSocket(io) {
  io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    socket.on("sendMessage", async (data) => {
      console.log("Message received via socket:", data);

      try {
        // Save message to MongoDB with all fields
        const newMessage = new Message({
          sender: data.sender,
          receiver: data.receiver,
          message: data.message || "",
          imageUrl: data.imageUrl || "",
          timestamp: data.timestamp || new Date().toISOString()
        });
        
        const savedMessage = await newMessage.save();
        console.log("Message saved to DB:", savedMessage._id);

        // Broadcast to all clients
        io.emit("receiveMessage", {
          sender: data.sender,
          receiver: data.receiver,
          message: data.message || "",
          imageUrl: data.imageUrl || "",
          timestamp: data.timestamp || new Date().toISOString()
        });
      } catch (err) {
        console.error("Error saving message:", err);
      }
    });

    // Handle typing events...
    socket.on("typing", (data) => {
      socket.broadcast.emit("typing", data);
    });

    socket.on("stopTyping", (data) => {
      socket.broadcast.emit("stopTyping", data);
    });

    socket.on("disconnect", () => {
      console.log("User disconnected:", socket.id);
    });
  });
}

module.exports = { messageRouter:  router, setupMessageSocket };