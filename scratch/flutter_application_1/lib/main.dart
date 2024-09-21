flutter create esp8266_control
cd esp8266_control

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de LED ESP8266',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String esp8266Ip =
      'http://192.168.1.100'; // Reemplazar a IP del ESP8266
  List<String> log = [];

  Future<void> _sendRequest(String action) async {
    final url = '$esp8266Ip/led/$action';
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
      appBar: AppBar(
        title: Text('LED ESP8266'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _sendRequest('on'),
                child: Text('Encender LED'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => _sendRequest('off'),
                child: Text('Apagar LED'),
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