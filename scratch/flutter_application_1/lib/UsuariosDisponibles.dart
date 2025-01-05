import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
  String? selectedDay;
  String? selectedTime;
  String? selectedDoor;

  // Opciones de los formularios
  List<String> days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
  List<String> times = ['09:00', '12:00', '15:00', '18:00'];
  List<String> doors = ['Puerta 1', 'Puerta 2', 'Puerta 3'];

  // Función para obtener la lista de usuarios desde la API
  Future<void> _fetchUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    // Obtener la URL del API desde el Config
    final apiUrl = Provider.of<Config>(context, listen: false)
        .usuariosEndpoint; // Usamos el endpoint de usuarios

    try {
      // Hacemos un GET al servidor para obtener los usuarios
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(
            'Respuesta de la API: $data'); // Imprimir la respuesta para verificarla

        if (data['users'] != null) {
          setState(() {
            usuarios = List<String>.from(data['users']);
            selectedUsuarios = List<bool>.filled(
                usuarios.length, false); // Inicializamos el estado de selección
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
        _isLoading = false; // Desactivamos el indicador de carga
      });
    }
  }

  // Agregar un nuevo usuario
  void _addUser() {
    if (_usernameController.text.isNotEmpty &&
        selectedDay != null &&
        selectedTime != null &&
        selectedDoor != null) {
      setState(() {
        usuarios
            .add(_usernameController.text); // Agregamos el usuario a la lista
      });
      Navigator.pop(context); // Cerramos el diálogo
      _showDialog('Éxito', 'Usuario agregado correctamente');
    } else {
      _showDialog('Error', 'Por favor complete todos los campos.');
    }
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
              _buildDropdown('día', selectedDay, days, (newValue) {
                setState(() {
                  selectedDay = newValue;
                });
              }),
              _buildDropdown('horario', selectedTime, times, (newValue) {
                setState(() {
                  selectedTime = newValue;
                });
              }),
              _buildDropdown('puerta', selectedDoor, doors, (newValue) {
                setState(() {
                  selectedDoor = newValue;
                });
              }),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.pop(context), // Cerrar el diálogo sin agregar
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: _addUser, // Llamar la función para agregar el usuario
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar un usuario
  Future<void> _deleteUser(String username) async {
    final apiUrl = Provider.of<Config>(context, listen: false).usuariosEndpoint;

    // Confirmación de eliminación
    bool? confirmDelete = await _confirmDelete(username);
    if (confirmDelete != true)
      return; // Si no se confirma, salimos de la función

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'delete_user',
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          usuarios.remove(username); // Eliminamos el usuario de la lista
          selectedUsuarios.clear(); // Limpiamos la lista de selección
        });
        _showDialog('Éxito', 'El usuario $username ha sido eliminado.');
      } else {
        _showDialog('Error', 'No se pudo eliminar el usuario $username.');
      }
    } catch (e) {
      _showDialog(
          'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
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

  // Widget para los Dropdowns de selección
  Widget _buildDropdown<T>(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
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

  @override
  void initState() {
    super.initState();
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
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alineamos todo a la izquierda
          children: <Widget>[
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (usuarios.isEmpty)
              const Center(child: Text('No hay usuarios disponibles.'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Alineamos a la izquierda cada fila
                      children: <Widget>[
                        // Nombre del usuario
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedUsuarios[index] =
                                  !selectedUsuarios[index];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                usuarios[index],
                                textAlign: TextAlign
                                    .left, // Alineamos el texto a la izquierda
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Mostrar opciones de eliminar si el usuario está seleccionado
                        if (selectedUsuarios[index])
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                // Botón rojo para borrar
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _deleteUser(usuarios[index]);
                                  },
                                ),
                                // Palomita para confirmar eliminación
                                IconButton(
                                  icon: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedUsuarios[index] =
                                          false; // Deselecciona el usuario
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
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
