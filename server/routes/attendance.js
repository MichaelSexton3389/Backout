const express = require("express");
const Attendance = require("../models/attendance");
const Activity = require("../models/activity");
const authMiddleware = require("../middleware/userAuth");
const attendanceRouter = express.Router();

// Mark Attendance Route
attendanceRouter.post("/api/attendance", authMiddleware, async (req, res) => {
    try {
        const { activity_id, status, points_earned } = req.body;
        const user_id = req.user.id; // Extract user ID from the token

        if (!activity_id) {
            return res.status(400).json({ msg: "Activity ID is required." });
        }

        // Check if the activity exists
        const activity = await Activity.findById(activity_id);
        if (!activity) {
            return res.status(404).json({ msg: "Activity not found." });
        }

        const attendance = new Attendance({
            user_id,
            activity_id,
            status,
            points_earned
        });

        const savedAttendance = await attendance.save();
        res.status(201).json(savedAttendance);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Get Attendance for an Activity
attendanceRouter.get("/api/attendance/:activity_id", authMiddleware, async (req, res) => {
    try {
        const { activity_id } = req.params;
        const attendanceRecords = await Attendance.find({ activity_id }).populate("user_id", "name email");
        res.status(200).json(attendanceRecords);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = attendanceRouter;
