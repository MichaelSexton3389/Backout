const express = require("express");
const userRouter = express.Router();
const User = require("../models/user");
const Activity = require("../models/activity");
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

// In your user route file (e.g., routes/user.js)
userRouter.get('/user/:id', async (req, res) => {
    try {
      const user = await User.findById(req.params.id).select('-password'); // exclude sensitive fields
      if (!user) return res.status(404).send({ message: 'User not found' });
      res.json({ user });
    } catch (err) {
      res.status(500).send({ error: 'Internal Server Error' });
    }
  });

// ✅ Update Profile Picture
userRouter.put('/update-photo', async (req, res) => {
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
userRouter.put('/update-bio', async (req, res) => {
    try {
        console.log("Request body:", req.body); //debugging
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

userRouter.get("/:userId/pal-count", async (req, res) => {
    try {
      const user = await User.findById(req.params.userId);
      res.json({ palCount: user.pals.length });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

userRouter.get("/:userId/activity-count", async (req, res) => {
    try {
      const user = await User.findById(req.params.userId);
      res.json({ activityCount: user.activities.length });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
});

// Get list of all pals for a particular user
userRouter.get("/:userId/pals", async (req, res) => {
    try {
        // Find the user by ID and populate the 'pals' field with select details
        const user = await User.findById(req.params.userId).populate("pals", "name profile_picture bio");
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }
        // If no pals, return a message indicating no buddies
        if (!user.pals || user.pals.length === 0) {
            return res.json({ message: "No offense, but your social circle is a dot. Let's expand that." });
        }
        res.json({ pals: user.pals });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

userRouter.get("/:userId/upcoming-activity-details", async (req, res) => {
  try {
    const userId = req.params.userId;

    const user = await User.findById(userId);
    if (!user || !user.activities || user.activities.length === 0) {
      return res.status(404).json({ msg: "No activities found for this user." });
    }

    const activities = await Activity.find({
      _id: { $in: user.activities },
      date: { $gte: new Date() } // Only fetch future activities
    }).populate("created_by", "name email");

    const mappedActivities = activities.map(activity => ({
      _id: activity._id,
      title: activity.title,
      bg_img: activity.bg_img,
      description: activity.description,
      location: activity.location,
      date: activity.date,
      created_by: activity.created_by,
      participants: activity.participants,
      imageURL: activity.imageURL,
      created_at: activity.created_at
    }));

    res.status(200).json({ activities: mappedActivities });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

userRouter.get("/:userId/past-activities", async (req, res) => {
  try {
    const userId = req.params.userId;

    const user = await User.findById(userId);
    if (!user || !user.activities || user.activities.length === 0) {
      return res.status(404).json({ msg: "No activities found for this user." });
    }

    const activities = await Activity.find({
      _id: { $in: user.activities },
      date: { $lt: new Date() } // Only past activities
    }).populate("created_by", "name email");

    const mappedActivities = activities.map(activity => ({
      _id: activity._id,
      title: activity.title,
      bg_img: activity.bg_img,
      description: activity.description,
      location: activity.location,
      date: activity.date,
      created_by: activity.created_by,
      participants: activity.participants,
      imageURL: activity.imageURL,
      created_at: activity.created_at
    }));

    res.status(200).json({ activities: mappedActivities });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

userRouter.get("/:userId/pals/upcoming-activity-details", async (req, res) => {
  try {
    const userId = req.params.userId;

    // Get user and populate pals' activity lists
    const user = await User.findById(userId).populate({
      path: "pals",
      populate: {
        path: "activities",
        match: { date: { $gte: new Date() } }, // only future activities
        populate: {
          path: "created_by",
          select: "name email"
        }
      }
    });

    if (!user || !user.pals || user.pals.length === 0) {
      return res.status(404).json({ msg: "This user has no pals." });
    }

    const results = user.pals.map(pal => ({
      _id: pal._id,
      name: pal.name,
      profile_picture: pal.profile_picture,
      bio: pal.bio,
      upcoming_activities: (pal.activities || []).map(activity => ({
        _id: activity._id,
        title: activity.title,
        bg_img: activity.bg_img,
        description: activity.description,
        location: activity.location,
        date: activity.date,
        created_by: activity.created_by,
        participants: activity.participants,
        imageURL: activity.imageURL,
        created_at: activity.created_at
      }))
    }));

    const filteredResults = results.filter(pal => pal.upcoming_activities.length > 0);

    if (filteredResults.length === 0) {
      return res.status(200).json({ message: "No activity to show", palsWithUpcomingActivities: [] });
    }

    res.status(200).json({ palsWithUpcomingActivities: filteredResults });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

userRouter.get("/:userId/pals/past-activity-details", async (req, res) => {
  try {
    const userId = req.params.userId;

    const user = await User.findById(userId).populate({
      path: "pals",
      populate: {
        path: "activities",
        match: { date: { $lt: new Date() } }, // Only past activities
        populate: {
          path: "created_by",
          select: "name email"
        }
      }
    });

    if (!user || !user.pals || user.pals.length === 0) {
      return res.status(404).json({ msg: "This user has no pals." });
    }

    const results = user.pals.map(pal => ({
      _id: pal._id,
      name: pal.name,
      profile_picture: pal.profile_picture,
      bio: pal.bio,
      past_activities: (pal.activities || []).map(activity => ({
        _id: activity._id,
        title: activity.title,
        bg_img: activity.bg_img,
        description: activity.description,
        location: activity.location,
        date: activity.date,
        created_by: activity.created_by,
        participants: activity.participants,
        imageURL: activity.imageURL,
        created_at: activity.created_at
      }))
    }));

    res.status(200).json({ palsWithPastActivities: results });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

userRouter.patch('/:userId/streak', async (req, res) => {
  try {
    const user = await User.findById(req.params.userId, 'Streak');
    if (!user) return res.status(404).json({ msg: 'User not found' });

    const nowDate = stripTime(new Date());
    const lastDate = stripTime(user.Streak.lastChanged);

    let newCount;
    if (+lastDate === +nowDate) {
      // already updated today → do nothing
      newCount = user.Streak.current;
    } else if (+lastDate === +new Date(nowDate - 24*3600*1000)) {
      // lastChanged was exactly yesterday → increment
      newCount = user.Streak.current + 1;
    } else {
      // gap of ≥2 days → reset to 0
      newCount = 0;
    }

    user.Streak.current = newCount;
    user.Streak.lastChanged = new Date();
    await user.save();

    res.json(user.Streak);
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// GET badges list
userRouter.get('/:userId/badges', async (req, res) => {
  try {
    const user = await User.findById(req.params.userId, 'Badges');
    if (!user) return res.status(404).json({ msg: 'User not found' });
    res.json(user.Badges);
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});

// PATCH add a badge (no duplicates)
userRouter.patch('/:userId/badges', async (req, res) => {
  try {
    const { badge } = req.body;
    if (!badge) return res.status(400).json({ msg: 'Badge is required' });

    const updated = await User.findByIdAndUpdate(
      req.params.userId,
      { $addToSet: { Badges: badge } },
      { new: true, select: 'Badges' }
    );
    if (!updated) return res.status(404).json({ msg: 'User not found' });

    res.json(updated.Badges);
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: 'Server error' });
  }
});




module.exports = userRouter;