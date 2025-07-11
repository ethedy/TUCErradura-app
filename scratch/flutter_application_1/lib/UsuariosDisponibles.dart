import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/EditUserPage.dart';
import 'package:flutter_application_1/HttpService.dart';
import 'package:flutter_application_1/config.dart';
import 'package:provider/provider.dart';

/* 
Pantalla principal: UsuariosPage muestra una lista de usuarios y recibe como parámetro el nombre del usuario actual (username).
Carga de datos: Al iniciarse, llama a _fetchUsuarios() para obtener los usuarios desde un endpoint (API) usando un token de autenticación.
Visualización: Los usuarios se muestran en tarjetas con su nombre y correo, junto a botones para editar o eliminar.
Eliminar usuario:
  Solicita confirmación mediante un AlertDialog.
  Si se confirma, envía una solicitud DELETE al servidor y elimina el usuario de la lista.
Editar usuario: Navega a la pantalla EditUserPage, pasando el email como parámetro.
  Botón "Añadir Nuevo Usuario": Solo se muestra visualmente, pero no tiene funcionalidad activa aún.
Componentes clave:
  HttpService: Encargado de las peticiones HTTP (GET y DELETE).
  Config: Proveedor que gestiona configuraciones globales como el token o las URLs.
  Provider: Usado para acceder al Config en el árbol de widgets.
*/

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
  bool _hasError = false; // Indicador de error

  // Función para obtener la lista de usuarios desde la API usando HttpService
  Future<void> _fetchUsuarios() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final config = Provider.of<Config>(context, listen: false);
    final apiUrl = config.usuariosEndpoint; // Endpoint de la API
    final token = await config.authToken; // Token de autenticación

    if (token == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    try {
      final response = await HttpService().getRequest(apiUrl, token);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['users'] != null) {
          setState(() {
            usuarios = List<Map<String, String>>.from(data['users'].map((user) {
              return {
                'name': user['name']?.toString() ?? 'Nombre no disponible',
                'email': user['email']?.toString() ?? 'Email no disponible',
              };
            }));
            selectedUsuarios = List<bool>.filled(usuarios.length, false);
          });
        } else {
          setState(() {
            _hasError = true;
          });
          _showDialog('Error', 'La respuesta de la API no contiene usuarios.');
        }
      } else {
        setState(() {
          _hasError = true;
        });
        _showDialog('Error',
            'No se pudo obtener la lista de usuarios. Código: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
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

  // Función para confirmar la eliminación
  Future<bool?> _confirmDelete(String username) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación de eliminación'),
          content: Text(
              '¿Estás seguro de que quieres eliminar al usuario $username?'),
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

  // Función para eliminar un usuario
  Future<void> _deleteUser(String email) async {
    final config = Provider.of<Config>(context, listen: false);
    final apiUrl = config.deleteUser; // Endpoint para eliminar usuario
    final token = await config.authToken; // Obtener el token de forma asíncrona

    if (token == null) {
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    // Asegúrate de que 'usuariosEndpoint' esté configurado como la URL de tu servidor
    final url =
        Uri.parse('$apiUrl/$email'); // Usamos el email del usuario en la URL

    // Confirmación de eliminación
    bool? confirmDelete = await _confirmDelete(email);
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
          // Encontramos el usuario en la lista y lo eliminamos
          usuarios.removeWhere((user) => user['email'] == email);
          selectedUsuarios.clear(); // Limpiamos la lista de selección
        });
        _showDialog('Éxito', 'El usuario con email $email ha sido eliminado.');
      } else {
        _showDialog(
            'Error', 'No se pudo eliminar el usuario con email $email.');
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
          : _hasError
              ? Center(child: Text('Hubo un error al cargar los usuarios'))
              : ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    var usuario = usuarios[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Información del usuario
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  usuario['name'] ?? 'Sin nombre',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10), // Espacio adicional
                                Opacity(
                                  opacity: 0.6,
                                  child: Text(
                                    usuario['email'] ?? 'Sin email',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botones de acción alineados horizontalmente
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteUser(usuario['name'] ?? '');
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditUserPage(
                                        email: usuario['email'] ?? '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // No hace nada por ahora, solo se muestra el botón
          },
          child: Text('Añadir Nuevo Usuario'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
