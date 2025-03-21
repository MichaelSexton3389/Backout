const express = require("express");
const bcryptjs = require("bcryptjs");
const User = require("../models/user");
const jwt = require("jsonwebtoken");
const authRouter = express.Router();


// Sign up route -> WORKING 

authRouter.post("/api/signup", async (req, res) =>  {
    console.log("Received signup request: ", req.body);

    try {
        const {name, email, password} = req.body;

        const existingUser = await User.findOne({email});

        if (existingUser) {
            return res
                .status(400)
                .json({msg: "A user with that email already exists!"});
        }

        const hashedPassword = await bcryptjs.hash(password, 8)

        let user = new User({
            email,
            password : hashedPassword,
            name
        });

        user = await user.save();
        res.json(user);
    }
    catch (e) {
        res
            .status(500)
            .json({error: e.message});
    }

});

// Sign In Route - finished, need to check if working

authRouter.post("/api/signin", async (req,res) => {
    try {
        const {email, password} = req.body;

        const user = await User.findOne({email});

        if (!user){
            return res
                .status(400)
                .json({msg: "A user with that email does not exist!"});
        }

        const isMatch = await bcryptjs.compare(password, user.password);

        if (!isMatch){
            return res
                    .status(400)
                    .json({msg:"Incorrect password."})
        }

        const token = jwt.sign({id: user._id}, "passwordKey");
        res.json({token, ...user._doc});
    }
    catch (e) {
        res
            .status(500)
            .json({error: e.message})
    }
})


// signout route

authRouter.post("/api/signout", async (req, res) => {
    try {
        res.status(200).json({ message: "Sign out successful" });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});



module.exports = authRouter;