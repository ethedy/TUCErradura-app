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
  Future<void> _getPuertasDisponibles() async {
    setState(() {
      _isLoading = true; // Activamos el indicador de carga
    });

    final apiUrl = Provider.of<Config>(context, listen: false).apiUrl;
    final url =
        '$apiUrl/doors'; // Aquí deberías poner la ruta correcta de la API

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          puertasDisponibles = List<String>.from(data['doors']);
        });
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
    _getPuertasDisponibles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puertas Disponibles'),
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
                      return ListTile(
                        title: Text(puertasDisponibles[index]),
                        onTap: () {
                          _showDialog('Acción',
                              'Abriendo puerta: ${puertasDisponibles[index]}');
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
