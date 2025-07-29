//ontick+notbdr+counttorecordthrottle
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
//import 'package:usb_oscilloscope/widgets/rtosc.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:usb_oscilloscope/pages/view_page.dart';

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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int data = 0;
  final _serial = FlutterSerialCommunication();
  List<dynamic> _devices = [];
  bool _isConnected = false;

  //String _receivedData = "";
  bool _ort_portrait = true;
  List<double> _datastream = [];
  Timer? _updateTimer;
  bool _isUpdateScheduled = false;
  final List<String> _pendingMessages = [];
  bool _isComputing = false;
  late final Ticker _ticker;
  final ValueNotifier<List<double>> _dataStreamNotifier = ValueNotifier([]);
  bool _isHold = false;
  final TextEditingController _secondsController = TextEditingController();
  bool _isRecording = false;
  late double _seconds;
  int _VolLevel = 0;

  //double _minX = 0;
  //double _maxX = 10;
  double _minY = -1.5;
  double _maxY = 1.5;
  double _offsetY = 0.0;
  double _scaleX = 1.0;
  double _scaleY = 1.0;
  double _ratio = 0.4;

  Duration _lastUpdate = Duration.zero;

  @override
  void initState() {
    super.initState();
    //_mockReceive();
    _initSerial();
    _ticker = Ticker(_onTick)..start();
  }

  Future<void> _changeVolLevel(int target) async {
    if (!_isConnected) return;
    late List<int> sdata;
    switch (target) {
      case 0:
        sdata = [0x30];
        break;
      case 1:
        sdata = [0x31];
        break;
      case 2:
        sdata = [0x32];
        break;
      case 3:
        sdata = [0x33];
        break;
    }
    _VolLevel = target;
    bool sent = await _serial.write(Uint8List.fromList(sdata));
    debugPrint("Sent: $sent");
    setState(() {});
  }

  void _startRecording() {
    final seconds = double.tryParse(_secondsController.text.trim());
    if (seconds == null || seconds <= 0) return;
    _seconds = seconds;

    setState(() {
      _isHold = true; // 暫停畫面更新
      _isRecording = true;
      _datastream.clear();
    });
  }

  void _onTick(Duration elapsed) {
    if (_isHold) return;
    // 每 16ms 更新一次圖表
    if (elapsed - _lastUpdate >= const Duration(milliseconds: 16)) {
      _lastUpdate = elapsed;
      _dataStreamNotifier.value = List.from(_datastream);
    }
  }

  void _processNextBatch() async {
    if (_pendingMessages.isEmpty) return;

    _isComputing = true;

    final batch = _pendingMessages.join();
    _pendingMessages.clear();

    try {
      final List<double> parsed =
          await compute(parseDoubleList, batch); //parseDoubleList(message);

      _datastream.addAll(parsed);
      if (_isRecording) {
        if (_datastream.length >= _seconds * 1000) {
          if (_datastream.length > _seconds * 1000) {
            _datastream.removeRange(
                (_seconds * 1000).toInt(), _datastream.length);
          }
          _dataStreamNotifier.value = List.from(_datastream);
          _isRecording = false;
          _pendingMessages.clear();
          setState(() {});
        }
      }else{
        if (_datastream.length > 1000) {
          _datastream.removeRange(0, _datastream.length - 1000);
        }
        if (!_isUpdateScheduled) {
          _isUpdateScheduled = true;
          _updateTimer = Timer(const Duration(milliseconds: 50), () {
            _isUpdateScheduled = false; //throttle

            //debugPrint("ndl: ${parsed.length}");
            //debugPrint("🔄 Running updateTimer...");
            //final len = _datastream.length.clamp(0, 1000);
            //_dataStreamNotifier.value = List.from(_datastream);
          });
        }
      }

      debugPrint("dsl: ${_datastream.length}");
      debugPrint("ndl: ${parsed.length}");
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

  void _onDataReceived(String message) async {
    //{
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
    if (_isHold && !_isRecording) return;
    _pendingMessages.add(message);

    if (!_isComputing) {
      _processNextBatch(); // 只有一個 compute 跑著
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
      } //income message to string
      _onDataReceived(message);
    });

    _serial
        .getDeviceConnectionListener()
        .receiveBroadcastStream()
        .listen((event) {
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
    //_receivedData = "";
    _VolLevel = 0;
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
      _ort_portrait = false;
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      _ort_portrait = true;
    }
    setState(() {});
  }

  void _applyScale() {
    //final xCenter = (_minX + _maxX) / 2;
    //final yCenter = (_minY + _maxY) / 2;

    //final xRange = 10 / _scaleX;
    final yRange = 3 / _scaleY;

    setState(() {
      //_minX = xCenter - xRange / 2;
      //_maxX = xCenter + xRange / 2;
      _minY = _offsetY - yRange / 2;
      _maxY = _offsetY + yRange / 2;
    });
  } //gpt ass

  @override
  void dispose() {
    _ticker.dispose();
    _dataStreamNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * _ratio;
    return //MaterialApp(
        //home: Scaffold(
        Scaffold(
            appBar: AppBar(
              title: const Text('USB Serial'),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    switch (_VolLevel) {
                      case 0:
                        _changeVolLevel(1);
                        break;
                      case 1:
                        _changeVolLevel(2);
                        break;
                      case 2:
                        _changeVolLevel(3);
                        break;
                      case 3:
                        _changeVolLevel(0);
                        break;
                    }
                  },
                  icon: switch (_VolLevel) {
                    0 => Icon(Icons.two_mp),
                    1 => Icon(Icons.ten_mp),
                    2 => Icon(Icons.twenty_mp),
                    3 => Icon(Icons.five_k),
                    _ => Icon(Icons.wash),
                  },
                ),
                IconButton(
                    onPressed: _isConnected ? _disconnect : null,
                    icon: Icon(Icons.usb_off)),
                IconButton(
                    onPressed: _isConnected ? null : () => _refresh(context),
                    icon: Icon(Icons.find_replace)),
                IconButton(
                    onPressed: _orientation,
                    icon: Icon(_ort_portrait
                        ? Icons.screen_rotation
                        : Icons.stay_primary_landscape)),
              ],
            ),
            body: Column(
              children: [
                const SizedBox(height: 16),
                /*SizedBox(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ValueListenableBuilder<List<double>>(
                      valueListenable: _dataStreamNotifier,
                      builder: (context, value, _) {
                        return Oscilloscope(
                          showYAxis: true,
                          yAxisMax: _maxY,
                          yAxisMin: _minY,
                          traceColor: Colors.blue,
                          dataSet: value,
                        );
                      },
                    ),
                  ),
                ),*/
                SizedBox(
                  height: height,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // 🟨 Y軸標籤
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (i) {
                            double value = _maxY - i * ((_maxY - _minY) / 4);
                            return Text(value.toStringAsFixed(4),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey));
                          }),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Stack(
                            children: [
                              // 🟦 Oscilloscope 波形圖
                              ValueListenableBuilder<List<double>>(
                                valueListenable: _dataStreamNotifier,
                                builder: (context, value, _) {
                                  return Oscilloscope(
                                    showYAxis: true,
                                    yAxisMax: _maxY,
                                    yAxisMin: _minY,
                                    traceColor: Colors.blue,
                                    dataSet: value,
                                  );
                                },
                              ),
                              // 🟥 XY軸標籤
                              Positioned(
                                top: 0,
                                right: 4,
                                child: Text("Y",
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 8,
                                child: Text("時間 →",
                                    style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: ValueListenableBuilder<List<double>>(
                            valueListenable: _dataStreamNotifier,
                            builder: (context, value, _) {
                              final recent = value.take(5); // 自訂函式或手動取
                              final text = recent
                                  .map((e) => e.toStringAsFixed(4))
                                  .join('\n');
                              final avg = value.isNotEmpty
                                  ? (value.reduce((a, b) => a + b) /
                                      value.length)
                                  : 0.0;
                              final latest =
                                  value.isNotEmpty ? value.last : 0.0;

                              return Text(
                                "最近值:\n$text\n\n"
                                "最新值: ${latest.toStringAsFixed(4)}\n"
                                "平均值: ${avg.toStringAsFixed(4)}\n"
                                "max: ${value.isNotEmpty ? value.reduce(max).toStringAsFixed(4) : 0.0}\n"
                                "min: ${value.isNotEmpty ? value.reduce(min).toStringAsFixed(4) : 0.0}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black87),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                /*Slider(
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
                ),*/
                Row(
                  children: <Widget>[
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
                    Slider(
                      value: _offsetY,
                      min: -5.0,
                      max: 5.0,
                      divisions: 100,
                      label: "Y 偏移 ${_offsetY.toStringAsFixed(2)}",
                      onChanged: (value) {
                        setState(() {
                          _offsetY = value;
                          _applyScale(); // ✅ 重新套用 Y 軸範圍
                        });
                      },
                    ),
                    Slider(
                      value: _ratio,
                      min: 0.1,
                      max: 0.9,
                      divisions: 100,
                      label: "比例 ${_ratio.toStringAsFixed(2)}",
                      onChanged: (value) {
                        setState(() {
                          _ratio = value;
                          _applyScale(); // ✅ 重新套用 Y 軸範圍
                        });
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _minY = -1.5;
                          _maxY = 1.5;
                          _offsetY = 0.0;
                          _scaleX = 1.0;
                          _scaleY = 1.0;
                          _applyScale();
                        });
                      },
                      icon: Icon(Icons.vertical_align_center),
                    ),
                    IconButton(
                      icon: Icon(_isHold ? Icons.play_arrow : Icons.pause),
                      onPressed: () => setState(() => _isHold = !_isHold),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _secondsController,
                        decoration: InputDecoration(labelText: "記錄秒數"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isRecording ? null : _startRecording,
                      child: const Text("記錄"),
                    ),
                    IconButton(
                      icon: Icon(Icons.monitor),
                      onPressed: _isHold && !_isRecording ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewPage(data: _datastream)),
                      ) : null,
                    ),
                  ],
                ),
              ],
            ) //;

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
            //}),
            ); //);
  }
}
