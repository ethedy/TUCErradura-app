import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screen_user.dart';
import 'package:flutter_application_1/screen_admin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Función para hacer la solicitud POST
  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    // Verificamos que los campos no estén vacíos
    if (email.isEmpty || password.isEmpty) {
      _showDialog(
        context,
        'Campos Vacíos',
        'Por favor, ingresa todos los campos',
      );
      return;
    }

    // Obtener apiUrl desde el Provider
    final apiUrl = Provider.of<Config>(context, listen: false).apiUrl;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"] == "success") {
          // Verificamos el rol del usuario
          String role = data["role"];

          // Si es administrador, redirigimos a la pantalla de administrador
          if (role == Config.adminRole) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AccionesAdmin()), // Acciones para admin
            );
          } else if (role == Config.userRole) {
            // Si es un usuario normal, redirigimos a la pantalla común
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AccionesUser()), // Acciones para usuarios normales
            );
          } else {
            // Si el rol no es reconocido, mostramos un error
            _showDialog(
              context,
              'Rol Desconocido',
              'El rol del usuario no es reconocido.',
            );
          }
        } else {
          _showDialog(
            context,
            'Credenciales Incorrectas',
            'El correo electrónico o la contraseña son incorrectos.',
          );
        }
      } else {
        _showDialog(
          context,
          'Error de Conexión',
          'Error al conectar con el servidor.',
        );
      }
    } catch (e) {
      _showDialog(
        context,
        'Error de Red',
        'Error de red: $e',
      );
    }
  }

  // Función para mostrar AlertDialog
  void _showDialog(BuildContext context, String title, String content) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context), // Cierra el diálogo
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Iniciar sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text("Ingresar"),
            ),
          ],
        ),
      ),
    );
  }
}
