const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const activitySchema = new Schema({
  title: {
    type: String,
    required: true,
    // trim: true
  },
  bg_img: {
    type: String,
    // trim: true,
    default: ''
  },
  description: {
    type: String,
    default: ''
  },
  location: {
    type: String,
    default: ''
  },
  date: {
    type: Date
  },
  created_by: {
    type: Schema.Types.ObjectId,
    ref: 'User', // References the User model
    default: null
  },
  participants: [{
    type: Schema.Types.ObjectId,
    ref: 'User', // References the User model
    default: []
  }],
  imageURL:[{
    
  }],
  created_at: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Activity', activitySchema);
