import 'package:flutter/material.dart';
import 'package:flutter_application_1/SessionManager.dart';
import 'package:flutter_application_1/UsuariosDisponibles.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/login_screen.dart';
import 'package:flutter_application_1/PuertasDisponiblesPage.dart';
import 'package:provider/provider.dart';

class AccionesAdmin extends StatefulWidget {
  final String username;
  const AccionesAdmin({super.key, required this.username});

  @override
  _AccionesAdminState createState() => _AccionesAdminState();
}

class _AccionesAdminState extends State<AccionesAdmin> {
  // Función para cerrar sesión y regresar a la pantalla de login
  void _logout(BuildContext context) {
    // Limpiar el token de autenticación
    final config = Provider.of<Config>(context, listen: false);
    config.clearAuthToken(); // Limpiar el token al desloguearse

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginScreen()), // Regresar a la pantalla de login
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el SessionManager y Config
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    final config = Provider.of<Config>(context, listen: false);

    // Registrar el contexto de la pantalla actual
    sessionManager.setContext(context);

    // Verificar si la sesión ha expirado
    sessionManager.checkSessionExpiration(config);
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UsuariosPage(username: widget.username),
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
