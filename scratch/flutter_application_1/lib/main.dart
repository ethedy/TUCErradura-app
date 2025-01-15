import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_application_1/SessionManager.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/screens.dart';
=======
import 'package:flutter_application_1/screens.dart';
import 'package:flutter_application_1/config.dart';
>>>>>>> main
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants.dart';

void main() {
  runApp(
<<<<<<< HEAD
    MultiProvider(
      // Usamos MultiProvider para manejar varios proveedores
      providers: [
        ChangeNotifierProvider(create: (context) => Config()),
        ChangeNotifierProvider(
            create: (context) =>
                SessionManager()), // Añadir SessionManager como proveedor
      ],
=======
    ChangeNotifierProvider(
      create: (context) => Config(),
>>>>>>> main
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TUSErradura',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kPrimaryLightColor,
      ),
      home: Screens(),
    );
  }
}
