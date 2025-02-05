const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const clubSchema = new Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    default: ''
  },
  admin_id: {
    type: Schema.Types.ObjectId,
    ref: 'User', // References the User model
    default: null
  },
  created_at: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Club', clubSchema);
