const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const photoSchema = new Schema({
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
  image_path: {
    type: String,
    default: '' // URL to the photo
  },
  caption: {
    type: String,
    default: ''
  },
  uploaded_at: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Photo', photoSchema);
