import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
/*
class LineChart extends StatefulWidget {
  const LineChart({super.key});

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
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
          accessor: (row) => (row as Map<String, dynamic>)['t'] as String,
        ),
        'v': Variable(
          accessor: (row) => (row as Map<String, dynamic>)['v'] as num,
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
          label: LabelStyle(),
          //Defaults.horizontalAxis.label,
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
}
*/
class LineChart extends StatelessWidget {
  const LineChart({super.key});

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
          accessor: (row) => (row as Map<String, dynamic>)['t'] as String,
        ),
        'v': Variable(
          accessor: (row) => (row as Map<String, dynamic>)['v'] as num,
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
          label: LabelStyle(),
          //Defaults.horizontalAxis.label,
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
}
