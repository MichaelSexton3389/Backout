const express = require("express");
const userRouter = express.Router();
const User = require("../models/user");
const authMiddleware= require("../middleware/userAuth")

userRouter.get("/users", async (req, res) => {
    try {
        const users = await User.find({}, { name: 1, _id: 1, profile_picture: 1 }); // Fetch only names and IDs
        res.json(users);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});



userRouter.put('/update-photo', authMiddleware, async (req, res) => {
    try {
        const { userId, photoUrl } = req.body;

        if (!userId || !photoUrl) {
            return res.status(400).json({ message: 'Missing userId or photoUrl' });
        }

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { profile_picture: photoUrl },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.json({ message: 'Profile photo updated successfully', user: updatedUser });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

module.exports = userRouter; 