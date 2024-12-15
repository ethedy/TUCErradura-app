import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_application_1/config.dart';

class AccionesUser extends StatefulWidget {
  const AccionesUser({Key? key}) : super(key: key);

  @override
  _AccionesUserState createState() => _AccionesUserState();
}

class _AccionesUserState extends State<AccionesUser> {
  List<String> log = [];
  bool _isLoading = false; // Para mostrar el indicador de carga

  // Función para hacer la solicitud GET a la API
  Future<void> _sendRequest(String action) async {
    setState(() {
      _isLoading = true; // Activamos el indicador de carga
    });

    // Obtener la URL del API desde el Config
    final apiUrl = Provider.of<Config>(context, listen: false).apiUrl;

    final url = '$apiUrl/door/$action';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          log.add('Acción: $action, Respuesta: ${response.body}');
        });
      } else {
        setState(() {
          log.add('Error al enviar la solicitud.');
        });
      }
    } catch (e) {
      setState(() {
        log.add('Error de red: $e');
      });
    } finally {
      setState(() {
        _isLoading = false; // Desactivamos el indicador de carga
      });
    }
  }

  // Función para cerrar sesión y regresar a la pantalla de login
  void _logout(BuildContext context) {
    // Aquí podrías limpiar cualquier dato de sesión si es necesario
    Navigator.pop(context); // Regresar a la pantalla de login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acciones del Usuario"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context), // Cerrar sesión
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _sendRequest('open'),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('ABRIR'),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 20),
            // Log de acciones realizadas
            Expanded(
              child: ListView.builder(
                itemCount: log.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(log[index]),
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
