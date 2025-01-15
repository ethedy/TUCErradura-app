import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class EditUserPage extends StatefulWidget {
  final String username;

  const EditUserPage({
    super.key,
    required this.username,
  });

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  String? selectedDay;
  TimeOfDay? selectedTime;
  String? selectedDoor;

  final List<String> days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes'
  ];
  final List<String> doors = ['Puerta 1', 'Puerta 2', 'Puerta 3'];

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores de los campos con los valores por defecto
    _usernameController = TextEditingController(text: widget.username);
    _emailController =
        TextEditingController(); // Lo puedes llenar con los datos iniciales de la API
    selectedDay = null;
    selectedTime = null;
    selectedDoor = null;
  }

  // Función para guardar los cambios
  Future<void> _saveChanges() async {
    final apiUrl = Provider.of<Config>(context, listen: false).usuariosEndpoint;
    // Aquí puedes agregar la lógica para enviar los cambios al servidor (PUT request)
    final updatedUser = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'day': selectedDay,
      'time': selectedTime?.format(context),
      'door': selectedDoor,
    };

    // Aquí realizarías la solicitud PUT al servidor
    // Por ejemplo:
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedUser),
    );

    // Si la actualización fue exitosa, puedes cerrar la pantalla y volver a la lista de usuarios.
    Navigator.pop(context);
    // Si hay algún error, podrías mostrar un mensaje de error.
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
            _buildDropdown('día', selectedDay, days, (newValue) {
              setState(() {
                selectedDay = newValue;
              });
            }),
            _buildTimePicker(),
            _buildDropdown('puerta', selectedDoor, doors, (newValue) {
              setState(() {
                selectedDoor = newValue;
              });
            }),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para los Dropdowns de selección
  Widget _buildDropdown<T>(String label, String? selectedValue,
      List<String> options, Function(String?) onChanged) {
    return DropdownButton<String>(
      value: selectedValue,
      hint: Text('Selecciona $label'),
      onChanged: (newValue) {
        onChanged(newValue);
      },
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );
  }

  Widget _buildTimePicker() {
    return ListTile(
      title: Text('Selecciona Horario'),
      subtitle: Text(selectedTime?.format(context) ?? 'Selecciona un horario'),
      onTap: () async {
        final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() {
            selectedTime = time;
          });
        }
      },
    );
  }
}
