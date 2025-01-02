import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';

class Salesreport extends StatefulWidget {
  const Salesreport({super.key});

  @override
  State<Salesreport> createState() => _SalesreportState();
}

class _SalesreportState extends State<Salesreport> {
  int totalSales = 0;
  int monthlySales = 0;
  List<double> salesData = [];
  double totalRevenue = 0;
  double averageOrderValue = 0;
  int totalCustomers = 0;
  double highestOrderValue = 0;
  double lowestOrderValue = double.infinity;
  List<double> revenuePerCustomer = [];

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    try {
      String farmerUserId = FirebaseAuth.instance.currentUser!.uid;

      DateTime now = DateTime.now();
      DateTime oneMonthAgo = now.subtract(Duration(days: 30));

      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('Orders')
          .where('userId', isEqualTo: farmerUserId)
          .get();

      totalSales = orderSnapshot.docs.length;
      salesData = List<double>.filled(30, 0.0);
      revenuePerCustomer = List<double>.filled(30, 0.0);
      double revenueInMonth = 0;
      Set<String> customers = {};

      for (var orderDoc in orderSnapshot.docs) {
        Map<String, dynamic>? orderData =
        orderDoc.data() as Map<String, dynamic>?;

        Timestamp orderTime = orderData!['orderTime'];
        DateTime orderDateTime = orderTime.toDate();
        double orderTotal = orderData['totalCost'] ?? 0.0;

        String customerId = orderData['customerId'] ?? '';
        customers.add(customerId);

        if (orderTotal > highestOrderValue) highestOrderValue = orderTotal;
        if (orderTotal < lowestOrderValue) lowestOrderValue = orderTotal;

        if (orderDateTime.isAfter(oneMonthAgo) && orderDateTime.isBefore(now)) {
          monthlySales++;
          revenueInMonth += orderTotal;

          int dayIndex = now.difference(orderDateTime).inDays;
          if (dayIndex < 30) {
            salesData[dayIndex] += orderTotal;
            revenuePerCustomer[dayIndex] += 1;
          }
        }

        totalRevenue += orderTotal;
      }

      averageOrderValue = totalSales > 0 ? totalRevenue / totalSales : 0.0;

      totalCustomers = customers.length;

      setState(() {});
    } catch (e) {
      print("Error fetching sales data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Text(
          translate('Sales Report'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: totalSales == 0
          ? Center(child: SpinKitWaveSpinner(color: Colors.green))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              _buildGraphTitle(translate("Sales Data (Last 30 Days)")),
              _buildLineChart(salesData, 'Sales Amount'),
              const SizedBox(height: 20),
              // _buildGraphTitle("Revenue per Customer (Last 30 Days)"),
              // _buildBarChart(revenuePerCustomer),
              const SizedBox(height: 20),
              _buildGraphTitle(translate("Customer Distribution")),
              _buildPieChart(totalCustomers),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('${translate('Total Sales')}:', totalSales.toString()),
            _buildSummaryRow('${translate('Sales in the Past Month')}:', monthlySales.toString()),
            _buildSummaryRow('${translate('Total Revenue')}:', '₹ ${totalRevenue.toStringAsFixed(2)}'),
            _buildSummaryRow('${translate('Average Order Value')}:', '₹ ${averageOrderValue.toStringAsFixed(2)}'),
            _buildSummaryRow('${translate('Total Customers')}:', totalCustomers.toString()),
            _buildSummaryRow('${translate('Highest Order Value')}:', '₹ ${highestOrderValue.toStringAsFixed(2)}'),
            _buildSummaryRow('${translate('Lowest Order Value')}:', '₹ ${lowestOrderValue.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildLineChart(List<double> data, String label) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  DateTime date =
                  DateTime.now().subtract(Duration(days: value.toInt()));
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      DateFormat('MMM d').format(date),
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
          ),
          minX: 0,
          maxX: data.length.toDouble() - 1,
          minY: 0,
          maxY: data.reduce((a, b) => a > b ? a : b) + 50,
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                  .toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [Colors.green.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(int totalCustomers) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: totalCustomers.toDouble(),
              title: translate('Customer'),
              radius: 60,
              titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              color: Colors.red,
              value: (30 - totalCustomers).toDouble(),
              title: translate('Potential'),
              radius: 60,
              titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
          centerSpaceRadius: 40,
          sectionsSpace: 4,
        ),
      ),
    );
  }
}
