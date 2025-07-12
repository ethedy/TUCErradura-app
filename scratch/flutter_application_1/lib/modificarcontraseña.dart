import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/SessionManager.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screen_user.dart';
import 'package:provider/provider.dart';

/*
Componentes principales:
	TextFormField para ingresar y confirmar la nueva contraseña.
	Provider para acceder a configuraciones globales como el token de sesión.
	SessionManager para verificar si la sesión expiró.
	HttpService o config.postRequest para hacer solicitudes POST al servidor.
  
Funcionamiento paso a paso
	Carga de datos del usuario (nombre, email y rol)
	Se obtiene el token de sesión.
	Se hace una solicitud POST al servidor para obtener los datos del usuario.
	Estos datos se muestran en campos deshabilitados (no editables).
Cambio de contraseña
	Cuando el usuario presiona "Cambiar contraseña":
	Se valida que:
		La contraseña nueva no esté vacía.
		Tenga al menos 6 caracteres.
		Coincida con la confirmación.
	Se hace un POST al servidor con el nuevo password.
Si el servidor responde con éxito:
	Se muestra un mensaje de éxito en un AlertDialog.
	Se redirige al usuario a la pantalla principal de usuario (AccionesUser).
Manejo de errores
Si falla la red, el token no existe o hay error en el servidor, se muestra un mensaje rojo informando lo ocurrido.
*/

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Map<String, dynamic>? _userData;

  Future<void> _loadUserData() async {
    final config = Provider.of<Config>(context, listen: false);
    final token = await config.authToken;

    if (token == null) {
      setState(() {
        _errorMessage = 'No se encontró el token de autenticación';
      });
      return;
    }

    try {
      final response = await config.postRequest(config.infoBaseDatos, {});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _userData = data['user'];
        });
      } else {
        setState(() {
          _errorMessage = 'Error al obtener los datos del usuario';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de red: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _changePassword() async {
    final config = Provider.of<Config>(context, listen: false);
    final token = await config.authToken;
    final apiUrl = config.modifyPassword;

    if (_formKey.currentState?.validate() ?? false) {
      final newPassword = _newPasswordController.text;

      if (token == null) {
        setState(() {
          _errorMessage = 'No se encontró el token de autenticación';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final requestData = {
        "new_password": newPassword,
      };

      try {
        final response = await config.postRequest(apiUrl, requestData);

        if (response.statusCode == 200) {
          setState(() {
            _isLoading = false;
          });
          final String name = _userData?['name'] ?? '';
          final String lastname = _userData?['lastname'] ?? '';

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Contraseña cambiada"),
                content: Text("Tu contraseña se cambió exitosamente."),
                actions: [
                  TextButton(
                    child: Text("Aceptar"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar diálogo
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccionesUser(
                            username: name,
                            lastname: lastname,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Error al cambiar la contraseña. Código: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error de red: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    final config = Provider.of<Config>(context, listen: false);
    sessionManager.setContext(context);
    sessionManager.checkSessionExpiration(config);

    return Scaffold(
      appBar: AppBar(title: Text('Cambiar Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _userData == null
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (_errorMessage != null) ...[
                      Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                    ],
                    TextFormField(
                      initialValue: _userData!['name'] ?? '',
                      decoration: InputDecoration(labelText: 'Nombre'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: _userData!['lastname'] ?? '',
                      decoration: InputDecoration(labelText: 'Apellido'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: _userData!['email'] ?? '',
                      decoration:
                          InputDecoration(labelText: 'Correo electrónico'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: _userData!['role'] ?? '',
                      decoration: InputDecoration(labelText: 'Rol'),
                      enabled: false,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
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
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                          labelText: 'Confirmar nueva contraseña'),
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
                      onPressed: _isLoading ? null : _changePassword,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Cambiar contraseña'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
