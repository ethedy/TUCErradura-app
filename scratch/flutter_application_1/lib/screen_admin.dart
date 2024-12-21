import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_application_1/config.dart';

class AccionesAdmin extends StatefulWidget {
  final String username;
  const AccionesAdmin({Key? key, required this.username}) : super(key: key);

  @override
  _AccionesAdminState createState() => _AccionesAdminState();
}

class _AccionesAdminState extends State<AccionesAdmin> {
  List<String> doors = []; // Lista de puertas
  List<String> users = []; // Lista de usuarios
  bool _isLoading = false;

  // Función para obtener la lista de puertas desde el servidor
  Future<void> _getDoors() async {
    setState(() {
      _isLoading = true;
    });

    final apiUrl = Provider.of<Config>(context, listen: false).apiUrl;
    final url =
        '$apiUrl/doors'; // Suponiendo que la URL para obtener puertas es '/doors'

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          doors = response.body.split(
              ','); // Supongamos que las puertas están separadas por comas
        });
      } else {
        setState(() {
          doors = [];
        });
      }
    } catch (e) {
      setState(() {
        doors = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para abrir una puerta
  Future<void> _openDoor(String doorId) async {
    setState(() {
      _isLoading = true;
    });

    final apiUrl = Provider.of<Config>(context, listen: false).apiUrl;
    final url =
        '$apiUrl/doorOpen/$doorId'; // Suponiendo que la URL para abrir la puerta es '/doorOpen/{doorId}'

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Mostrar un mensaje de éxito o actualizar estado
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Puerta $doorId abierta')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al abrir la puerta')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para obtener la lista de usuarios desde la base de datos
  Future<void> _getUsers() async {
    setState(() {
      _isLoading = true;
    });

    final apiUrl = Provider.of<Config>(context, listen: false).apiUrl;
    final url =
        '$apiUrl/users'; // Suponiendo que la URL para obtener usuarios es '/users'

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          users = response.body.split(
              ','); // Supongamos que los usuarios están separados por comas
        });
      } else {
        setState(() {
          users = [];
        });
      }
    } catch (e) {
      setState(() {
        users = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para agregar un nuevo usuario
  Future<void> _addUser(String name, String email, String password) async {
    final apiUrl = Provider.of<Config>(context, listen: false).apiUrl;
    final url =
        '$apiUrl/addUser'; // Suponiendo que la URL para agregar un usuario es '/addUser'

    try {
      final response = await http.post(Uri.parse(url), body: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Actualizar lista de usuarios después de agregar uno nuevo
        setState(() {
          users.add('$name ($email)'); // Agregar el nuevo usuario a la lista
        });
        Navigator.pop(context); // Cerrar el popup
      } else {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al agregar el usuario')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al agregar el usuario')));
    }
  }

  // Función para mostrar el formulario emergente (popup) de agregar usuario
  void _showAddUserDialog() {
    String name = '';
    String email = '';
    String password = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Nuevo Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
              ),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el popup
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _addUser(name, email,
                    password); // Llamar a la función para agregar el usuario
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  // Función para cerrar sesión y regresar a la pantalla de login
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginScreen()), // Regresar a la pantalla de login
    );
  }

  @override
  void initState() {
    super.initState();
    _getDoors();
    _getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú de Administrador"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context), // Cerrar sesión
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: kPrimaryColor,
              ),
              child: Text(
                'Opciones de Administrador',
                style: TextStyle(
                  color: kPrimaryLightColor,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Ver Puertas'),
              onTap: () {
                _getDoors();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Ver Usuarios'),
              onTap: () {
                _getUsers();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Agregar Usuario'),
              onTap: () {
                _showAddUserDialog(); // Mostrar el formulario de agregar usuario
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  const Text(
                    'Hola',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.username, // Nombre del usuario recibido
                    style: TextStyle(
                      fontSize: 20,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Mostrar las puertas disponibles
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: doors.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Puerta ${doors[index]}'),
                          trailing: IconButton(
                            icon: Icon(Icons.check_circle_outline),
                            onPressed: () {
                              _openDoor(doors[index]);
                            },
                          ),
                        );
                      },
                    ),
                  ),
            // Mostrar los usuarios disponibles
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index]),
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
