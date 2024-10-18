import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

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
  String baseIp = 'http://192.168.100.1'; // Cambia esto según tu red
  List<String> devices = [];
  List<String> log = [];

  @override
  void initState() {
    super.initState();
    getLocalIp();
  }

  Future<void> getLocalIp() async {
    final info = NetworkInfo();
    String? wifiIP = await info.getWifiIP();
    if (wifiIP != null) {
      setState(() {
        baseIp = wifiIP.split('.').sublist(0, 3).join('.');
      });
    }
  }

  Future<void> scanDevices() async {
    devices.clear();
    for (int i = 1; i < 255; i++) {
      String ip = '$baseIp.$i';
      try {
        final response = await http.get(Uri.parse('$ip/get_mac'));
        if (response.statusCode == 200) {
          devices.add('$ip: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
    setState(() {
      if (devices.isEmpty) {
        log.add('No se encontraron dispositivos.');
      }
    });
  }

  Future<void> _sendRequest(String action, String ip) async {
    final url = '$ip/door/$action';
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
          ElevatedButton(
            onPressed: scanDevices,
            child: const Text('Iniciar Escaneo'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(devices[index]),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title:
                              Text('Seleccionar acción para ${devices[index]}'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _sendRequest(
                                    'open', devices[index].split(':')[0]);
                                Navigator.of(context).pop();
                              },
                              child: const Text('ABRIR'),
                            ),
                            TextButton(
                              onPressed: () {
                                _sendRequest(
                                    'closed', devices[index].split(':')[0]);
                                Navigator.of(context).pop();
                              },
                              child: const Text('CERRAR'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          //agregar un ListView para mostrar logs
        ],
      ),
    );
  }
}
