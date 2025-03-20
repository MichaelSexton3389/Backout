// Color nameColor = Colors.white; // Default name color
//   Color counter_font= Colors.white;
//   Color counter_bg= Colors.black.withOpacity(0.5);
//   Color follow_font= Colors.black;
//   Color follow_bg= Colors.white;
//   String selectedFont = 'Roboto'; // Default font
//   FontWeight nameWeight= FontWeight.w100;
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const profileSchema = new Schema({
  nameColor: {
    type: Color,
    default: Colors.white 
  },
  counter_font: {
    type: Color,
    default: Colors.white
  },
  follow_font: {
    type: Color,
    default: Colors.black
  },
  follow_bg: {
    type: Color,
    default: Colors.black.withOpacity(0.5)
  },
  selectedFont: {
    type: Color,
    default: 'Roboto'
  },
  nameWeight: {
    type: Color,
    default: FontWeight.w100
  },
});

module.exports = mongoose.model('profile_config', profileSchema);
