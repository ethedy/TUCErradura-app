import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de LED ESP8266',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String esp8266Ip =
      'http://192.168.100.79'; // Reemplazar a IP del ESP8266
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
      appBar: AppBar(
        title: const Text(
          'PUERTA - ESP8266',
          style: TextStyle(
            color: Color.fromARGB(255, 19, 15, 15),
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.blue,
        shadowColor: Colors.grey,
        scrolledUnderElevation: 20.0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4C60AF),
                Color.fromARGB(255, 37, 195, 248),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
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
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(log[index]),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
