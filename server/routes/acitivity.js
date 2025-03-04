const express = require("express");
const Activity = require("../models/activity");
const authMiddleware = require("../middleware/userAuth"); // Middleware for authentication
const activityRouter = express.Router();

// Create Activity Route
activityRouter.post("/api/activities", authMiddleware, async (req, res) => {
    try {
        const { title, description, location, date } = req.body;
        const userId = req.user.id; // Extract user ID from the authenticated request

        if (!title) {
            return res.status(400).json({ msg: "Title is required." });
        }

        const newActivity = new Activity({
            title,
            description,
            location,
            date,
            created_by: userId,
        });

        const savedActivity = await newActivity.save();
        res.status(201).json(savedActivity);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Join Activity and Check for Pals
activityRouter.post("/join-activity", authMiddleware, async (req, res) => {
    const { userId, activityId } = req.body;
  
    try {
        // Add activity to user's list if not already there
        await User.findByIdAndUpdate(userId, { $addToSet: { activities: activityId } });

        // Find all users who have attended this activity
        const participants = await User.find({ activities: activityId });

        for (let participant of participants) {
            if (participant._id.toString() !== userId) {
                // Check if they are already pals
                const isAlreadyPals = await User.findOne({
                    _id: userId,
                    pals: participant._id,
                });

                if (!isAlreadyPals) { // Only add them as pals if they aren't already pals
                    // Count how many activities they have in common
                    const commonActivities = await User.findOne({
                        _id: userId,
                        activities: { $in: participant.activities },
                    });

                    if (commonActivities.activities.length >= 3) {
                        // Ensure a mutual pal connection
                        await User.findByIdAndUpdate(userId, { $addToSet: { pals: participant._id } });
                        await User.findByIdAndUpdate(participant._id, { $addToSet: { pals: userId } });
                    }
                }
            }
        }

        res.json({ success: true, message: "Joined activity and checked for mutual pals!" });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// Get Activity Route
activityRouter.get("/api/activities/:id", authMiddleware, async (req, res) => {
    try {
        const activityId = req.params.id;
        const activity = await Activity.findById(activityId).populate("created_by", "name email");

        if (!activity) {
            return res.status(404).json({ msg: "Activity not found." });
        }

        res.status(200).json(activity);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Get All Activities Created by a User
activityRouter.get("/api/user/activities", authMiddleware, async (req, res) => {
    try {
        const userId = req.user.id;
        const activities = await Activity.find({ created_by: userId });
        res.status(200).json(activities);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Delete Activity Route
activityRouter.delete("/api/activities/:id", authMiddleware, async (req, res) => {
    try {
        const activityId = req.params.id;
        const userId = req.user.id;

        const activity = await Activity.findById(activityId);
        if (!activity) {
            return res.status(404).json({ msg: "Activity not found." });
        }

        // Ensure the user deleting is the creator
        if (activity.created_by.toString() !== userId) {
            return res.status(403).json({ msg: "Unauthorized: You can only delete your own activities." });
        }

        await Activity.findByIdAndDelete(activityId);
        res.status(200).json({ msg: "Activity deleted successfully." });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = activityRouter;
