import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/HttpService.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/config.dart';

/*¿Qué hace este programa?
Carga los datos del usuario desde el servidor:
    Utiliza el email como identificador.
    Hace una solicitud GET usando un token de autenticación.
    Recupera el nombre, email y horarios laborales (estructura de franjas horarias por día).
Muestra un formulario editable:
    Campo de texto para el nombre.
    Email mostrado pero deshabilitado.
    Días de la semana como chips seleccionables.
    Editor de horarios (inicio/fin) para cada día seleccionado.
Permite modificar y guardar los cambios:
    Se pueden agregar o quitar franjas horarias por día.
    Al guardar, se hace una solicitud PUT al backend para actualizar los datos.
Manejo de errores y estados:
    Indicador de carga mientras se obtienen los datos.
    Mensajes de error si hay problemas de conexión o si el token no está presente.
    Diálogos (AlertDialog) para informar al usuario sobre el estado de la operación.
*/
class EditUserPage extends StatefulWidget {
  final String email;
  final String lastname;

  const EditUserPage({super.key, required this.email, required this.lastname});

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  Map<String, List<Map<String, String>>> _schedule = {};
  bool _isLoading = false;
  bool _hasError = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<String> _daysOfWeek = [
    'Lun',
    'Mar',
    'Mie',
    'Jue',
    'Vie',
    'Sab',
    'Dom'
  ];
  final Map<String, bool> _selectedDays = {};

  @override
  void initState() {
    super.initState();
    for (var day in _daysOfWeek) {
      _selectedDays[day] = false;
    }
    _fetchUserData();
  }

  bool _dataLoaded = false; // Nueva bandera

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _dataLoaded = false;
    });

    final config = Provider.of<Config>(context, listen: false);
    final apiUrl = config.editUser;
    final token = await config.authToken;

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
        final body = json.decode(response.body);
        final data = body['user'];
        if (data == null) {
          setState(() {
            _hasError = true;
            _dataLoaded = true; // Para mostrar el formulario
          });
          _showDialog('Error', 'No se pudo cargar la información del usuario.');
          return;
        }

        final name = data['name'] ?? '';
        final lastname = data['lastname'] ?? '';
        final email = data['email'] ??
            widget.email; // Usa el email del widget como fallback
        final scheduleData = Map<String, dynamic>.from(data['schedule'] ?? {});
        Map<String, List<Map<String, String>>> parsedSchedule = {};

        scheduleData.forEach((key, value) {
          parsedSchedule[key] = List<Map<String, String>>.from(
            value.map((item) => Map<String, String>.from(item)),
          );
          _selectedDays[key] = true;
        });

        setState(() {
          _schedule = parsedSchedule;
          _nameController.text = name;
          _lastnameController.text = lastname;
          _emailController.text = email;
          _dataLoaded = true;
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
        _dataLoaded = true;
      });
    }
  }

  Future<void> _saveUserChanges() async {
    final config = Provider.of<Config>(context, listen: false);
    final apiUrl = config.editUser;
    final token = await config.authToken;

    if (token == null) {
      _showDialog('Error', 'No se encontró el token de autenticación.');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final updatedUser = {
        'name': _nameController.text.trim(),
        'lastname': _lastnameController.text.trim(),
        'email': _emailController.text.trim(),
        'schedule': _schedule,
      };
      print('Payload para actualización: $updatedUser');

      final response = await HttpService()
          .putRequest('$apiUrl/${widget.email}', updatedUser, token);

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

  void _addTimeSlot(String day) {
    setState(() {
      _schedule[day] ??= [];
      _schedule[day]!.add({'start': '', 'end': ''});
    });
  }

  void _removeTimeSlot(String day, int index) {
    setState(() {
      _schedule[day]?.removeAt(index);
    });
  }

  Widget _buildScheduleEditor(String day) {
    List<Map<String, String>> timeSlots = _schedule[day] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < timeSlots.length; i++)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: timeSlots[i]['start'],
                  decoration: InputDecoration(labelText: 'Inicio'),
                  onChanged: (value) {
                    setState(() {
                      _schedule[day]![i]['start'] = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: timeSlots[i]['end'],
                  decoration: InputDecoration(labelText: 'Fin'),
                  onChanged: (value) {
                    setState(() {
                      _schedule[day]![i]['end'] = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeTimeSlot(day, i),
              ),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: Icon(Icons.add),
            label: Text('Agregar franja'),
            onPressed: () => _addTimeSlot(day),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _showDialog(String title, String content) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
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
              ? Center(child: Text('Hubo un error al cargar los datos.'))
              : !_dataLoaded
                  ? Center(child: Text('Cargando datos del usuario...'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Nombre',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _lastnameController,
                              decoration: InputDecoration(
                                labelText: 'Apellido',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 24),
                            Text('Selecciona los días laborales:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Wrap(
                              spacing: 10,
                              children: _daysOfWeek.map((day) {
                                return FilterChip(
                                  label: Text(day),
                                  selected: _selectedDays[day]!,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _selectedDays[day] = selected;
                                      if (!selected) {
                                        _schedule.remove(day);
                                      } else {
                                        _schedule[day] ??= [];
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 24),
                            ..._selectedDays.entries
                                .where((entry) => entry.value)
                                .map((entry) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 16),
                                        Text(entry.key,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                        _buildScheduleEditor(entry.key),
                                      ],
                                    )),
                            SizedBox(height: 24),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _saveUserChanges,
                                icon: Icon(Icons.save),
                                label: Text('Guardar Cambios'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
