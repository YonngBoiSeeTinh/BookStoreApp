import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetail extends StatefulWidget {
  final List<dynamic> orders; 
  final List<dynamic> orderDetails; 
  final List<dynamic> products;
  final int orderId;
  const OrderDetail({super.key, 
   
    required this.orderDetails,
    required this.orders,
    required this.products,
    required this.orderId,
  }) ;

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  
  List<dynamic> getOrderDetailsByOrderId(int orderId) {
    return widget.orderDetails.where((detail) => detail['orderId'] == orderId).toList();
  }

  String getProduct(dynamic productId) {
    final product = widget.products.firstWhere(
      (product) => product['id'].toString() == productId.toString(),
      orElse: () => null,
    );
    return product?['name'] ?? 'Không rõ sản phẩm';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orders.firstWhere((o) => o['id'] == widget.orderId, orElse: () => null);
    final selectedOrderDetails = getOrderDetailsByOrderId(widget.orderId);

    if (order == null) {
      return Center(
        child: Text(
          "Order not found",
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }
    String formatDate(String? createdAt) {
      if (createdAt == null || createdAt.isEmpty) {
        return 'N/A';
      }
      try {
        DateTime parsedDate = DateTime.parse(createdAt);
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (e) {
        print('Error parsing date: $e');
        return 'N/A';
      }
    }

        return 
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tên khách hàng: ${order['name'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Ngày đặt: ${formatDate(order['createdAt'])} ",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Địa chỉ: ${order['address'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Số điện thoại: ${order['phone'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Danh sách sản phẩm:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                  SizedBox(height: 8),
                  Column(
                    children: selectedOrderDetails.map((od) {
                      String productName = getProduct(od['productId']);
                      String formattedPrice = "${od['price']}".replaceAllMapped(
                        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                        (match) => "${match[1]},",
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                productName,
                                style: TextStyle(fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "${od['quantity']} x ",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "$formattedPrice đ",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Divider(color: Color.fromARGB(255, 75, 83, 174)),
                  Text(
                    "Tổng cộng: ${order['totalPrice'] ?? '0'} VND",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ],
              ),
            ),
          );
  }
}
