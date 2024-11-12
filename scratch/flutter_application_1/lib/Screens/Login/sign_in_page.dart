import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Imagen SVG en la parte superior
            SvgPicture.asset(
              "assets/icons/Background.svg",
              height: size.height * 0.30, // Ajusta el tamaño de la imagen
            ),

            // Espacio entre la imagen y los campos de entrada
            SizedBox(height: 20),

            // Formulario de inicio de sesión
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Campo de correo electrónico
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Campo de contraseña
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Botón de inicio de sesión con Google
                  ElevatedButton.icon(
                    onPressed: () {
                      // Lógica para iniciar sesión con Google
                    },
                    icon: Icon(Icons.login),
                    label: Text("Iniciar sesión con Google"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue, // Color del botón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Espacio debajo del botón de Google
            SizedBox(height: 20),

            // Opción para crear cuenta
            TextButton(
              onPressed: () {
                // Lógica para redirigir a la pantalla de registro
              },
              child: Text("¿No tienes una cuenta? Regístrate"),
            ),
          ],
        ),
      ),
    );
  }
}
