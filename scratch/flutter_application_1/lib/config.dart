import 'package:flutter/material.dart';

class Config with ChangeNotifier {
  String apiUrl = 'http://localhost:3000/login';

  void setApiUrl(String url) {
    apiUrl = url;
    notifyListeners();
  }
}
