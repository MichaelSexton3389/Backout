const express = require("express");
const userRouter = express.Router();
const User = require("../models/user");
const authMiddleware = require("../middleware/userAuth");

// ✅ Fetch Users (Now Includes Bio)
userRouter.get("/users", async (req, res) => {
    try {
        const users = await User.find({}, { name: 1, _id: 1, profile_picture: 1, bio: 1 });
        res.json(users);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ✅ Update Profile Picture
userRouter.put('/update-photo', authMiddleware, async (req, res) => {
    try {
        const { userId, photoUrl } = req.body;

        if (!userId || !photoUrl) {
            return res.status(400).json({ message: 'Missing userId or photoUrl' });
        }

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { profile_picture: photoUrl },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.json({ message: 'Profile photo updated successfully', user: updatedUser });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// Update Bio
userRouter.put('/update-bio', authMiddleware, async (req, res) => {
    try {
        const { userId, bio } = req.body;

        if (!userId || bio === undefined) {
            return res.status(400).json({ message: 'Missing userId or bio' });
        }

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            { bio: bio },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.json({ message: 'Bio updated successfully', user: updatedUser });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// Follow a user (Add Pal)
userRouter.post("/addPal", authMiddleware, async (req, res) => {
  const { userId, targetUserId } = req.body;

  try {
    // Add target user to the current user's pal list (if not already added)
    await User.findByIdAndUpdate(userId, { $addToSet: { pals: targetUserId } });

    // Add current user to the target user's pal list (ensure mutual connection)
    await User.findByIdAndUpdate(targetUserId, { $addToSet: { pals: userId } });

    res.json({ success: true, message: "Pals added successfully!" });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

userRouter.get("/user/:userId/pal-count", async (req, res) => {
    try {
      const user = await User.findById(req.params.userId);
      res.json({ palCount: user.pals.length });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });



module.exports = userRouter;