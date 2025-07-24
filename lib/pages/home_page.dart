import 'dart:typed_data';
import 'package:flutter/services.dart';
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
  bool _ort_portrait = true;

  @override
  void initState() {
    super.initState();
    _initSerial();
  }

  Future<void> _initSerial() async {
    // Get available devices
    List<dynamic> devices = await _serial.getAvailableDevices();
    setState(
        () => _devices = devices); //expression body: () => fn same_as () {fn}

    // Listen for incoming serial data
    _serial.getSerialMessageListener().receiveBroadcastStream().listen((event) {
      debugPrint("🔻 Received From Device: $event");
      String message;
      if (event is String) {
        message = event;
      } else if (event is List<int>) {
        message = String.fromCharCodes(event);
      } else {
        message = event.toString();
      }
      setState(() => _receivedData = "$message\n");
    });

    // Listen for device connect/disconnect
    _serial
        .getDeviceConnectionListener()
        .receiveBroadcastStream()
        .listen((event) {
      debugPrint("🔌 Device Event: $event");
      setState(() => _receivedData = "$event\n");
    });
  }

  Future<void> _connectToDevice(dynamic device) async {
    bool result = await _serial.connect(device, 9600); // use your own baud rate
    setState(() => _isConnected = result);
    debugPrint("✅ Connected: $result");
  }

  Future<void> _refresh(BuildContext context) async {
    debugPrint("Refresh");
    _devices = [];
    _receivedData = "";
    await _initSerial();
    if (!context.mounted) return; // Ensure context is still valid
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ..._devices.map((device) => ListTile(
                    title: Text(device.deviceName ?? "Unnamed Device"),
                    subtitle: Text(device.manufacturerName ?? "Unknown"),
                    trailing: IconButton(
                      onPressed: () {
                        _connectToDevice(device);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.usb),
                    ),
                  )),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _disconnect() async {
    await _serial.disconnect();
    setState(() => _isConnected = false);
  }

  Future<void> _orientation() async {
    if (_ort_portrait) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return //MaterialApp(
        //home: Scaffold(
        Scaffold(
      appBar: AppBar(
        title: const Text('USB Serial'),
        actions: <Widget>[
          IconButton(
              onPressed: _isConnected ? _disconnect : null,
              icon: Icon(Icons.usb_off)),
          IconButton(
              onPressed: _isConnected ? null : () => _refresh(context),
              icon: Icon(Icons.find_replace)),
          IconButton(
              onPressed: _orientation,
              icon: Icon(_ort_portrait
                  ? Icons.stay_primary_landscape
                  : Icons.screen_rotation)),
        ],
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        if (_ort_portrait != isPortrait) {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => setState(() => _ort_portrait = isPortrait));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //const Text("Available Devices:"),
              /*..._devices.map((device) => ListTile(
                    title: Text(device.deviceName ?? "Unnamed Device"),
                    subtitle: Text(device.manufacturerName ?? "Unknown"),
                    trailing: IconButton(
                      onPressed: () => _connectToDevice(device),
                      icon: Icon(Icons.usb),
                    ),
                  )),*/
              const SizedBox(height: 16),
              Text(_isConnected ? "🔗 Connected" : "❌ Disconnected"),
              const SizedBox(height: 16),
              Text("Received Data: $_receivedData"),
              /*Container(
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
              ),*/
            ],
          ),
        );
      }),
    ); //);
  }
}
