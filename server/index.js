const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");

const PORT = process.env.PORT || 3000;
const app = express();

app.use(express.json());
app.use(authRouter);

const DB = 
    "mongodb+srv://mise3389:nqMGBHs8fgtS4u0J@cluster1.d6p3k.mongodb.net/?retryWrites=true&w=majority&appName=Cluster1";

mongoose
    .connect(DB)
    .then(() => {
        console.log("Connection successful");
    })
    .catch(() =>{
        console.log(e);
    });

app.listen(PORT, "0.0.0.0", () => {
    console.log(`connected at port ${PORT}`);
});

