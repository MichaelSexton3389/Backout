const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const attendanceSchema = new Schema({
  user_id: {
    type: Schema.Types.ObjectId,
    ref: 'User', // References the User model
    required: true
  },
  activity_id: {
    type: Schema.Types.ObjectId,
    ref: 'Activity', // References the Activity model
    required: true
  },
  status: {
    type: Boolean,
    default: '' // e.g., "present", "absent", etc.
  },
  points_earned: {
    type: Number,
    default: 0
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Attendance', attendanceSchema);
