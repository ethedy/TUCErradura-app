import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/Login/components/email.dart';
import 'package:flutter_application_1/Screens/Login/components/password.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Accountlog();
  }
}

class Accountlog extends StatelessWidget {
  const Accountlog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "assets/images/Background.svg", //logo IPS
                height: size.height * 0.30,
              ),

              SizedBox(height: 20),

              // Formulario de inicio de sesión
              Column(
                children: [
                  // Campo de correo electrónico
                  TextEmail(
                    onChanged: (value) {},
                  ),
                  SizedBox(height: 15),

                  // Campo de contraseña
                  Password(
                    onChanged: (value) {},
                  ),
                  SizedBox(height: 20),

                  Container(
                    width: size.width * 0.8,
                    child: Row(
                      children: <Widget>[
                        Divider(
                          height: 1.5,
                        ),
                        Text("OR")
                      ],
                    ),
                  ),

                  // Botón de inicio de sesión con Google
                  ElevatedButton.icon(
                    onPressed: () {
                      // Lógica para iniciar sesión con Google
                    },
                    icon: Icon(Icons.login),
                    label: Text("Iniciar sesión con Google"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
