import 'package:flutter/material.dart';
import 'package:flutter_application_1/HttpService.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Config with ChangeNotifier {
  // URL de la API
  String apiUrl = 'http://localhost:3000';

  // Roles de usuario
  static const String adminRole = 'admin';
  static const String userRole = 'user';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Método para establecer el token de forma segura
  Future<void> setAuthToken(String token, String role) async {
    // Verificar el rol para determinar el tiempo de expiración
    Duration expirationDuration = Duration(minutes: 15); // Default para user
    if (role == adminRole) {
      expirationDuration = Duration(minutes: 60); // Para admin
    }

    // Calcula la hora de expiración según el rol
    final expirationTime =
        DateTime.now().add(expirationDuration).toIso8601String();

    await _secureStorage.write(key: 'authToken', value: token); // Guardar token
    await _secureStorage.write(
        key: 'authTokenExpiration',
        value: expirationTime); // Guardar expiración
    await _secureStorage.write(
        key: 'userRole', value: role); // Guardar el rol del usuario
    notifyListeners(); // Notificar a los oyentes
  }

  // Método para obtener el token de forma segura
  Future<String?> get authToken async {
    final token = await _secureStorage.read(key: 'authToken');
    final expirationTimeStr =
        await _secureStorage.read(key: 'authTokenExpiration');

    if (token == null || expirationTimeStr == null) {
      return null; // Si no hay token o expiración, no está autenticado
    }

    final expirationTime = DateTime.parse(expirationTimeStr);

    // Si el token ha expirado, eliminamos el token y retornamos null
    if (DateTime.now().isAfter(expirationTime)) {
      await clearAuthToken(); // Borra el token si ha expirado
      return null; // El token ha expirado
    }

    return token; // Si no ha expirado, retorna el token
  }

// Método para obtener el rol de usuario
  Future<String?> fetchUserRole() async {
    return await _secureStorage.read(key: 'userRole');
  }

  // Método para borrar el token de forma segura
  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: 'authToken'); // Borra el token
    await _secureStorage.delete(
        key: 'authTokenExpiration'); // Borra la expiración
    await _secureStorage.delete(key: 'userRole'); // Borra el rol
    notifyListeners(); // Notifica a los oyentes
  }

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

  // Método para obtener el endpoint de usuarios (nombres)
  String get usuariosEndpoint => '$apiUrl/users';

  // Endpoint para obtener la información del usuario
  String get infoBaseDatos => '$apiUrl/infoBaseDatos';

  //Mètodo para eliminar usuario
  String get deleteUser => '$apiUrl/DeleteUser';

  // Método para obtener el endpoint de usuarios
  String get addUserEndpoint => '$apiUrl/AddUser';

  // Metodo para editar el usuario
  String get editUser => '$apiUrl/editUser';

  //Mètodo para cambiar contraseña
  String get modifyPassword => '$apiUrl/changePassword';

  // Método para verificar la autenticación
  Future<bool> get isAuthenticated async {
    final token = await authToken;
    return token != null; // Verifica si el token existe
  }

  // Método común para validar el token antes de hacer cualquier solicitud
  Future<void> _ensureAuthenticated() async {
    final token =
        await authToken; // Llama al getter que ya verifica si el token ha expirado

    if (token == null) {
      throw Exception(
          "No se encontro ningun token. Por Favor autentiquese primero.");
    }
  }

  // Método para hacer una solicitud GET con el token
  Future<http.Response> getRequest(String endpoint) async {
    await _ensureAuthenticated(); // Verifica que el usuario esté autenticado
    final token = await authToken;
    return await HttpService().getRequest(endpoint, token!);
  }

  // Método para hacer una solicitud POST con el token
  Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    await _ensureAuthenticated(); // Verifica que el usuario esté autenticado
    final token = await authToken;
    return await HttpService().postRequest(Uri.parse(endpoint), data, token!);
  }

  // Método para hacer una solicitud DELETE con el token
  Future<http.Response> deleteRequest(String endpoint) async {
    await _ensureAuthenticated(); // Verifica que el usuario esté autenticado
    final token = await authToken;
    return await HttpService().deleteRequest(endpoint, token!);
  }
}
