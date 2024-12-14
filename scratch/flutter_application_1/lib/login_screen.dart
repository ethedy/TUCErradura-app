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
      // Mostrar un AlertDialog si algún campo está vacío
      _showDialog(
        context,
        'Campos Vacíos',
        'Por favor, ingresa todos los campos',
      );
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
          _showDialog(
            context,
            'Credenciales Incorrectas',
            'El correo electrónico o la contraseña son incorrectos.',
          );
        }
      } else {
        // Error en la solicitud HTTP
        _showDialog(
          context,
          'Error de Conexión',
          'Error al conectar con el servidor.',
        );
      }
    } catch (e) {
      // Si hay algún error con la conexión
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


/*
class AlertDialogExampleApp extends StatelessWidget {
  const AlertDialogExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorSchemeSeed: const Color(0xff6750a4), useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('AlertDialog Sample')),
        body: const Center(
          child: DialogExample(),
        ),
      ),
    );
  }
}

class DialogExample extends StatelessWidget {
  const DialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const Text('AlertDialog description'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      child: const Text('Show Dialog'),
    );
  }
}*/