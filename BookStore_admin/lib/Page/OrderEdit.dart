import 'package:flutter/material.dart';


import 'dart:convert';
import 'package:http/http.dart' as http;

import '../AppConfig.dart';
import '../Widget/Alter.dart';
import 'HomePage.dart';
class OrderUpdateWidget extends StatefulWidget {
  final List<dynamic> orders; 
  final List<dynamic> orderDetails; 
  final List<dynamic> products;
  final int orderId;
  const OrderUpdateWidget({super.key, 
    required this.orderDetails,
    required this.orders,
    required this.products,
    required this.orderId,
  });
  
  @override
  _OrderUpdateWidgetState createState() => _OrderUpdateWidgetState();
}

class _OrderUpdateWidgetState extends State<OrderUpdateWidget> {

  List<dynamic> getOrderDetailsByOrderId(int orderId) {
    return widget.orderDetails.where((detail) => detail['orderId'] == orderId).toList();
  }
  Map<String, dynamic>? order;

  String getProduct(dynamic productId) {
    final product = widget.products.firstWhere(
      (product) => product['id'].toString() == productId.toString(),
      orElse: () => null,
    );
    return product?['name'] ?? 'Không rõ sản phẩm';
  }

  String? selectedStatus;
  final List<String> statuses = ["Chờ xác nhận", "Đã xác nhận", "Đã giao hàng","Đang giao", "Đã giao"];

  @override
  void initState() {
    super.initState();
    order = widget.orders.firstWhere((o) => o['id'] == widget.orderId, orElse: () => null);
    selectedStatus =  order?['status'] ;
  }
Future<void> updateOrder() async {
  var uri = Uri.parse('${ApiConfig.baseUrl}/api/Orders/${widget.orderId}');
  final body = jsonEncode({
    "createdAt": order?['createdAt'],
    "userId": order?['userId'],
    "totalPrice": order?['totalPrice'],
    "name": order?['name'],
    "paymentMethod": order?['paymentMethod'],
    "paymentStatus": order?['paymentStatus'],
    "cancellationReason": order?['cancellationReason'],
    "phone": order?['phone'],
    "address": order?['address'],
    "status": selectedStatus,
  });

  try {
    final response = await http.put(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: body,
    );

    if (response.statusCode == 204) {
      if (selectedStatus == "Đã giao hàng") {
       
        await updateUser(); 
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Cập nhật đơn hàng thành công!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      ).then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(index: 2),
          ),
        );
      });
    } else {
      showErrorDialog('Cập nhật đơn hàng thất bại!');
      print('Failed to update order: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> updateUser() async {
  try {
    
    final userResponse = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Users/${order?['userId']}'));
    if (userResponse.statusCode == 200) {
      final user = jsonDecode(userResponse.body);
      user['totalBuy'] += order?['totalPrice'] ?? 0;
      
      user.remove('updatedAt');
      user.remove('image');
      var uri = Uri.parse('${ApiConfig.baseUrl}/api/Users/${order?['userId']}');
      var request = http.MultipartRequest('PUT', uri);

    
      request.fields['id'] = user['id'].toString();
      request.fields['name'] = user['name'];
      request.fields['phone'] = user['phone'];
      request.fields['address'] = user['address'];
      if(user['totalBuy'] <= 1500000)
        {request.fields['role'] = "4";} // thuong
      else if(user['totalBuy'] > 1500000)
        {request.fields['role'] = "5";}  //bac
      else if(user['totalBuy'] > 3500000)
       { request.fields['role'] = "6";} //vang
      else if(user['totalBuy'] > 7000000)
       { request.fields['role'] = "7";} //kim cuong
      request.fields['totalBuy'] = user['totalBuy'].toString();
      request.fields['account'] = user['account'].toString();
      request.fields['createdAt'] = user['createdAt'];
      var response = await request.send();
      print('Request fields: ${request.fields}');
      if (response.statusCode != 204) {
        showErrorDialog('Cập nhật user thất bại!');
        print('Response user Failed to update user: ${response.statusCode}');
      }
    } else {
      showErrorDialog('Lấy thông tin user thất bại!');
      print('Response user Failed to fetch user: ${userResponse.statusCode}');
    }
  } catch (e) {
    print('Response user Error updating user: $e');
  }
}

void showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
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
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text("Cập nhật đơn hàng" ,style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFF4C53A5),
         iconTheme: IconThemeData(
          color: Colors.white,
         ),
      ),
      body: Container(
      
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
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
                children:
                 selectedOrderDetails.map((od) {
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
                        SizedBox(height: 16),
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
                "Total Price: ${order['totalPrice'] ?? '0'} đ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              SizedBox(height: 16),
              Text(
                "Cập nhật trạng thái:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                items: statuses.map((String status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                updateOrder();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                          Container(
                            height: 50,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Color(0xFF4C53A5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "Cập nhật",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
              ),
            ),
          ),
    );
  }
}
