
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int data = 0;
  final _serial = FlutterSerialCommunication();
  List<dynamic> _devices = [];
  bool _isConnected = false;
  String _receivedData = "";

  @override
  void initState() {
    super.initState();
    _initSerial();
  }

  Future<void> _initSerial() async {
    // Get available devices
    List<dynamic> devices = await _serial.getAvailableDevices();
    setState(() {
      _devices = devices;
    });

    // Listen for incoming serial data
    _serial.getSerialMessageListener().receiveBroadcastStream().listen((event) {
      debugPrint("🔻 Received From Device: $event");
      setState(() {
        _receivedData = "$event\n";
      });
    });

    // Listen for device connect/disconnect
    _serial.getDeviceConnectionListener().receiveBroadcastStream().listen((event) {
      debugPrint("🔌 Device Event: $event");
      setState(() {
      _receivedData = "$event\n";
  });
    });
  }

  Future<void> _connectToDevice(dynamic device) async {
    bool result = await _serial.connect(device, 9600); // use your own baud rate
    setState(() {
      _isConnected = result;
    });
    debugPrint("✅ Connected: $result");
  }

  Future<void> _sendData() async {
    if (!_isConnected) return;

    // Replace with your actual message
    final data = Uint8List.fromList([0x48, 0x65, 0x6C, 0x6C, 0x6F]); // 'Hello'
    bool sent = await _serial.write(data);
    debugPrint("📤 Sent: $sent");
  }

  Future<void> _disconnect() async {
    await _serial.disconnect();
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('USB Serial Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Available Devices:"),
              ..._devices.map((device) => ListTile(
                    title: Text(device.deviceName ?? "Unnamed Device"),
                    subtitle: Text(device.manufacturerName ?? "Unknown"),
                    trailing: ElevatedButton(
                      onPressed: () => _connectToDevice(device),
                      child: const Text("Connect"),
                    ),
                  )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isConnected ? _sendData : null,
                child: const Text("Send 'Hello'"),
              ),
              ElevatedButton(
                onPressed: _isConnected ? _disconnect : null,
                child: const Text("Disconnect"),
              ),
              Text(_isConnected ? "🔗 Connected" : "❌ Disconnected"),
              const SizedBox(height: 16),
              const Text("Received Data:"),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 150,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Text(
                    _receivedData,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
