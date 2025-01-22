import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HttpService.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/config.dart';

class EditUserPage extends StatefulWidget {
  final String email; // Email del usuario a editar

  const EditUserPage({super.key, required this.email});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late String _name;
  late String _email;
  late Map<String, List<Map<String, String>>>
      _schedule; // Para manejar el horario
  bool _isLoading = false;
  bool _hasError = false;

  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Obtener los datos del usuario desde el servidor
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final config = Provider.of<Config>(context, listen: false);
    final apiUrl =
        config.editUser; // Endpoint para obtener los datos del usuario
    final token = await config.authToken;

    // Verificar que el token no sea nulo
    if (token == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    try {
      final response =
          await HttpService().getRequest('$apiUrl/${widget.email}', token);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Verificar si los datos esenciales están presentes
        if (data == null || data['name'] == null || data['email'] == null) {
          setState(() {
            _hasError = true;
          });
          _showDialog('Error', 'Los datos del usuario están incompletos.');
          return;
        }

        // Si 'schedule' no está presente, inicializarlo como un mapa vacío
        var scheduleData = data['schedule'] ?? {};

        setState(() {
          _name = data['name'];
          _email = data['email'];
          _schedule = Map<String, List<Map<String, String>>>.from(
              scheduleData); // Asegurarnos de que 'schedule' sea un mapa

          // Rellenamos los controladores con la información del usuario
          _nameController.text = _name;
          _emailController.text = _email;
        });
      } else {
        setState(() {
          _hasError = true;
        });
        _showDialog('Error', 'No se pudo obtener la información del usuario.');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      _showDialog(
          'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para mostrar un AlertDialog
  void _showDialog(String title, String content) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context), // Cierra el diálogo
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Función para guardar los cambios del usuario
  Future<void> _saveUserChanges() async {
    final config = Provider.of<Config>(context, listen: false);
    final apiUrl = config.editUser; // Endpoint para editar el usuario
    final token = await config.authToken;

    // Verificar que el token no sea nulo
    if (token == null) {
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    // Realizamos la solicitud PUT para editar los datos del usuario
    try {
      setState(() {
        _isLoading = true;
      });

      final updatedUser = {
        'name': _nameController.text,
        'email': _emailController.text,
        'schedule': _schedule, // Se envía el horario actualizado
      };

      final response =
          await HttpService().putRequest(apiUrl, updatedUser, token);

      if (response.statusCode == 200) {
        _showDialog('Éxito', 'Usuario actualizado correctamente.');
      } else {
        _showDialog('Error', 'No se pudo actualizar el usuario.');
      }
    } catch (e) {
      _showDialog(
          'Error de Red', 'No se pudo conectar al servidor. Detalles: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Cargar los datos del usuario al inicio
  }

  // Función para editar el horario (schedule) de un día
  Widget _buildScheduleField(String day) {
    List<Map<String, String>> daySchedule = _schedule[day] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        ...daySchedule.map((period) {
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: period['start'],
                  decoration: InputDecoration(labelText: 'Start Time'),
                  onChanged: (value) {
                    setState(() {
                      period['start'] = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: period['end'],
                  decoration: InputDecoration(labelText: 'End Time'),
                  onChanged: (value) {
                    setState(() {
                      period['end'] = value;
                    });
                  },
                ),
              ),
            ],
          );
        }).toList(),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Usuario'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Text('Hubo un error al cargar los datos del usuario'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Nombre del usuario
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Email del usuario (solo lectura)
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          enabled: false, // No editable
                        ),
                        SizedBox(height: 16),

                        // Horario de trabajo (schedule)
                        ...['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom']
                            .map((day) => _buildScheduleField(day)),

                        SizedBox(height: 32),

                        // Botón para guardar cambios
                        ElevatedButton(
                          onPressed: _saveUserChanges,
                          child: Text('Guardar Cambios'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
