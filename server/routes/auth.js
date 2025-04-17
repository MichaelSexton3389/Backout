const express = require("express");
const bcryptjs = require("bcryptjs");
const User = require("../models/user");
const jwt = require("jsonwebtoken");
const authRouter = express.Router();

// Sign up route
authRouter.post("/api/signup", async (req, res) => {
    console.log("[SIGNUP] Received signup request:", req.body);

    try {
        const { name, email, password } = req.body;
        
        console.log("[SIGNUP] Checking if user exists with email:", email);
        const existingUser = await User.findOne({ email });

        if (existingUser) {
            console.log("[SIGNUP] User already exists:", email);
            return res.status(400).json({ msg: "A user with that email already exists!" });
        }

        console.log("[SIGNUP] Hashing password...");
        const hashedPassword = await bcryptjs.hash(password, 8);

        console.log("[SIGNUP] Creating new user document...");
        let user = new User({
            email,
            password: hashedPassword,
            name
        });

        console.log("[SIGNUP] Saving user to database...");
        user = await user.save();
        console.log("[SIGNUP] User saved successfully:", user._id);

        res.json(user);
    } catch (e) {
        console.error("[SIGNUP] Error during signup:", e.message);
        res.status(500).json({ error: e.message });
    }
});

// Sign In Route
authRouter.post("/api/signin", async (req, res) => {
    console.log("[SIGNIN] Received signin request:", req.body);

    try {
        const { email, password } = req.body;
        
        console.log("[SIGNIN] Searching for user with email:", email);
        const user = await User.findOne({ email });

        if (!user) {
            console.log("[SIGNIN] No user found with email:", email);
            return res.status(400).json({ msg: "A user with that email does not exist!" });
        }

        console.log("[SIGNIN] Comparing passwords...");
        const isMatch = await bcryptjs.compare(password, user.password);

        if (!isMatch) {
            console.log("[SIGNIN] Password mismatch for user:", email);
            return res.status(400).json({ msg: "Incorrect password." });
        }

        console.log("[SIGNIN] Password matched. Signing token...");
        const token = jwt.sign({ id: user._id }, "passwordKey");

        console.log("[SIGNIN] Signin successful, sending response.");
        res.json({ token, ...user._doc });
    } catch (e) {
        console.error("[SIGNIN] Error during signin:", e.message);
        res.status(500).json({ error: e.message });
    }
});

// Signout route
authRouter.post("/api/signout", async (req, res) => {
    console.log("[SIGNOUT] Received signout request.");

    try {
        res.status(200).json({ message: "Sign out successful" });
    } catch (e) {
        console.error("[SIGNOUT] Error during signout:", e.message);
        res.status(500).json({ error: e.message });
    }
});

module.exports = authRouter;
