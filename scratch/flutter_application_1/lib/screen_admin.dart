import 'package:flutter/material.dart';
import 'package:flutter_application_1/PuertasDisponiblesPage.dart';
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
    Size size = MediaQuery.of(context).size;
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
              title: Text('Lista de Puertas Disponibles'),
              leading: Icon(Icons.door_front_door),
              onTap: () {
                // Navegar a la página de Puertas Disponibles
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PuertasDisponiblesPage(username: widget.username),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Lista de Usuarios Verificados'),
              leading: Icon(Icons.verified_user),
              onTap: () {
                _getUsers();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Agregar Usuarios'),
              leading: Icon(Icons.supervised_user_circle),
              onTap: () {
                _showAddUserDialog(); // Mostrar el formulario de agregar usuario
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Cerrar sesión'),
              leading: Icon(Icons.exit_to_app),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Stack(
        // Usamos Stack para posicionar la imagen en la parte inferior derecha
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Centrar los elementos
                children: <Widget>[
                  // Pantalla de bienvenida con el nombre del usuario
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Bienvenido al TUSE',
                        style: TextStyle(
                          fontSize: 20,
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
                      const SizedBox(height: 10),
                      Container(
                        width: size.height * 0.3,
                        height:
                            size.height * 0.3, // Ajusta el tamaño de la imagen
                        child: Image.asset(
                          'assets/images/administrador.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Image.asset(
              'assets/images/logo-IPS-UNR.png',
              width: size.width * 0.3, // Ajusta el tamaño de la imagen
            ),
          ),
          // Imagen en la parte inferior izquierda
          Positioned(
            bottom: 16,
            left: 16,
            child: Image.asset(
              'assets/images/Depto Electro.jpg', // Nombre de la nueva imagen
              width: size.width * 0.1, // Ajusta el tamaño de la imagen
            ),
          ),
        ],
      ),
    );
  }
}
