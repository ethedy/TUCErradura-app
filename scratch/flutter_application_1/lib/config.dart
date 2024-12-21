import 'package:flutter/material.dart';

class Config with ChangeNotifier {
  // URL de la API
  String apiUrl = 'http://localhost:3000/login';

  // Roles de usuario
  static const String adminRole = 'admin';
  static const String userRole = 'user';

  // Método para cambiar la URL de la API y notificar a los widgets
  void setApiUrl(String url) {
    apiUrl = url;
    notifyListeners();
  }
}
