const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const membershipSchema = new Schema({
  club_id: {
    type: Schema.Types.ObjectId,
    ref: 'Club', // References the Club model
    required: true
  },
  user_id: {
    type: Schema.Types.ObjectId,
    ref: 'User', // References the User model
    required: true
  },
  joined_at: {
    type: Date,
    default: Date.now
  },
  role: {
    type: String,
    default: '' // For example: 'member', 'admin', etc.
  }
});

module.exports = mongoose.model('Membership', membershipSchema);
