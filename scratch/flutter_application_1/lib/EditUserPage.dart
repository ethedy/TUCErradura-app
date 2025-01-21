import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class EditUserPage extends StatefulWidget {
  final String
      email; // Cambié 'username' por 'email' para tener un identificador único.

  const EditUserPage({
    super.key,
    required this.email,
  });

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  Map<String, dynamic> userInfo =
      {}; // Variable para almacenar la información del usuario.
  Map<String, List<Map<String, String>>> schedule =
      {}; // Para almacenar los horarios del usuario

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _fetchUserInfo(); // Llamada para obtener la información del usuario
  }

  // Obtener la información del usuario desde el servidor
  Future<void> _fetchUserInfo() async {
    final apiUrl = Provider.of<Config>(context, listen: false).editUser;

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': widget.email}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userInfo =
            data['user']; // Guardamos la información del usuario en la variable
        _usernameController.text = userInfo['name'];
        _emailController.text = userInfo['email'];
        schedule = userInfo['schedule'] ??
            {}; // Si no tiene horarios, asignamos un mapa vacío
      });
    } else {
      // Manejo de error si no se encuentra al usuario
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudo obtener la información del usuario'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Función para guardar los cambios
  Future<void> _saveChanges() async {
    final apiUrl = Provider.of<Config>(context, listen: false).editUser;
    final updatedUser = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'schedule': schedule, // Enviamos los horarios modificados
    };

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedUser),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // Cerrar la página al guardar los cambios
    } else {
      // Si ocurre algún error en la actualización, muestra un mensaje
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('No se pudo guardar la información del usuario'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Función para seleccionar horario de un día
  Future<void> _selectTime(String day) async {
    final selectedDaySchedule = schedule[day] ?? [];
    final selectedTimes = await showDialog<List<Map<String, String>>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Horarios para $day'),
          content: ListView.builder(
            itemCount: selectedDaySchedule.length +
                1, // Agregar un botón para nuevo horario
            itemBuilder: (context, index) {
              if (index == selectedDaySchedule.length) {
                return ListTile(
                  title: Text('Añadir nuevo horario'),
                  onTap: () {
                    Navigator.pop(context, [
                      ...selectedDaySchedule,
                      {'start': '00:00', 'end': '01:00'}
                    ]);
                  },
                );
              }
              final time = selectedDaySchedule[index];
              return ListTile(
                title: Text('${time['start']} - ${time['end']}'),
                onTap: () async {
                  // Selección de nuevo horario
                  final timeRange = await _pickTimeRange(context);
                  if (timeRange != null) {
                    selectedDaySchedule[index] = {
                      'start': timeRange[0],
                      'end': timeRange[1]
                    };
                    setState(() {
                      schedule[day] = selectedDaySchedule;
                    });
                  }
                },
              );
            },
          ),
        );
      },
    );
    if (selectedTimes != null) {
      setState(() {
        schedule[day] = selectedTimes;
      });
    }
  }

  // Método para seleccionar el rango de tiempo
  Future<List<String>?> _pickTimeRange(BuildContext context) async {
    final start =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (start == null) return null;
    final end = await showTimePicker(context: context, initialTime: start);
    if (end == null) return null;
    return [start.format(context), end.format(context)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nombre de usuario'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            ..._buildScheduleWidgets(), // Mostrar los horarios
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  // Función para construir los widgets de los horarios de los días de la semana
  List<Widget> _buildScheduleWidgets() {
    final scheduleWidgets = <Widget>[];
    schedule.forEach((day, times) {
      scheduleWidgets.add(
        ListTile(
          title: Text(day),
          subtitle: Text(times.isEmpty
              ? 'No hay horarios disponibles'
              : times.map((e) => '${e['start']} - ${e['end']}').join(', ')),
          onTap: () => _selectTime(day),
        ),
      );
    });
    return scheduleWidgets;
  }
}
