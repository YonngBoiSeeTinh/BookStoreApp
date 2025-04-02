import 'dart:convert';
import 'dart:io';
//import 'package:fl_chart/fl_chart.dart' show BarChart, BarChartData, BarChartGroupData, BarChartRodData, BarTouchData, FlTapUpEvent;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../AppConfig.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic>? orders;
  List<dynamic>? users;
  bool isLoading = false;

  double _dailyRevenue = 0;
  int _monthlyUser = 0;
  double _monthlyRevenue = 0;
  int _monthlyOrders = 0;
  Map<String, double> _lastSixMonthsRevenue = {};

 @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchOrder();
    showingTooltip = -1;
  }
Future<void> fetchUsers() async {
  try {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Users'));
    if (response.statusCode == 200) {
      final List<dynamic> userList = jsonDecode(response.body);
      final now = DateTime.now();
      int monthlyNewUsers = 0;

      for (var user in userList) {
        final createdDate = DateTime.parse(user['createdAt']);

        if (createdDate.year == now.year && createdDate.month == now.month) {
          monthlyNewUsers++;
        }
      }

      setState(() {
        users = userList;
        _monthlyUser = monthlyNewUsers; 
      });
      print('dashboard _monthlyUser ${monthlyNewUsers}');
    } else {
      print('Failed to load users: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching users: $e');
  }
}
 Future<void> fetchOrder() async {
  setState(() {
    isLoading = true;
  });

  try {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Orders'));
    if (response.statusCode == 200) {
      final List<dynamic> orderList = jsonDecode(response.body);
      final now = DateTime.now();

      // Tính doanh thu theo ngày
      double dailyRevenue = 0;
      // Tính doanh thu và số lượng theo tháng
      double monthlyRevenue = 0;
      int monthlyOrders = 0;
      //Doanh thu trong 6 thang
      Map<String, double> lastSixMonthsRevenue = {};

      for (int i = 0; i < 6; i++) {
        final month = DateTime(now.year, now.month - i, 1);
        lastSixMonthsRevenue[month.toString()] = 0.0;
      }
      for (var order in orderList) {
        final orderDate = DateTime.parse(order['createdAt']);
        String status = order['status'];

         if (status == "Đã giao hàng" &&
            orderDate.year == now.year &&
            orderDate.month == now.month &&
            orderDate.day == now.day) {
            dailyRevenue += order['totalPrice'] ?? 0;
        }
        // Theo tháng
        if (status == 'Đã giao hàng' &&
            orderDate.year == now.year &&
            orderDate.month == now.month) {
            monthlyRevenue += order?['totalPrice'] ?? 0;
        }
       
        if (orderDate.year == now.year &&
            orderDate.month == now.month) {
            monthlyRevenue += order?['totalPrice'] ?? 0;
            monthlyOrders++;
        }
        //6 thang gan day
         if (status == 'Đã giao hàng') {
          for (var month in lastSixMonthsRevenue.keys) {
              final monthDate = DateTime.parse(month);
              if (orderDate.year == monthDate.year &&
                  orderDate.month == monthDate.month) {
                lastSixMonthsRevenue[month] =
                    (lastSixMonthsRevenue[month] ?? 0) +
                        (order['totalPrice'] ?? 0);
              }
          }
        }
      }
      setState(() {
            orders = orderList;
            // Cập nhật các giá trị để hiển thị
            _dailyRevenue = dailyRevenue;
            _monthlyRevenue = monthlyRevenue;
            _monthlyOrders = monthlyOrders;
            _lastSixMonthsRevenue = lastSixMonthsRevenue;
          });
          print('dashboard _dailyRevenue ${dailyRevenue}');
          print('dashboard _monthlyOrders ${monthlyOrders}');
        } else {
          print('Failed to load orders: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching orders: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
}

String formatCurrency(double amount) {
  final pattern = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
  return amount.toStringAsFixed(0).replaceAllMapped(pattern, (match) => '${match[1]}.') + ' ₫';
}

@override
Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 16,
              children: [
                _buildRevenueChartContainer(
                    title: "Doanh thu ngày",
                    value:  '${formatCurrency(_dailyRevenue)} ',
                    icon: Icons.money_off),
                _buildChartContainer(
                    title: "Đơn hàng",
                    value: _monthlyOrders.toString(),
                    icon: Icons.shopping_cart),
                _buildRevenueChartContainer(
                    title: "Doanh thu tháng",
                    value: '${formatCurrency(_monthlyRevenue)} ',
                    icon: Icons.money),
                _buildChartContainer(
                    title: "Khách hàng ",
                    value: _monthlyUser.toString(),
                    icon: Icons.account_box),
              ],
            ),
            //_buildLastSixMonthsChart(),
          ],
        ),
      ),
    );
  }
Widget _buildChartContainer(
      {required String title, required String value, required IconData icon}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      height: 150,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C53A5),
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 112, 209, 143),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Xem chi tiết",
                  style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 137, 176, 207))),
              Icon(
                icon,
                size: 30,
                color: Color.fromARGB(255, 86, 83, 83),
              ),
            ],
          )
        ],
      ),
    );
  }

Widget _buildRevenueChartContainer(
      {required String title, required String value, required IconData icon}) {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width * 0.45,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C53A5),
            ),
          ),
          SizedBox(height: 16),
          Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 112, 209, 143),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Xem chi tiết",
                  style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 137, 176, 207))),
              Icon(
                icon,
                size: 30,
                color: Color.fromARGB(255, 86, 83, 83),
              ),
            ],
          )
        ],
      ),
    );
  }
late int showingTooltip;


// Widget _buildLastSixMonthsChart() {
//   final List<String> months = _lastSixMonthsRevenue.keys.toList();
//   final List<double> revenues = _lastSixMonthsRevenue.values.toList();
//   BarChartGroupData generateGroupData(int x, int y) {
//     return BarChartGroupData(
//       x: x,
//       showingTooltipIndicators: showingTooltip == x ? [0] : [],
//       barRods: [
//         BarChartRodData(toY: y.toDouble()),
//       ],
//     );
//   }
//   return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: AspectRatio(
//             aspectRatio: 2,
//             child: BarChart(
//               BarChartData(
//                 barGroups: [
//                   for(int i = 0; i<6; i++)
//                     generateGroupData(months[i] as int, revenues[i] as int),
//                 ],
//                 barTouchData: BarTouchData(
//                   enabled: true,
//                   handleBuiltInTouches: false,
//                   touchCallback: (event, response) {
//                     if (response != null && response.spot != null && event is FlTapUpEvent) {
//                       setState(() {
//                         final x = response.spot!.touchedBarGroup.x;
//                         final isShowing = showingTooltip == x;
//                         if (isShowing) {
//                           showingTooltip = -1;
//                         } else {
//                           showingTooltip = x;
//                         }
//                       });
//                     }
//                   },
//                   mouseCursorResolver: (event, response) {
//                     return response == null || response.spot == null
//                         ? MouseCursor.defer
//                         : SystemMouseCursors.click;
//                   }
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
  
  
// }


}
