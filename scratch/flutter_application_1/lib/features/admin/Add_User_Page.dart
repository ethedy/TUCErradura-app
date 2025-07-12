import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/Http_Service.dart';
import 'package:flutter_application_1/core/config.dart';
import 'package:provider/provider.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _rolSeleccionado = 'user';

  bool _isSubmitting = false;

  // Enviar datos al servidor
  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final config = Provider.of<Config>(context, listen: false);
    final token = await config.authToken;
    final url = config.addUserEndpoint;

    if (token == null) {
      _showSnackBar('Token de autenticación no disponible.');
      return;
    }

    final Map<String, dynamic> userData = {
      "name": _nombreController.text,
      "lastname": _apellidoController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "role": _rolSeleccionado,
    };

    try {
      final response = await HttpService().postRequest(
        Uri.parse(url),
        userData,
        token,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar('Usuario creado exitosamente.');
        Navigator.pop(context); // Regresa a UsuariosPage
      } else {
        _showSnackBar(
            'Error al crear usuario: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error de red: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Añadir Nuevo Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              // Apellido
              TextFormField(
                controller: _apellidoController,
                decoration: InputDecoration(labelText: 'Apellido'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese un apellido'
                    : null,
              ),
              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un email';
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return 'Email inválido';
                  return null;
                },
              ),
              // Contraseña
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6
                    ? 'Mínimo 6 caracteres'
                    : null,
              ),
              // Rol (Dropdown)
              DropdownButtonFormField<String>(
                value: _rolSeleccionado,
                decoration: InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Usuario')),
                  DropdownMenuItem(
                      value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _rolSeleccionado = value);
                },
              ),
              SizedBox(height: 24),
              // Botón añadir
              ElevatedButton(
                onPressed: _isSubmitting ? null : _addUser,
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Añadir'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
