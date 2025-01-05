import 'package:flutter/material.dart';

class Config with ChangeNotifier {
  // URL de la API
  String apiUrl = 'http://localhost:3000';

  // Roles de usuario
  static const String adminRole = 'admin';
  static const String userRole = 'user';

  // Método para cambiar la URL de la API y notificar a los widgets
  void setApiUrl(String url) {
    apiUrl = url;
    notifyListeners();
  }

  // Método para obtener las puertas disponibles desde el servidor
  String get doorsEndpoint =>
      '$apiUrl/doors'; // Retorna la URL para las puertas

  // Método para obtener el endpoint de abrir una puerta
  String get openDoorEndpoint =>
      '$apiUrl/door/open'; // Retorna el endpoint para abrir una puerta

  // Método para obtener el endpoint de login
  String get loginEndpoint => '$apiUrl/login'; // Retorna la URL para el login

  // Método para obtener el endpoint de usuarios
  String get usuariosEndpoint => '$apiUrl/users';

  // Método para obtener el endpoint de usuarios
  String get addUserEndpoint => '$apiUrl/AddUser';

  //Mètodo para eliminar usuario
  String get deleteUser => '$apiUrl/DeleteUser';
}
