import 'package:flutter/material.dart';
import 'package:flutter_application_1/HttpService.dart';
import 'package:http/http.dart' as http;

class Config with ChangeNotifier {
  // URL de la API
  String apiUrl = 'http://localhost:3000';

  // Roles de usuario
  static const String adminRole = 'admin';
  static const String userRole = 'user';

  // El token se guardará aquí
  String? _authToken;

  // Método para establecer el token
  void setAuthToken(String token) {
    _authToken = token;
    notifyListeners();
  }

  // Método para obtener el token
  String? get authToken => _authToken;

  // Método para cambiar la URL de la API y notificar a los widgets
  void setApiUrl(String url) {
    apiUrl = url;
    notifyListeners();
  }

  //ENDPOINTS
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

  //Mètodo para eliminar usuario
  String get deleteUser => '$apiUrl/DeleteUser';

  // Método para obtener el endpoint de usuarios
  String get addUserEndpoint => '$apiUrl/AddUser';

  //Mètodo para cambiar contraseña
  String get modifyPassword => '$apiUrl/changePassword';

  // Método para verificar la autenticación
  bool get isAuthenticated => _authToken != null;

  // Método común para validar el token antes de hacer cualquier solicitud
  Future<void> _ensureAuthenticated() async {
    if (_authToken == null) {
      throw Exception("No token found. Please authenticate first.");
    }
  }

  // Método para hacer una solicitud GET con el token
  Future<http.Response> getRequest(String endpoint) async {
    await _ensureAuthenticated(); // Verifica que el usuario esté autenticado
    return await HttpService().getRequest(endpoint, _authToken!);
  }

  // Método para hacer una solicitud POST con el token
  Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    await _ensureAuthenticated(); // Verifica que el usuario esté autenticado
    return await HttpService()
        .postRequest(Uri.parse(endpoint), data, _authToken!);
  }

  // Método para hacer una solicitud DELETE con el token
  Future<http.Response> deleteRequest(String endpoint) async {
    await _ensureAuthenticated(); // Verifica que el usuario esté autenticado
    return await HttpService().deleteRequest(endpoint, _authToken!);
  }
}
