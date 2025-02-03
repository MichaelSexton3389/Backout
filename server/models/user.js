// CHANGE THIS FILE WITH ACTUAL DATABASE SCHEMA



const mongoose = require("mongoose");

const userSchema = mongoose.Schema({
    name : {
        required: true,
        type: String,
        trim: true
    },
    email : {
        required: true,
        type: String,
        trim: true,
        validate: { 
            validator: (value) => {
                const RegexEmailValidator =
                    /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
                return value.match(RegexEmailValidator);
            },
            message: "Please enter valid email address"
        }
    },
    password : {
        required: true,
        type: String
    }
});


const User = mongoose.model("User", userSchema);
module.exports = User;