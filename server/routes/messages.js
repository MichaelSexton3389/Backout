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
    io.on('connection', (socket) => {
        console.log('User connected');
    
        socket.on('sendMessage', async (data) => {
            try {
                const { sender, receiver, message, imageUrl } = data;
    
                const newMessage = new Message({
                    sender,
                    receiver,
                    message,
                    imageUrl, // Store the image URL
                });
    
                await newMessage.save();
    
                io.to(receiver).emit('receiveMessage', {
                    sender,
                    receiver,
                    message,
                    imageUrl,
                    timestamp: new Date().toISOString(),
                });
            } catch (error) {
                console.error('Error saving message:', error);
            }
        });

        socket.on('sendImageMessage', async (data) => {
            try {
                const { sender, receiver, message, imageUrl } = data;
    
                const newMessage = new Message({
                    sender,
                    receiver,
                    message,
                    imageUrl, // Store the image URL
                });
    
                await newMessage.save();
    
                io.to(receiver).emit('receiveMessage', {
                    sender,
                    receiver,
                    message,
                    imageUrl,
                    timestamp: new Date().toISOString(),
                });
            } catch (error) {
                console.error('Error saving message:', error);
            }
        });
    
        socket.on('disconnect', () => {
            console.log('User disconnected');
        });
    });    
}

module.exports = { messageRouter, setupMessageSocket };