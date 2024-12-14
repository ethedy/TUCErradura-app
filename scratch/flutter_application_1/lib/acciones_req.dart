import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AccionesReq extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Acciones(),
    );
  }
}

class Acciones extends StatefulWidget {
  const Acciones({super.key});

  @override
  _AccionesState createState() => _AccionesState();
}

class _AccionesState extends State<Acciones> {
  final String esp8266Ip =
      'ws://127.0.0.1:55356/95S-Y3WwTco=/ws'; // Reemplazar a IP del ESP8266
  List<String> log = [];

  Future<void> _sendRequest(String action) async {
    final url = '$esp8266Ip/door/$action';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _sendRequest('open'),
                child: const Text('ABRIR'),
              ),
              const SizedBox(width: 50),
              ElevatedButton(
                onPressed: () => _sendRequest('closed'),
                child: const Text('CERRAR'),
              ),
            ],
          ),
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
    );
  }
}
