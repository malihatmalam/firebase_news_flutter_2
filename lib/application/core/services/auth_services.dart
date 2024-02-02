
import 'dart:io';

import 'package:flutter/cupertino.dart';

class AuthService extends ChangeNotifier{
  bool _isLogin = true;
  bool _isAuthenticating = false;
  String _enteredEmail = "";
  String _enteredPassword = "";
  String _enteredUsername = "";
  File? _pickImage;

  void changeAuthImage(File image){
    _pickImage = image;
    notifyListeners();
  }

  void changeIsLogin(){
    _isLogin = !_isLogin;
    notifyListeners();
  }

  void changeIsAuthenticating(){
    _isAuthenticating = !_isAuthenticating;
    notifyListeners();
  }

  void setEnteredEmail(email){
    _enteredEmail = email;
    notifyListeners();
  }

  void setEnteredPassword(password){
    _enteredPassword = password;
    notifyListeners();
  }

  void setEnteredUsername(username){
    _enteredUsername = username;
    notifyListeners();
  }

  File? getTempAuthImage() => _pickImage;

  bool getIsLogin() => _isLogin;

  bool getIsAuthenticating() => _isAuthenticating;

  String? getEnteredUsername() => _enteredUsername;

  String? getEnteredPassword() => _enteredPassword;

  String? getEnteredEmail() => _enteredEmail;
}
