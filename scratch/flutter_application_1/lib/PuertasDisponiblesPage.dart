import 'dart:convert';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_application_1/HttpService.dart';
import 'package:flutter_application_1/SessionManager.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:provider/provider.dart';
=======
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
>>>>>>> main

class PuertasDisponiblesPage extends StatefulWidget {
  final String username; // Recibimos el nombre del usuario
  const PuertasDisponiblesPage({super.key, required this.username});

  @override
  _PuertasDisponiblesPageState createState() => _PuertasDisponiblesPageState();
}

class _PuertasDisponiblesPageState extends State<PuertasDisponiblesPage> {
  List<String> puertasDisponibles = [];
  bool _isLoading = false; // Para mostrar el indicador de carga

  // Función para obtener las puertas disponibles desde la API
  Future<void> _fetchDoors() async {
    setState(() {
      _isLoading = true; // Activamos el indicador de carga
    });

<<<<<<< HEAD
    // Obtener el token de autenticación y la URL del API desde el Config
    final config = Provider.of<Config>(context, listen: false);

    // Obtén el token de manera asíncrona
    final token =
        await config.authToken; // Debemos esperar el resultado del Future
    final apiUrl = config.doorsEndpoint;

    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    try {
      // Usamos el HttpService para hacer la solicitud
      final response = await HttpService().postRequest(
        Uri.parse(apiUrl), // Convertimos apiUrl a Uri
        {'action': 'get_doors'}, // Este cuerpo es necesario en un POST
        token,
=======
    // Obtener la URL del API desde el Config
    final apiUrl = Provider.of<Config>(context, listen: false)
        .doorsEndpoint; // Usamos el endpoint de puertas

    try {
      // Hacemos un POST al servidor para obtener las puertas
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'get_doors', // Enviamos una acción como parámetro
        }),
>>>>>>> main
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(
            'Respuesta de la API: $data'); // Imprimir la respuesta para verificarla

<<<<<<< HEAD
        // Acceder correctamente a la respuesta, asumiendo que está en 'data' -> 'doors'
        if (data['data'] != null && data['data']['doors'] != null) {
          //Verifica que la estructura de la respuesta de la API coincida con cómo estás tratando de acceder
          // a ella en el código (posiblemente debas acceder a data['data']['doors'] en lugar de solo data['doors']).
          setState(() {
            puertasDisponibles = List<String>.from(data['data']['doors']);
          });
        } else {
          _showDialog('Error',
              'La respuesta de la API no contiene las puertas esperadas.');
=======
        if (data['doors'] != null) {
          setState(() {
            puertasDisponibles = List<String>.from(data['doors']);
          });
        } else {
          _showDialog('Error', 'La respuesta de la API no contiene puertas.');
>>>>>>> main
        }
      } else {
        setState(() {
          puertasDisponibles = [];
        });
        _showDialog('Error', 'No se pudo obtener las puertas disponibles.');
      }
    } catch (e) {
<<<<<<< HEAD
      _showDialog(
          'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
      setState(() {
        puertasDisponibles = [];
      });
=======
      setState(() {
        puertasDisponibles = [];
      });
      _showDialog(
          'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
>>>>>>> main
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

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    // Aquí registramos el contexto y verificamos la expiración de la sesión
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    final config = Provider.of<Config>(context, listen: false);
    sessionManager
        .setContext(context); // Registramos el contexto de la pantalla
    sessionManager
        .checkSessionExpiration(config); // Verificamos si el token ha expirado
    _fetchDoors(); // Llamamos a la función para cargar las puertas en el inicio
=======
    _fetchDoors(); // Llamamos a la función para obtener las puertas disponibles cuando se inicie la página
>>>>>>> main
  }

  // Función para abrir una puerta mediante la acción de GET
  Future<void> _openDoor(String doorName) async {
<<<<<<< HEAD
    setState(() {
      _isLoading = true; // Activamos el indicador de carga
    });
    // Obtener el token de autenticación desde el Config
    final token = await Provider.of<Config>(context, listen: false).authToken;

    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }
    // Obtener la URL del API desde el Config
=======
>>>>>>> main
    final apiUrl = Provider.of<Config>(context, listen: false).openDoorEndpoint;
    final url = '$apiUrl/$doorName'; // Acción para abrir la puerta específica

    try {
<<<<<<< HEAD
      // Usamos el HttpService para hacer la solicitud GET
      final response = await HttpService().getRequest(url, token);
=======
      final response = await http.get(Uri.parse(url));
>>>>>>> main

      if (response.statusCode == 200) {
        _showDialog(
            'Éxito', 'La puerta $doorName ha sido abierta correctamente.');
      } else {
        _showDialog('Error', 'No se pudo abrir la puerta $doorName.');
      }
    } catch (e) {
      _showDialog(
          'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
<<<<<<< HEAD
    } finally {
      setState(() {
        _isLoading = false; // Desactivamos el indicador de carga
      });
=======
>>>>>>> main
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puertas Disponibles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Si está cargando o no hay puertas disponibles, se muestra el mensaje correspondiente
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (puertasDisponibles.isEmpty)
              const Center(child: Text('No hay puertas disponibles.'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: puertasDisponibles.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: kPrimaryLightColor, // Fondo gris claro
                                borderRadius: BorderRadius.circular(
                                    20.0), // Bordes circulares
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Text(
                                puertasDisponibles[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                )
                              : Icon(
                                  Icons.check_circle_outline,
                                  size: 40,
                                  color: Colors.green,
                                ),
                          onPressed: _isLoading
<<<<<<< HEAD
                              ? null // Desactivamos el botón mientras está cargando
=======
                              ? null
>>>>>>> main
                              : () => _openDoor(puertasDisponibles[index]),
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
