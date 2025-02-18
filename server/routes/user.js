const express = require("express");
const userRouter = express.Router();
const User = require("../models/user");

userRouter.get("/users", async (req, res) => {
    try {
        const users = await User.find({}, { name: 1, _id: 1 }); // Fetch only names and IDs
        res.json(users);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = userRouter; 