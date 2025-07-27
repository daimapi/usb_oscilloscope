/*import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graphic Chart Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Line Chart with graphic')),
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: const LineChartExample(),
          );
        })),
      ),
    );
  }
}

class LineChartExample extends StatelessWidget {
  const LineChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'t': '2015', 'v': 5},
      {'t': '2016', 'v': 8},
      {'t': '2017', 'v': 6},
      {'t': '2018', 'v': 10},
      {'t': '2019', 'v': 12},
      {'t': '2020', 'v': 9},
    ];

    return Chart(
      data: data,
      variables: {
        't': Variable(
          accessor: (row) => (row as Map<String, dynamic>)['year'] as String,
        ),
        'v': Variable(
          accessor: (row) => (row as Map<String, dynamic>)['value'] as num,
        ),
      },
      marks: [
        LineMark(
          shape: ShapeEncode(value: BasicLineShape()),
          color: ColorEncode(value: Colors.blue),
        ),
        PointMark(),
      ],
      axes: [
        AxisGuide(
          variable: 't',
          line: PaintStyle(strokeColor: Colors.black, strokeWidth: 2.0),
          tickLine: Defaults.horizontalAxis.tickLine,
          label: LabelStyle(

          ),//Defaults.horizontalAxis.label,
          grid: PaintStyle(
            strokeColor: Colors.black.withValues(alpha: 1),
            strokeWidth: 1.5,
          ),
        ),
        AxisGuide(
          variable: 'v',
          line: PaintStyle(strokeColor: Colors.black, strokeWidth: 2.0),
          tickLine: Defaults.verticalAxis.tickLine,
          label: Defaults.verticalAxis.label,
          grid: PaintStyle(
            strokeColor: Colors.black.withValues(alpha: 1),
            strokeWidth: 1.5,
          ),
        ),
      ],
    );
  }
}*/

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
