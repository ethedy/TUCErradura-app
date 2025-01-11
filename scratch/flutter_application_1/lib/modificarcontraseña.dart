import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _errorMessage;

  // Función para enviar el cambio de contraseña
  Future<void> _changePassword() async {
    final config = Provider.of<Config>(context, listen: false);

    // Obtener el token y URL desde el provider de Config
    final token = config.authToken;
    final apiUrl = config.modifyPassword;

    // Validar que el formulario esté correcto
    if (_formKey.currentState?.validate() ?? false) {
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;

      if (token == null) {
        setState(() {
          _errorMessage = 'No se encontró el token de autenticación';
        });
        return;
      }

      // Construir el cuerpo de la solicitud
      final requestData = {
        "current_password": currentPassword,
        "new_password": newPassword,
      };

      try {
        // Usar HttpService para enviar la solicitud POST
        final response = await config.postRequest(apiUrl, requestData);

        if (response.statusCode == 200) {
          // Si la respuesta es exitosa, mostrar un mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Contraseña cambiada exitosamente')),
          );
        } else {
          // Si hay un error con el servidor
          setState(() {
            _errorMessage =
                'Error al cambiar la contraseña. Código: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error de red: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cambiar Contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
              ],
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Contraseña actual'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña actual';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Nueva contraseña'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una nueva contraseña';
                  }
                  if (value.length < 6) {
                    return 'La nueva contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration:
                    InputDecoration(labelText: 'Confirmar nueva contraseña'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirma tu nueva contraseña';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text('Cambiar contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
