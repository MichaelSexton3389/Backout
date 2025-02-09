const express = require("express");
const Club = require("../models/club");
const authMiddleware = require("../middleware/auth");
const clubRouter = express.Router();

// Create Club Route
clubRouter.post("/api/clubs", authMiddleware, async (req, res) => {
    try {
        const { name, description } = req.body;
        const admin_id = req.user.id;

        if (!name) {
            return res.status(400).json({ msg: "Club name is required." });
        }

        const newClub = new Club({
            name,
            description,
            admin_id
        });

        const savedClub = await newClub.save();
        res.status(201).json(savedClub);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Get All Clubs Route
clubRouter.get("/api/clubs", async (req, res) => {
    try {
        const clubs = await Club.find().populate("admin_id", "name email");
        res.status(200).json(clubs);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Get Single Club by ID Route
clubRouter.get("/api/clubs/:id", async (req, res) => {
    try {
        const clubId = req.params.id;
        const club = await Club.findById(clubId).populate("admin_id", "name email");

        if (!club) {
            return res.status(404).json({ msg: "Club not found." });
        }

        res.status(200).json(club);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Update Club Route (Only Admin Can Update)
clubRouter.put("/api/clubs/:id", authMiddleware, async (req, res) => {
    try {
        const clubId = req.params.id;
        const userId = req.user.id;
        const { name, description, admin_id } = req.body;

        const club = await Club.findById(clubId);
        if (!club) {
            return res.status(404).json({ msg: "Club not found." });
        }

        if (club.admin_id.toString() !== userId) {
            return res.status(403).json({ msg: "Unauthorized: Only the club admin can update this club." });
        }

        if (name) club.name = name;
        if (description) club.description = description;
        if (admin_id) club.admin_id = admin_id;

        await club.save();
        res.status(200).json({ msg: "Club updated successfully.", club });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Delete Club Route (Only Admin Can Delete)
clubRouter.delete("/api/clubs/:id", authMiddleware, async (req, res) => {
    try {
        const clubId = req.params.id;
        const userId = req.user.id;

        const club = await Club.findById(clubId);
        if (!club) {
            return res.status(404).json({ msg: "Club not found." });
        }

        if (club.admin_id.toString() !== userId) {
            return res.status(403).json({ msg: "Unauthorized: Only the club admin can delete this club." });
        }

        await Club.findByIdAndDelete(clubId);
        res.status(200).json({ msg: "Club deleted successfully." });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = clubRouter;
