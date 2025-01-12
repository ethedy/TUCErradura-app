import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/login_screen.dart';

//Se crea un popup de forma global que pueda aparecer en cualquier pantalla,
//sin importar en qué parte de la aplicación te encuentres.

class SessionManager with ChangeNotifier {
  BuildContext? _context;

  // Registrar el contexto en el que se desea mostrar el popup
  void setContext(BuildContext context) {
    _context = context;
  }

  // Función para verificar si el token ha expirado
  Future<void> checkSessionExpiration(Config config) async {
    final token = await config.authToken;
    if (token == null) {
      // Si el token ha expirado o no existe, muestra el popup
      _showSessionExpiredDialog();
    } else {
      // Si el token está presente, verificamos el rol
      String? role = await config.fetchUserRole();

      if (role == null) {
        // Si no se pudo obtener el rol (nulo), muestra el mensaje de error
        _showSessionExpiredDialog();
      } else {
        // Aquí puedes manejar la lógica basada en el rol del usuario
        if (role == Config.adminRole) {
          // Lógica para el administrador (puedes redirigir o mostrar un popup específico)
          print("Rol: Admin");
        } else if (role == Config.userRole) {
          // Lógica para el usuario normal
          print("Rol: User");
        }
      }
    }
  }

  // Función para mostrar el dialogo de sesión expirada
  void _showSessionExpiredDialog() {
    if (_context == null) return;

    showDialog(
      context: _context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sesión Expirada'),
          content: Text(
              'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Usamos Navigator para redirigir al login screen
                Navigator.pushReplacement(
                  _context!,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
