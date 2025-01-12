import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HttpService.dart';
import 'package:flutter_application_1/SessionManager.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:provider/provider.dart';

class UsuariosPage extends StatefulWidget {
  final String username; // Recibimos el nombre del usuario
  const UsuariosPage({super.key, required this.username});

  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<String> usuarios = [];
  List<bool> selectedUsuarios = []; // Estado de selección de cada usuario
  bool _isLoading = false; // Para mostrar el indicador de carga

  // Para el formulario de agregar usuario
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  TimeOfDay? selectedTime;

  // Opciones de los formularios
  List<String> days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
  String? selectedDay;
  String? selectedDoor;
  List<String> doors = ['Puerta 1', 'Puerta 2', 'Puerta 3'];

  // Función para obtener la lista de usuarios desde la API usando HttpService
  Future<void> _fetchUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    // Obtener la URL del API y el token desde el Config
    final config = Provider.of<Config>(context, listen: false);
    final apiUrl = config.usuariosEndpoint; // Usamos el endpoint de usuarios
    final token =
        await config.authToken; // Obtenemos el token de forma asíncrona

    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    try {
      // Hacemos un GET al servidor para obtener los usuarios
      final response = await HttpService().getRequest(apiUrl, token);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['users'] != null) {
          setState(() {
            usuarios = List<String>.from(data['users']);
            selectedUsuarios = List<bool>.filled(usuarios.length, false);
          });
        } else {
          _showDialog('Error', 'La respuesta de la API no contiene usuarios.');
        }
      } else {
        setState(() {
          usuarios = [];
        });
        _showDialog('Error', 'No se pudo obtener la lista de usuarios.');
      }
    } catch (e) {
      setState(() {
        usuarios = [];
      });
      _showDialog(
          'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Función para agregar un nuevo usuario
  Future<void> _addUser() async {
    final config = Provider.of<Config>(context, listen: false);
    final apiUrl =
        config.addUserEndpoint; // La URL del endpoint para agregar un usuario
    final token = await config.authToken; // Obtener el token de forma asíncrona

    if (token == null) {
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    // Asegúrate de que la URL esté configurada correctamente en tu configuración
    final url = Uri.parse(apiUrl); // URL para la solicitud POST al servidor

    // Verificamos que los campos no estén vacíos
    if (_usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        selectedDay != null && // Verificamos que el día esté seleccionado
        selectedTime != null && // Verificamos que la hora esté seleccionada
        selectedDoor != null) {
      // Verificamos que la puerta esté seleccionada) {
      // Creamos el objeto de usuario para enviar en la solicitud
      var newUser = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': 'user', // Puedes ajustar el rol según tus necesidades
        'name': _usernameController.text,
        'day': selectedDay, // El día seleccionado
        'time': selectedTime
            .toString(), // La hora seleccionada (puedes formatearla como necesites)
        'door': selectedDoor, // La puerta seleccionada
      };

      try {
        // Realizamos la solicitud POST
        final response = await HttpService().postRequest(url, newUser, token);

        if (response.statusCode == 201) {
          // Si la solicitud fue exitosa, actualizamos el estado de la interfaz
          setState(() {
            usuarios.add(_usernameController
                .text); // Agregamos el usuario a la lista local
          });

          _showDialog('Usuario Creado',
              'El usuario ${_usernameController.text} ha sido creado exitosamente.');
        } else {
          // Si hubo un error, mostramos el mensaje
          var errorResponse = jsonDecode(response.body);
          _showDialog('Error',
              errorResponse['message'] ?? 'No se pudo crear el usuario.');
        }
      } catch (e) {
        // Manejo de errores en la conexión con el servidor
        _showDialog(
            'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
      }
    } else {
      // Si los campos están vacíos, mostramos un mensaje de error
      _showDialog('Error', 'Por favor complete todos los campos.');
    }
  }

  // Guardar el usuario en el servidor
  Future<void> _saveUserToServer() async {
    final config = Provider.of<Config>(context, listen: false);
    final apiUrl = config.usuariosEndpoint;
    final token = await config.authToken;

    if (token == null) {
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    final newUser = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'day': selectedDay,
      'time': selectedTime?.format(context),
      'door': selectedDoor
    };

    try {
      final response =
          await HttpService().postRequest(Uri.parse(apiUrl), newUser, token);

      if (response.statusCode == 200) {
        _showDialog('Éxito', 'Usuario agregado correctamente.');
      } else {
        _showDialog('Error', 'No se pudo agregar el usuario.');
      }
    } catch (e) {
      _showDialog(
          'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
    }
  }

  // Función para eliminar un usuario
  Future<void> _deleteUser(String username) async {
    final config = Provider.of<Config>(context, listen: false);
    final apiUrl = config.deleteUser; // Endpoint para eliminar usuario
    final token = await config.authToken; // Obtener el token de forma asíncrona

    if (token == null) {
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    // Asegúrate de que 'usuariosEndpoint' esté configurado como la URL de tu servidor
    final url =
        Uri.parse('$apiUrl/$username'); // Usamos el email del usuario en la URL

    // Confirmación de eliminación
    bool? confirmDelete = await _confirmDelete(username);
    if (confirmDelete != true) return;
    // Cambiar el estado para mostrar el cargador
    setState(() {
      _isLoading = true;
    });
    try {
      // Realizamos la solicitud DELETE a través de HttpService
      final response = await HttpService().deleteRequest(url.toString(), token);

      if (response.statusCode == 200) {
        setState(() {
          usuarios.remove(username); // Eliminamos el usuario de la lista local
          selectedUsuarios.clear(); // Limpiamos la lista de selección
        });
        _showDialog('Éxito', 'El usuario $username ha sido eliminado.');
      } else {
        _showDialog('Error', 'No se pudo eliminar el usuario $username.');
      }
    } catch (e) {
      _showDialog(
          'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
    } finally {
      // Desactivar el cargador cuando la operación termine
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para confirmar la eliminación del usuario
  Future<bool?> _confirmDelete(String username) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación de eliminación'),
          content: Text('¿Está seguro de que desea eliminar a $username?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar un AlertDialog
  void _showDialog(String title, String content) {
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

  // Mostrar el formulario para agregar un usuario
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de usuario'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              _buildDropdown('día', selectedDay, days, (newValue) {
                setState(() {
                  selectedDay = newValue;
                });
              }),
              _buildTimePicker(),
              _buildDropdown('puerta', selectedDoor, doors, (newValue) {
                setState(() {
                  selectedDoor = newValue;
                });
              }),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: _addUser,
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  // Widget para los Dropdowns de selección
  Widget _buildDropdown<T>(String label, String? selectedValue,
      List<String> options, Function(String?) onChanged) {
    return DropdownButton<String>(
      value: selectedValue,
      hint: Text('Selecciona $label'),
      onChanged: (newValue) {
        onChanged(newValue);
      },
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker() {
    return ListTile(
      title: Text('Selecciona Horario'),
      subtitle: Text(selectedTime?.format(context) ?? 'Selecciona un horario'),
      onTap: () async {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() {
            selectedTime = time;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Aquí registramos el contexto y verificamos la expiración de la sesión
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    final config = Provider.of<Config>(context, listen: false);
    sessionManager
        .setContext(context); // Registramos el contexto de la pantalla
    sessionManager
        .checkSessionExpiration(config); // Verificamos si el token ha expirado

    _fetchUsuarios(); // Llamamos a la función para obtener la lista de usuarios cuando se inicie la página
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuarios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (usuarios.isEmpty)
              const Center(child: Text('No hay usuarios disponibles.')),
            if (usuarios.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(usuarios[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteUser(usuarios[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            // Botones centrados en la parte inferior
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón para agregar usuario
                    ElevatedButton(
                      onPressed: _showAddUserDialog,
                      child: const Text('Agregar Usuario'),
                    ),
                    const SizedBox(width: 10), // Espacio entre los botones
                    // Botón para actualizar la lista de usuarios con un ícono
                    ElevatedButton(
                      onPressed: _fetchUsuarios,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), // Hace el botón circular
                        padding:
                            EdgeInsets.all(16), // Espacio interno para el ícono
                      ),
                      child: Icon(
                        Icons.refresh, // Icono de refresco
                        color: kPrimaryColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
