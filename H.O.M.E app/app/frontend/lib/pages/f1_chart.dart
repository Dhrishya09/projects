import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EnergyConsumptionGraph extends StatelessWidget {
  const EnergyConsumptionGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1),
              FlSpot(1, 3),
              FlSpot(2, 2),
              FlSpot(3, 5),
            ],
            isCurved: true,
           color: const Color.fromARGB(255, 33, 150, 243),

            barWidth: 4,
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toString(), style: TextStyle(fontSize: 12));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toString(), style: TextStyle(fontSize: 12));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
