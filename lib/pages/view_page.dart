import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:usb_oscilloscope/widgets/LineChart.dart';
import 'package:usb_oscilloscope/pages/home_page.dart';
import 'dart:math';

class ViewPage extends StatefulWidget {
  final List<double> data;

  const ViewPage({super.key, required this.data});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  double _minY = -5.0;
  double _maxY = 5.0;
  double _minX = 0;
  double _maxX = 1000;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  double _scaleX = 1.0;
  double _scaleY = 1.0;
  double _ratio = 0.4;



  List<FlSpot> _toFlSpot(List<double> data) {
    return List.generate(data.length, (i) {
      return FlSpot(i.toDouble(), data[i]);});
  }

  void _applyScale() {
    //final xCenter = (_minX + _maxX) / 2;
    //final yCenter = (_minY + _maxY) / 2;

    //final xRange = 10 / _scaleX;
    final len = widget.data.length.toDouble();
    final yRange = 10 / _scaleY;
    final xRange = len / _scaleX;

    setState(() {
      _minX = -_offsetX + len/2 - xRange / 2;
      _maxX = -_offsetX + len/2 + xRange / 2;
      _minY = _offsetY - yRange / 2;
      _maxY = _offsetY + yRange / 2;
    });
  } //gpt ass

  @override
  void initState() {
    super.initState();
    _maxX = widget.data.length.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final avg = widget.data.isNotEmpty
        ? (widget.data.reduce((a, b) => a + b) /
        widget.data.length)
        : 0.0;
    final latest =
    widget.data.isNotEmpty ? widget.data.last : 0.0;
    return Scaffold(
        appBar: AppBar(
          title: const Text("View"),
          actions: [],
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
              height: MediaQuery.of(context).size.height * _ratio,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Expanded(
                      child: Stack(
                        children: [
                          // 🟦 Oscilloscope 波形圖
                          Chart(
                            data: _toFlSpot(widget.data),
                            minY: _minY,
                            maxY: _maxY,
                            minX: _minX,
                            maxX: _maxX,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: Text(
                        "最新值: ${latest.toStringAsFixed(4)}\n"
                            "平均值: ${avg.toStringAsFixed(4)}\n"
                            "max: ${widget.data.isNotEmpty ? widget.data.reduce(max).toStringAsFixed(4) : 0.0}\n"
                            "min: ${widget.data.isNotEmpty ? widget.data.reduce(min).toStringAsFixed(4) : 0.0}",
                        style:
                        TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

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
                  value: _scaleX,
                  min: 0.1,
                  max: 5.0,
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
                  value: _offsetX,
                  min: -1000.0,
                  max: 1000.0,
                  divisions: 100,
                  label: "X 偏移 ${_offsetX.toStringAsFixed(2)}",
                  onChanged: (value) {
                    setState(() {
                      _offsetX = value;
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
                      _minY = -5.0;
                      _maxY = 5.0;
                      _minX = 0;
                      _maxX = widget.data.length.toDouble();
                      _offsetY = 0.0;
                      _offsetX = 0.0;
                      _scaleX = 1.0;
                      _scaleY = 1.0;
                      _applyScale();
                    });
                  },
                  icon: Icon(Icons.vertical_align_center),
                ),
              ],
            ),
          ],
        ));
  }
}
