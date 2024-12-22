import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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
      _isLoading = true;
    });

    // Obtener la URL del API desde el Config
    final apiUrl = Provider.of<Config>(context, listen: false).apiUrl;
    final url = '$apiUrl/doors'; // URL para obtener las puertas

    try {
      // Hacemos un POST al servidor para obtener las puertas
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'get_doors', // Enviamos una acción como parámetro
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(
            'Respuesta de la API: $data'); // Imprimir la respuesta para verificarla

        if (data['doors'] != null) {
          setState(() {
            puertasDisponibles = List<String>.from(data['doors']);
          });
        } else {
          _showDialog('Error', 'La respuesta de la API no contiene puertas.');
        }
      } else {
        setState(() {
          puertasDisponibles = [];
        });
        _showDialog('Error', 'No se pudo obtener las puertas disponibles.');
      }
    } catch (e) {
      setState(() {
        puertasDisponibles = [];
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

  @override
  void initState() {
    super.initState();
    _fetchDoors(); // Llamamos a la función para obtener las puertas disponibles cuando se inicie la página
  }

  // Función para abrir una puerta mediante la acción de GET
  Future<void> _openDoor(String doorName) async {
    final apiUrl = Provider.of<Config>(context, listen: false).apiUrl;
    final url =
        '$apiUrl/door/open/$doorName'; // Acción para abrir la puerta específica

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        _showDialog(
            'Éxito', 'La puerta $doorName ha sido abierta correctamente.');
      } else {
        _showDialog('Error', 'No se pudo abrir la puerta $doorName.');
      }
    } catch (e) {
      _showDialog(
          'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puertas Disponibles'),
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
                                color: Colors.grey[300], // Fondo gris claro
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
                                  color: Colors.blue,
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
                              ? null
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
