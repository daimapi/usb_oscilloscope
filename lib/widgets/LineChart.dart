import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: false,
            barWidth: 2,
            color: Colors.blue,
            dotData: FlDotData(show: false),
          ),
        ],
        // 可互動縮放/平移
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItems: (spots) {
                return spots.map<LineTooltipItem?>((spot) {
                  return LineTooltipItem(
                    'x: ${spot.x.toStringAsFixed(2)}\ny: ${spot.y.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white),
                  );
                }).toList(); // ✅ 正常情況下這樣就行
              }),
          handleBuiltInTouches: true,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            // 可在此加入自訂邏輯
          },
        ),
        // 手勢互動：平移和縮放
        showingTooltipIndicators: [],
        // 設定縮放和平移
        extraLinesData: ExtraLinesData(),
        // X/Y 軸平移縮放設定
        // 使用 `LineTouchData` 加上 `clipData` 可以避免圖表超出邊界
        clipData: FlClipData.all(),
        // 畫面拖曳與縮放
        // 注意：需要將畫面包在 InteractiveViewer 外層才會啟用 pinch zoom
      ),
    );
  }
}
