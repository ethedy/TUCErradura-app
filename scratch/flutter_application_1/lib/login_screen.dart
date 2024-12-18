import 'package:flutter/material.dart';
import 'package:flutter_application_1/acciones_req.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // URL del ESP8266
  final String esp8266Ip =
      'http://192.168.100.79'; // Reemplazar a IP del ESP8266

  // Función para hacer la solicitud POST
  Future<void> _login() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    // Verificamos que los campos no estén vacíos
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Por favor, ingresa todos los campos"),
      ));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(esp8266Ip),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        // Si la respuesta del ESP8266 es exitosa
        var data = json.decode(response.body);
        if (data["status"] == "success") {
          // Si el login es exitoso, navegar a la siguiente pantalla
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Acciones()),
          );
        } else {
          // Si las credenciales son incorrectas
          _showErrorDialog("Credenciales incorrectas");
        }
      } else {
        // Error en la solicitud HTTP
        _showErrorDialog("Error al conectar con el servidor");
      }
    } catch (e) {
      // Si hay algún error con la conexión
      _showErrorDialog("Error de red: $e");
    }
  }

  // Método para mostrar un AlertDialog con un mensaje de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('ERROR'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context), // Cierra el diálogo
            child: Text('OK'),
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
                    color: const Color.fromARGB(255, 131, 9, 56),
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
                    ElevatedButton(
                      onPressed: _login,
                      child: Text("Ingresar"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Imagen logo-IPS-UNR en la esquina inferior derecha
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
