import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/config.dart';
import 'package:flutter_application_1/features/users/screen_user.dart';
import 'package:flutter_application_1/features/admin/screen_admin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/constants.dart';

//Este código define una pantalla de inicio de sesión (LoginScreen) en una app Flutter.
//Permite que el usuario se autentique con su correo electrónico y contraseña, y según su rol (admin o user), lo redirige a una pantalla específica de la aplicación.
//Funciones principales del programa:
//Formulario de Login:
//  Contiene dos campos de texto para ingresar correo electrónico y contraseña.
//  Al presionar el botón “Ingresar”, se llama al método _login().

//Proceso de autenticación (_login):
//  Envía una solicitud POST a un endpoint (/login) del backend con los datos del usuario.
//  Si la respuesta es exitosa (statusCode 200) y el servidor devuelve un token, role y status:
//  Guarda el token de forma segura usando el Provider y la clase Config.
//  Redirige al usuario a la pantalla correspondiente:
//  AccionesAdmin si es admin.
//  AccionesUser si es usuario normal.
//  Si el login falla o el rol es desconocido, muestra un mensaje de error en un diálogo (AlertDialog).
//Interfaz de usuario:
//  Muestra una imagen superior y un título.
//  Incluye el formulario de login y un logo en la parte inferior.
//  Usa diseño responsive (MediaQuery) para adaptar el layout a la pantalla.

class LoginScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
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
    final apiUrl = Provider.of<Config>(context, listen: false).loginEndpoint;

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
        // Si la respuesta del ESP8266 es exitosa
        var data = json.decode(response.body);

        // Verifica si "status" y "role" están presentes en la respuesta
        String status = data["status"] ?? '';
        String role =
            data["role"] ?? 'unknown'; // Asegura que 'role' nunca sea null
        String token =
            data["token"]; // Suponemos que el token está en la respuesta

        if (status == "success") {
          final config = Provider.of<Config>(context, listen: false);
          // Guardamos el token y el rol en el provider
          await config.setAuthToken(token, role);
          // Obtenemos nombre y apellido desde el token guardado
          final name = await config.userName ?? '';
          final lastname = await config.userLastName ?? '';

          // Redirigir al usuario según su rol
          if (role == Config.adminRole) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AccionesAdmin(
                        username: name,
                      )),
            );
          } else if (role == Config.userRole) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AccionesUser(
                  username: name,
                  lastname: lastname,
                ),
              ),
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
          'Error al conectar con el servidor. Código de estado: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Mejora la impresión de los errores
      print('Error de conexión: $e');
      _showDialog(
        context,
        'Error de Red',
        'No se pudo conectar al servidor. Por favor, verifica tu conexión a internet. Detalles: $e',
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Formulario y la imagen arriba del formulario
          Column(
            children: <Widget>[
              // Imagen en la parte superior, encima del formulario
              Container(
                width: double.infinity,
                height: size.height * 0.3, // Ajusta el tamaño de la imagen
                child: Image.asset(
                  'assets/images/Depto Electro.jpg',
                ),
              ),
              // Título centrado entre la imagen y el formulario
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              // Formulario de login
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _emailController,
                      decoration:
                          InputDecoration(labelText: 'Correo electrónico'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _login,
                          icon: Icon(Icons.check_circle_outline,
                              size: 20, color: kPrimaryColor),
                          label: Text('Ingresar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Image.asset(
              'assets/images/logo-IPS-UNR.png',
              width: size.width * 0.3, // Ajusta el tamaño de la imagen
            ),
          ),
        ],
      ),
    );
  }
}
