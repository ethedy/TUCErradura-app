import 'package:flutter/material.dart';
import 'package:flutter_application_1/PuertasDisponiblesPage.dart';
import 'package:flutter_application_1/UsuariosDisponibles.dart';
import 'package:flutter_application_1/login_screen.dart';

class AccionesAdmin extends StatefulWidget {
  final String username;
  const AccionesAdmin({super.key, required this.username});

  @override
  _AccionesAdminState createState() => _AccionesAdminState();
}

class _AccionesAdminState extends State<AccionesAdmin> {
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
                color: Colors.blue,
              ),
              child: Text(
                'Opciones de Administrador',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Lista de Puertas '),
              onTap: () {
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
              title: Text('Lista de Usuarios'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UsuariosPage(username: widget.username),
                  ),
                );
              },
            ),
            /*ListTile(
              title: Text('Agregar Usuario'),
              onTap: () {
                _showAddUserDialog(); // Mostrar el formulario de agregar usuario
                Navigator.pop(context);
              },
            ),*/
            ListTile(
              title: Text('Cerrar Sesion'),
              leading: Icon(Icons.exit_to_app),
              onTap: () => _logout(context),
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
                    'Bienvenido al TUSE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.username, // Nombre del usuario recibido
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
