import 'package:fdls/constants.dart';
import 'package:fdls/widgets/render_rect_listener.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleGraph<T> extends StatefulWidget {
  final double minY;
  final double maxY;
  final List<LineChartBarData> data;

  const SimpleGraph({
    required this.maxY,
    required this.data,
    this.minY = 0,
    super.key,
  });

  @override
  State<SimpleGraph<T>> createState() => _SimpleGraphState<T>();
}

class _SimpleGraphState<T> extends State<SimpleGraph<T>> {
  double width = 100;

  @override
  Widget build(BuildContext context) {
    return RenderRectListener(
      listener: (rect) {
        if (rect.width == width) return;
        setState(() => width = rect.width);
      },
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(enabled: false),
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          clipData: const FlClipData.all(),
          borderData: FlBorderData(show: false),
          minY: widget.minY,
          maxY: widget.maxY,
          minX: DateTime.now()
                  .subtract(fdlsGraphPer100Px * (width / 100))
                  .millisecondsSinceEpoch /
              1000,
          maxX: DateTime.now().millisecondsSinceEpoch / 1000,
          lineBarsData: widget.data,
        ),
        duration: Duration.zero,
      ),
    );
  }
}
