import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/EditUserPage.dart';
import 'package:flutter_application_1/HttpService.dart';
import 'package:flutter_application_1/config.dart';
import 'package:provider/provider.dart';

class UsuariosPage extends StatefulWidget {
  final String username; // Recibimos el nombre del usuario
  const UsuariosPage({super.key, required this.username});

  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<Map<String, String>> usuarios = []; // Lista de usuarios
  List<bool> selectedUsuarios =
      []; // Lista para hacer seguimiento de la selección de usuarios
  bool _isLoading = false; // Para mostrar el indicador de carga

  // Función para obtener la lista de usuarios desde la API usando HttpService
  Future<void> _fetchUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    final config = Provider.of<Config>(context, listen: false);
    final apiUrl = config.usuariosEndpoint; // Endpoint de la API
    final token = await config.authToken; // Token de autenticación

    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    try {
      final response = await HttpService().getRequest(apiUrl, token);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['users'] != null) {
          // Ahora la respuesta contiene todos los detalles de los usuarios
          setState(() {
            usuarios = List<Map<String, String>>.from(data['users'].map((user) {
              return {
                'name': user['name'], // Nombre del usuario
                'email': user['email'], // Correo electrónico del usuario
                'role': user['role'], // Rol del usuario
              };
            }));
            // Inicializamos selectedUsuarios con una lista de 'false' para cada usuario
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

  @override
  void initState() {
    super.initState();
    _fetchUsuarios(); // Cargar usuarios al inicio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios - ${widget.username}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                var usuario = usuarios[index];
                return ListTile(
                  title: Text(usuario['name'] ?? 'Sin nombre'),
                  subtitle: Text(usuario['email'] ?? 'Sin email'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // Navegar a EditUserPage con solo el email
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserPage(
                            email: usuario['email']!, // Pasamos el email
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí puedes agregar la lógica para agregar un nuevo usuario si es necesario
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
