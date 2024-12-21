import 'package:flutter/material.dart';
import 'package:flutter_application_1/PuertasDisponiblesPage.dart';
import 'package:flutter_application_1/login_screen.dart';
import 'package:flutter_application_1/constants.dart';

class AccionesUser extends StatefulWidget {
  final String username; // Recibimos el nombre del usuario
  const AccionesUser({Key? key, required this.username}) : super(key: key);

  @override
  _AccionesUserState createState() => _AccionesUserState();
}

class _AccionesUserState extends State<AccionesUser> {
  // Función para cerrar sesión y regresar a la pantalla de login
  void _logout(BuildContext context) {
    // Aquí podrías limpiar cualquier dato de sesión si es necesario
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginScreen()), // Regresar a la pantalla de login
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu de Usuario"),
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
                'Opciones de Usuario',
                style: TextStyle(
                  color: kPrimaryLightColor,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Ver Puertas Disponibles'),
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
              title: Text('Cerrar sesión'),
              leading: Icon(Icons.exit_to_app),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Center(
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
                  const SizedBox(height: 20),
                  Container(
                    width: size.height * 0.3,
                    height: size.height * 0.3, // Ajusta el tamaño de la imagen
                    child: Image.asset(
                      'assets/images/Usuario.jpg',
                      fit: BoxFit.cover, // Asegura que la imagen se ajuste bien
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
