import 'package:flutter/material.dart';
import 'package:flutter_application_1/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_application_1/config.dart';

class AccionesUser extends StatefulWidget {
  final String username; // Recibimos el nombre del usuario
  const AccionesUser({Key? key, required this.username}) : super(key: key);

  @override
  _AccionesUserState createState() => _AccionesUserState();
}

class _AccionesUserState extends State<AccionesUser> {
  List<String> log = [];
  bool _isLoading = false; // Para mostrar el indicador de carga
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();

    // Retrasa la ejecución para asegurar que el widget esté completamente inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Aquí puedes hacer cosas después de que el widget se haya renderizado
    });
  }

  // Función para hacer la solicitud GET a la API
  Future<void> _sendRequest(String action) async {
    // Retrasar la solicitud a la red para asegurarse de que el widget esté completamente listo
    await Future.delayed(Duration.zero);

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
          // Limitar el número de acciones a 5
          if (log.length > 5) {
            String removedAction = log.removeAt(0); // Remueve la primera acción
            // Eliminar con animación
            _removeLogItem(removedAction);
          }
          // Insertar nuevo ítem con animación
          _insertLogItem('Acción: $action, Respuesta: ${response.body}');
        });
      } else {
        setState(() {
          log.add('Error al enviar la solicitud.');
          _insertLogItem('Error al enviar la solicitud.');
        });
      }
    } catch (e) {
      setState(() {
        log.add('Error de red: $e');
        _insertLogItem('Error de red: $e');
      });
    } finally {
      setState(() {
        _isLoading = false; // Desactivamos el indicador de carga
      });
    }
  }

  // Función para insertar un log con animación
  void _insertLogItem(String item) {
    log.add(item);
    _listKey.currentState
        ?.insertItem(log.length - 1, duration: Duration(milliseconds: 300));
  }

  // Función para eliminar un log con animación
  void _removeLogItem(String item) {
    final index = log.indexOf(item);
    if (index != -1) {
      _listKey.currentState?.removeItem(
        index,
        (context, animation) {
          return FadeTransition(
            opacity: animation,
            child: ListTile(title: Text(item)),
          );
        },
        duration: Duration(
            milliseconds: 300), // Duración para la animación de eliminación
      );
    }
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
  Widget build(BuildContext context) {
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
                color: Colors.blue,
              ),
              child: Text(
                'Opciones de Usuario',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Ver Puerta'),
              onTap: () {
                // Aquí podrías agregar la lógica para ver la puerta disponible
              },
            ),
            ListTile(
              title: Text('Abrir Puerta'),
              leading: Icon(Icons.check_circle_outline), // Palomita de acción
              onTap: () {
                _sendRequest('open');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Pantalla de bienvenida con el nombre del usuario
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
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Contenedor con un logo de palomita y acción de abrir puerta
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Para alinear los elementos a los extremos
              children: <Widget>[
                // Primer "botón": solo texto dentro de un Padding
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Fondo gris claro
                        borderRadius:
                            BorderRadius.circular(20.0), // Bordes circulares
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical:
                              15.0), // Un poco de padding para que el texto no esté tan pegado
                      child: Text(
                        'Puerta 1',
                        textAlign: TextAlign.center, // Centrar el texto
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.blue, // Puedes cambiar el color del texto
                        ),
                      ),
                    ),
                  ),
                ),
                // Segundo "botón": IconButton que muestra el indicador de carga
                IconButton(
                  icon: _isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green),
                        )
                      : Icon(Icons.check_circle_outline,
                          size: 40, color: Colors.green),
                  onPressed: _isLoading ? null : () => _sendRequest('open'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Log de acciones realizadas
            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: log.length,
                itemBuilder: (context, index, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ListTile(
                      title: Text(log[index]),
                    ),
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
