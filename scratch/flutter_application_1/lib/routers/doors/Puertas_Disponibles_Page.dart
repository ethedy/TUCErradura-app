import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/Http_Service.dart';
import 'package:flutter_application_1/core/Session_Manager.dart';
import 'package:flutter_application_1/core/config.dart';
import 'package:provider/provider.dart';

/*
Carga de puertas disponibles (_fetchDoors)
	Al iniciar, el widget llama a una API para obtener las puertas disponibles.
	La respuesta se espera en formato JSON dentro de data['data']['doors'].
	Las puertas se guardan en una lista y se muestran en pantalla.
Apertura de puerta (_openDoor)
	Cada puerta tiene un botón con un ícono de check.
	Al presionarlo, se hace una solicitud GET al servidor para "abrir" esa puerta específica.
	Si la solicitud es exitosa, se muestra un mensaje de éxito.
Control de sesión
	Usa SessionManager para verificar si el token ha expirado.
	Si no hay token, muestra un error.
Componentes clave
	HttpService: para manejar solicitudes HTTP.
	Provider<Config>: obtiene URLs y tokens.
	SessionManager: controla el estado de sesión del usuario.
	AlertDialog: muestra mensajes de error o éxito.
	ListView.builder: muestra dinámicamente la lista de puertas.
¿Qué ve el usuario?
	Una lista de puertas con nombre.
	Un botón para abrir cada puerta.
	Mensajes de error o éxito según el resultado de la solicitud.
*/

class PuertasDisponiblesPage extends StatefulWidget {
  final String username; // Recibimos el nombre del usuario

  const PuertasDisponiblesPage({super.key, required this.username});

  @override
  _PuertasDisponiblesPageState createState() => _PuertasDisponiblesPageState();
}

class _PuertasDisponiblesPageState extends State<PuertasDisponiblesPage> {
  List<String> puertasDisponibles = [];
  List<Map<String, dynamic>> puertasDetalles = [];
  String? userRole;
  bool _isLoading = false; // Para mostrar el indicador de carga

  @override
  void initState() {
    super.initState();
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    final config = Provider.of<Config>(context, listen: false);
    sessionManager.setContext(context);
    sessionManager.checkSessionExpiration(config);
    _fetchDoors();
  }

  Future<void> _fetchDoors() async {
    setState(() => _isLoading = true);
    final config = Provider.of<Config>(context, listen: false);
    final token = await config.authToken;

    if (token == null) {
      _showDialog('Error', 'No se encontró el token.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Obtener rol del usuario
      final userInfoResp = await HttpService()
          .postRequest(Uri.parse(config.infoBaseDatos), {}, token);
      if (userInfoResp.statusCode == 200) {
        userRole = json.decode(userInfoResp.body)['user']['role'];
      }

      // Obtener puertas
      final doorsResp = await HttpService().postRequest(
        Uri.parse(config.doorsEndpoint),
        {'action': 'get_doors'},
        token,
      );
      if (doorsResp.statusCode == 200) {
        final data = json.decode(doorsResp.body);
        puertasDetalles =
            List<Map<String, dynamic>>.from(data['data']['doors']);

// Y aparte un array solo con los nombres (para el ListView)
        puertasDisponibles =
            puertasDetalles.map((d) => d['name'] as String).toList();
      }

      // Si es admin, obtener detalles
      if (userRole == 'admin') {
        final detailResp = await HttpService()
            .postRequest(Uri.parse(config.doorsDetailsEndpoint), {}, token);
        if (detailResp.statusCode == 200) {
          final extra = List<Map<String, dynamic>>.from(
              json.decode(detailResp.body)['data']);
          // Reemplaza o agrega campos en puertasDetalles según name o mac
          for (var det in extra) {
            final idx =
                puertasDetalles.indexWhere((d) => d['name'] == det['name']);
            if (idx != -1) {
              puertasDetalles[idx].addAll(det); // merge
            } else {
              puertasDetalles.add(det); // nueva puerta
            }
          }
        }
      }
    } catch (e) {
      _showDialog('Error', 'Fallo al obtener puertas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openDoor(String doorName, String tokenESP, String mac) async {
    setState(() => _isLoading = true);
    final token = await Provider.of<Config>(context, listen: false).authToken;
    final apiUrl =
        '${Provider.of<Config>(context, listen: false).openDoorEndpoint}';

    try {
      final response = await HttpService().postRequest(
        Uri.parse(apiUrl),
        {
          'tokenESP': tokenESP,
          'door': doorName,
          'mac': mac, // envío la mac
        },
        token!, // token JWT del usuario para autorización en backend
      );

      if (response.statusCode == 200) {
        _showDialog('Éxito', 'La puerta $doorName ha sido abierta.');
      } else {
        _showDialog('Error', 'No se pudo abrir la puerta.');
      }
    } catch (e) {
      _showDialog('Error', 'Error de red: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editarPuerta(
      String mac, String nuevoNombre, bool activa) async {
    final token = await Provider.of<Config>(context, listen: false).authToken;
    final url =
        '${Provider.of<Config>(context, listen: false).updateDoorEndpoint}/$mac';

    try {
      final response = await HttpService().putRequest(
        url,
        {'name': nuevoNombre, 'active': activa},
        token!,
      );

      if (response.statusCode == 200) {
        _showDialog('Actualizado', 'Puerta actualizada con éxito.');
        _fetchDoors(); // Recargar datos
      } else {
        _showDialog('Error', 'Fallo al actualizar puerta.');
      }
    } catch (e) {
      _showDialog('Error', 'Fallo de red: $e');
    }
  }

  // Función para mostrar un AlertDialog
  void _mostrarDialogoEdicion(Map<String, dynamic> puerta) {
    final TextEditingController nameController =
        TextEditingController(text: puerta['name']);
    bool activa = puerta['active'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar puerta (${puerta['mac']})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              SwitchListTile(
                title: Text('Activa'),
                value: activa,
                onChanged: (bool value) {
                  setState(() {
                    activa = value;
                  });
                  Navigator.pop(context);
                  _mostrarDialogoEdicion({
                    ...puerta,
                    'name': nameController.text,
                    'active': value,
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                Navigator.pop(context);
                _editarPuerta(puerta['mac'], nameController.text, activa);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puertas Disponibles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : puertasDisponibles.isEmpty
                ? Center(child: Text('No hay puertas disponibles.'))
                : ListView.builder(
                    itemCount: puertasDisponibles.length,
                    itemBuilder: (context, index) {
                      final nombre = puertasDisponibles[index];
                      final detalle = puertasDetalles.firstWhere(
                        (d) => d['name'] == nombre,
                        orElse: () => {},
                      );

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(nombre),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  final tokenESP = detalle['token'] ?? '';
                                  final mac = detalle['mac'] ?? '';
                                  _openDoor(nombre, tokenESP, mac);
                                },
                              ),
                              if (userRole == 'admin')
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    if (detalle.isNotEmpty) {
                                      _mostrarDialogoEdicion(detalle);
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
