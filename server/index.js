const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const cors = require("cors");
const clubRouter = require("./routes/club");
const membershipRouter = require("./routes/membership");
const activityRouter = require("./routes/acitivity");
const attendanceRouter = require("./routes/attendance");


const PORT = process.env.PORT || 3000;
const app = express();

app.use(express.json());
app.use(cors());  
app.use(authRouter);
app.use(activityRouter)
app.use(attendanceRouter);
app.use(clubRouter);
app.use(membershipRouter)
const DB = "mongodb+srv://Aryan:Nhibataunga25@cluster1.d6p3k.mongodb.net/?retryWrites=true&w=majority&appName=Cluster1";

mongoose
    .connect(DB)
    .then(() => {
        console.log("Connection successful");
    })
    .catch((e) =>{
        console.log(e);
    });

app.listen(PORT, "0.0.0.0", () => {
    console.log(`connected at port ${PORT}`);
});
