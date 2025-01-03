import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
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

  // Función para eliminar un usuario
  Future<void> _deleteUser(String username) async {
    final apiUrl = Provider.of<Config>(context, listen: false).usuariosEndpoint;

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
                                  color: Colors.blue,
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
          ],
        ),
      ),
    );
  }
}
