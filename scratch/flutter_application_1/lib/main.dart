import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens.dart';
import 'package:flutter_application_1/config.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/constants.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Config(),
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
