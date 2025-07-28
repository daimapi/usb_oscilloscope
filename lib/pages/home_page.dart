import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';
import 'package:usb_oscilloscope/widgets/LineChart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

List<double> parseDoubleList(String message) {
  return message
      .split('\n')
      .map((s) => double.tryParse(s.trim()))
      .whereType<double>()
      .where((d) => d.isFinite)
      .toList();
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  int data = 0;
  final _serial = FlutterSerialCommunication();
  List<dynamic> _devices = [];
  bool _isConnected = false;
  String _receivedData = "";
  bool _ort_portrait = true;
  List<FlSpot> _data = [];
  List<double> _datastream = [];
  Timer? _updateTimer;
  bool _isUpdateScheduled = false;
  final List<String> _pendingMessages = [];
  bool _isComputing = false;
  late final Ticker _ticker;

  double _minX = 0;
  double _maxX = 10;
  double _minY = -1.5;
  double _maxY = 1.5;

  double _scaleX = 1.0;
  double _scaleY = 1.0;

  Duration _lastUpdate = Duration.zero;

  @override
  void initState() {
    super.initState();
    _mockReceive();
    //_initSerial();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    // 每 50ms 更新一次圖表
    if (elapsed - _lastUpdate >= const Duration(milliseconds: 50)) {
      _lastUpdate = elapsed;
      _updateChart();
    }
  }

  void _updateChart() {
    final len = _datastream.length.clamp(0, 1000);
    final List<FlSpot> _nextdata = List.generate(len, (i) => FlSpot(i.toDouble(), _datastream[i]));
    setState(() {
      _data = _nextdata;
    });
  }

  void _processNextBatch() async {
    if (_pendingMessages.isEmpty) return;

    _isComputing = true;

    final batch = _pendingMessages.join();
    _pendingMessages.clear();

    try {
      final List<double> parsed = await compute(parseDoubleList, batch);//parseDoubleList(message);

      _datastream.addAll(parsed);
      if (_datastream.length > 1000) {
        _datastream.removeRange(0, _datastream.length - 1000);
      }
      if (!_isUpdateScheduled) {
        _isUpdateScheduled = true;
        _updateTimer = Timer(const Duration(milliseconds: 50), () {
          _isUpdateScheduled = false;//throttle

          //debugPrint("ndl: ${parsed.length}");
          //debugPrint("dsl: ${_datastream.length}");
          //debugPrint("🔄 Running updateTimer...");
          //final len = _datastream.length.clamp(0, 1000);
          //final List<FlSpot> _nextdata = List.generate(len, (i) => FlSpot(i.toDouble(), _datastream[i]));
          //setState(() {
          //  _data = _nextdata;
          //});
        });
      }
    } catch (e) {
      debugPrint("❌ compute error: $e");
    }

    _isComputing = false;

    if (_pendingMessages.isNotEmpty) {
      _processNextBatch();
    }
  }

  void _mockReceive() {
    Timer.periodic(const Duration(milliseconds: 1), (timer) {
      final value = sin(DateTime.now().millisecondsSinceEpoch / 100.0);
      _onDataReceived("$value\n");
      //debugPrint("📈 Mock value: $value");
    });
    debugPrint("🔧 Mock started");
  } // 模擬收到資料

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onDataReceived(String message) async{//{
    /*try {
      final List<double> newData = message
          .split('\n')
          .map((s) => double.tryParse(s.trim()))
          .whereType<double>()
          .where((d) => d.isFinite)
          .toList();

      _datastream.addAll(newData);

      // 保留最多 1000 筆資料
      if (_datastream.length > 1000) {
        _datastream.removeRange(0, _datastream.length - 1000);
      }

      // debounce 更新圖表
      _updateTimer?.cancel();
      _updateTimer = Timer(const Duration(milliseconds: 50), () {
        debugPrint("🔄 Running updateTimer...");
        setState(() => _data = List.generate(1000, (i) {
          final x = i / 100;
          final y = _datastream[i];
            return FlSpot(x, y);}));
      });
    } catch (e) {
      debugPrint("❌ error: $e");
    }
    debugPrint("🖼️ UI updated: ${_data.length} points");
    debugPrint("🖼️ UI updated: ${_datastream.length} points");*/
    /*try {
      final List<double> newData = await compute(parseDoubleList, message);//parseDoubleList(message);

      _datastream.addAll(newData);
      if (_datastream.length > 1000) {
        _datastream.removeRange(0, _datastream.length - 1000);
      }

      // ✅ Throttle: 若尚未安排更新，則安排一個
      if (!_isUpdateScheduled) {
        _isUpdateScheduled = true;
        _updateTimer = Timer(const Duration(milliseconds: 50), () {
          _isUpdateScheduled = false;

          debugPrint("ndl: ${newData.length}");
          debugPrint("dsl: ${_datastream.length}");
          debugPrint("🔄 Running updateTimer...");
          final len = _datastream.length.clamp(0, 1000);
          setState(() {
            /*_data = List.generate(len, (i) {
              final x = i.toDouble();
              final y = _datastream[i];
              return FlSpot(x, y);
            });*/
            _data = List.generate(len, (i) => FlSpot(i.toDouble(), _datastream[i]));
          });
        });
      }

    } catch (e) {
      debugPrint("❌ error: $e");
    }*/
    _pendingMessages.add(message);

    if (!_isComputing) {
      _processNextBatch();  // 只有一個 compute 跑著
    }
  }

  Future<void> _initSerial() async {
    List<dynamic> devices = await _serial.getAvailableDevices();
    setState(() => _devices = devices);

    _serial.getSerialMessageListener().receiveBroadcastStream().listen((event) {
      String message;
      if (event is String) {
        message = event;
      } else if (event is List<int>) {
        message = String.fromCharCodes(event);
      } else {
        message = event.toString();
      }//income message to string
      _onDataReceived(message);
    });

    _serial.getDeviceConnectionListener().receiveBroadcastStream().listen((event) {
      debugPrint("🔌 Device Event: $event");
    });
  }

  Future<void> _connectToDevice(dynamic device) async {
    bool result =
    await _serial.connect(device, 2000000); // use your own baud rate
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

  void _applyScale() {
    final xCenter = (_minX + _maxX) / 2;
    final yCenter = (_minY + _maxY) / 2;

    final xRange = 10 / _scaleX;
    final yRange = 3 / _scaleY;

    setState(() {
      _minX = xCenter - xRange / 2;
      _maxX = xCenter + xRange / 2;
      _minY = yCenter - yRange / 2;
      _maxY = yCenter + yRange / 2;
    });
  } //gpt ass

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
          return Column(
            children: [
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Chart(
                    data: _data,
                    minX: _minX,
                    maxX: _maxX,
                    minY: _minY,
                    maxY: _maxY,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: _scaleX,
                min: 0.1,
                max: 2.0,
                divisions: 45,
                label: "X 縮放 ${_scaleX.toStringAsFixed(2)}x",
                onChanged: (value) {
                  setState(() {
                    _scaleX = value;
                    _applyScale();
                  });
                },
              ),
              Slider(
                value: _scaleY,
                min: 0.1,
                max: 2.0,
                divisions: 45,
                label: "Y 縮放 ${_scaleY.toStringAsFixed(2)}x",
                onChanged: (value) {
                  setState(() {
                    _scaleY = value;
                    _applyScale();
                  });
                },
              ),
              Text(_receivedData),
            ],
          );

          /*InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 5.0,
          child: SizedBox(
              //width: 1000,
              height: 300,
              child: Chart(
                data: _data,
                minX: _minX,
                maxX: _maxX,
                minY: _minY,
                maxY: _maxY,
              )),
        );*/ //without gesture

          /*Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              //const SizedBox(height: 16),
              //Text(_isConnected ? "🔗 Connected" : "❌ Disconnected"),
              //const SizedBox(height: 16),
              //Text("Received Data: $_receivedData"),
            ],
          ),
        );*/
        }),
      ); //);
  }
}
