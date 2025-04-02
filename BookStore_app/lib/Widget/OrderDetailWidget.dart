import 'dart:convert';

import 'package:GOSY/Page/ProductDetail.dart';
import 'package:flutter/material.dart';

class OrderDetail extends StatefulWidget {
  final List<dynamic> orders;
  final List<dynamic> orderDetails;
  final List<dynamic> products;
  final int orderId;

  const OrderDetail({
    super.key,
    required this.orderDetails,
    required this.orders,
    required this.products,
    required this.orderId,
  });

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  List<dynamic> getOrderDetailsByOrderId(int orderId) {
    return widget.orderDetails
        .where((detail) => detail['orderId'] == orderId)
        .toList();
  }

  Future<dynamic> getProduct(int productId) async {
    return widget.products.firstWhere(
      (product) => product['id'].toString() == productId.toString(),
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orders.firstWhere(
      (o) => o['id'] == widget.orderId,
      orElse: () => null,
    );
    final selectedOrderDetails = getOrderDetailsByOrderId(widget.orderId);

    if (order == null) {
      return Center(
        child: Text(
          "Order not found",
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Người nhận: ${order['name'] ?? 'N/A'}",
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
                return FutureBuilder<dynamic>(
                  future: getProduct(od['productId']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Text("Sản phẩm không tồn tại");
                    }

                    final product = snapshot.data;
                    String formattedPrice = "${od['price']}".replaceAllMapped(
                      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                      (match) => "${match[1]},",
                    );

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(
                              product: product,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromARGB(255, 111, 111, 111),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 55,
                                  child: product['image'] != null &&
                                          product['image'].isNotEmpty
                                      ? Image.memory(
                                          base64Decode(product['image']),
                                          height: 50,
                                        )
                                      : Icon(Icons.image_not_supported,
                                          size: 50, color: Colors.grey),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    product['name'] ?? 'Tên sản phẩm',
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    "Số lượng:  ${od['quantity']}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Spacer(),
                                  Text(
                                    "x    $formattedPrice đ",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            if (order['cancellationReason'] != null &&
                order['cancellationReason'].isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lý do hủy:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    Text(
                      "${order['cancellationReason']}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            Divider(color: Color.fromARGB(255, 75, 83, 174)),
            Text(
              "Tổng tiền: ${order['totalPrice'] ?? '0'} VND",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
