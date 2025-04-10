import 'package:BackOut/models/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(id: '', name: '', email: '', token: '', password: '', profilePicture: '', bio:'');

  User get user => _user;

  void setUser(String userJson) {
    _user = User.fromJson(userJson);
    print("User loaded: ${_user.toJson()}"); // ✅ Debugging line
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  void updateProfilePictures(String newPictures) {
    _user = User(
      id: _user.id,
      name: _user.name,
      email: _user.email,
      token: _user.token,
      password: _user.password,
      profilePicture: newPictures, // ✅ Update profile pictures
      bio: _user.bio,
    );
    notifyListeners();
  }
}