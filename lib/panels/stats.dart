import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Stats extends StatelessWidget {
  const Stats({super.key});

  @override
  Widget build(BuildContext context) {
    const double consumedCalories = 1850;
    const double targetCalories = 2200;
    const double protein = 120;
    const double carbs = 210;
    const double fat = 65;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Statystyki Diety', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalorieCard(consumedCalories, targetCalories),
            const SizedBox(height: 24),

            const Text('Rozkład Makroskładników', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildMacroPieChart(protein, carbs, fat),
            const SizedBox(height: 24),

            const Text('Spożycie Kalorii z 7 dni', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildWeeklyBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard(double consumed, double target) {
    double progress = consumed / target;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dzisiejsze Spożycie', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${consumed.toInt()} / ${target.toInt()} kcal', 
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress > 1.0 ? 1.0 : progress,
                    backgroundColor: Colors.grey[200],
                    color: progress > 1.0 ? Colors.red : Colors.blueAccent,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroPieChart(double p, double c, double f) {
    double total = p + c + f;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            SizedBox(
              height: 140,
              width: 140,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(color: Colors.redAccent, value: p, title: '${(p/total*100).toStringAsFixed(0)}%', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    PieChartSectionData(color: Colors.amber, value: c, title: '${(c/total*100).toStringAsFixed(0)}%', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    PieChartSectionData(color: Colors.green, value: f, title: '${(f/total*100).toStringAsFixed(0)}%', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMacroIndicator(Colors.redAccent, 'Białko', '${p.toInt()}g'),
                  const SizedBox(height: 8),
                  _buildMacroIndicator(Colors.amber, 'Węglowodany', '${c.toInt()}g'),
                  const SizedBox(height: 8),
                  _buildMacroIndicator(Colors.green, 'Tłuszcze', '${f.toInt()}g'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroIndicator(Color color, String label, String amount) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(amount, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWeeklyBarChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12, left: 12, right: 12),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 2500,
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 1900, color: Colors.blue, width: 14)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 2150, color: Colors.blue, width: 14)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1800, color: Colors.blue, width: 14)]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 2300, color: Colors.red, width: 14)]),
                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 1650, color: Colors.blue, width: 14)]),
                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 2000, color: Colors.blue, width: 14)]),
                BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 1850, color: Colors.blueAccent, width: 14)]),
              ],
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'Sb', 'Nd'];
  
                      if (value < 0 || value >= days.length) return const SizedBox.shrink();

                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          days[value.toInt()], 
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }
}
