const express = require("express");
const Membership = require("../models/membership");
const Club = require("../models/club");
const authMiddleware = require("../middleware/userAuth");
const membershipRouter = express.Router();

// Follow (Join a Club)
membershipRouter.post("/api/clubs/:clubId/follow", authMiddleware, async (req, res) => {
    try {
        const userId = req.user.id;
        const clubId = req.params.clubId;

        // Check if the club exists
        const club = await Club.findById(clubId);
        if (!club) {
            return res.status(404).json({ msg: "Club not found." });
        }

        // Check if user is already a member
        const existingMembership = await Membership.findOne({ user_id: userId, club_id: clubId });
        if (existingMembership) {
            return res.status(400).json({ msg: "User is already a member of this club." });
        }

        // Create new membership
        const newMembership = new Membership({ user_id: userId, club_id: clubId });
        await newMembership.save();

        res.status(201).json({ msg: "Successfully joined the club." });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Unfollow (Leave a Club)
membershipRouter.delete("/api/clubs/:clubId/unfollow", authMiddleware, async (req, res) => {
    try {
        const userId = req.user.id;
        const clubId = req.params.clubId;

        // Check if membership exists
        const membership = await Membership.findOne({ user_id: userId, club_id: clubId });
        if (!membership) {
            return res.status(400).json({ msg: "User is not a member of this club." });
        }

        // Remove membership
        await Membership.findByIdAndDelete(membership._id);
        res.status(200).json({ msg: "Successfully left the club." });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = membershipRouter;
