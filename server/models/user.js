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
        unique: true,
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
    },
    profile_picture: {
        type: String,
        default:'' //setup a default image?
    },
    bio: {
        type: String,
        default: ''
    },

    pals: [{
         type: mongoose.Schema.Types.ObjectId,
          ref: "User"
         }], // Two-way pal connections
         
    activities: [{
         type: mongoose.Schema.Types.ObjectId,
          ref: "Activity"
         }], // Activity participation
    Streak: {
      current: {
        type: Number,
        default: 0
      },
      lastChanged: {
        type: Date,
        default: Date.now
      }
    },

    interest: [{
        type: String
    }],


    created_at: {
        type: Date,
        default: Date.now
  }
});


const User = mongoose.model("User", userSchema);
module.exports = User;