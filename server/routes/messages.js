const express = require("express");
const Message = require("../models/message");

const messageRouter = express.Router();

// ✅ API route to fetch messages
messageRouter.get("/messages/:sender/:receiver", async (req, res) => {
    try {
        const { sender, receiver } = req.params;
        const messages = await Message.find({
            $or: [
                { sender: sender, receiver: receiver },
                { sender: receiver, receiver: sender }
            ]
        }).sort({ timestamp: 1 });

        res.json(messages);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ✅ WebSocket message handling function
function setupMessageSocket(io) {
    io.on("connection", (socket) => {
        console.log("User connected:", socket.id);

        socket.on("sendMessage", async (data) => {
            console.log("Message received:", data);

            try {
                // ✅ Save message to MongoDB
                const newMessage = new Message({
                    sender: data.sender,
                    receiver: data.receiver,
                    message: data.message
                });
                await newMessage.save();

                io.emit("receiveMessage", data); // ✅ Broadcast message to all users
            } catch (err) {
                console.error("Error saving message:", err);
            }
        });

        socket.on("disconnect", () => {
            console.log("User disconnected:", socket.id);
        });
    });
}

module.exports = { messageRouter, setupMessageSocket };