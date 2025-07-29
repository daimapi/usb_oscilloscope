import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Chart extends StatefulWidget {
  final List<FlSpot> data;
  final double minX, maxX, minY, maxY;

  const Chart({
    super.key,
    required this.data,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  FlSpot? _touchedSpot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        LineChart(
          LineChartData(
            minX: widget.minX,
            maxX: widget.maxX,
            minY: widget.minY,
            maxY: widget.maxY,
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: widget.data,
                isCurved: false,
                barWidth: 2,
                color: Colors.blue,
                dotData: FlDotData(show: false),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                showOnTopOfTheChartBoxArea: false,
                //tooltipRoundedRadius: 0,
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 0,
                //tooltipBgColor: Colors.transparent,
                getTooltipItems: (spots) => List.filled(spots.length, null), // 不顯示內建 tooltip
              ),
              touchCallback: (event, response) {
                if (response == null ||
                    response.lineBarSpots == null ||
                    response.lineBarSpots!.isEmpty) {
                  setState(() => _touchedSpot = null);
                } else {
                  final spot = response.lineBarSpots!.first;
                  setState(
                      () => _touchedSpot = FlSpot(spot.x, spot.y));
                }
              },
            ), /*
          showingTooltipIndicators: [],
          clipData: FlClipData.none(),*/ // ❌ 取消裁剪也可選擇保留
          ),
        ),
        if (_touchedSpot != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'x: ${_touchedSpot!.x.toStringAsFixed(0)}, y: ${_touchedSpot!.y.toStringAsFixed(4)}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
