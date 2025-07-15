import 'package:flutter/material.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';

import 'package:usb_oscilloscope/pages/home_page.dart';

final _flutterSerialCommunicationPlugin = FlutterSerialCommunication();

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "among us"),
    );
  }
}