import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../AppConfig.dart';
import '../Widget/Alter.dart';
import '../Widget/OrderDetailWidget.dart';
import 'OrderEdit.dart';


class OrderManager extends StatefulWidget {
  const OrderManager({super.key});

  @override
  _OrderManagerState createState() => _OrderManagerState();
}

class _OrderManagerState extends State<OrderManager> {
 
    List<dynamic> orders = []; // Danh sách sản phẩm
    List<dynamic> orderDetails = []; 
    List<dynamic> products = []; 
    bool isLoading = false;
    @override
    void initState() {
      super.initState();
      fetchOrder();
      fetchOrderDetails(); 
      fetchProducts();
    }
  Future<void> deleteOrders(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/api/Orders/$id')); 
      if (response.statusCode == 204) {
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return Alter(message: 'Xóa thành công!');
        },
      ).then((_) {
        setState(() {
          orders.removeWhere((order) => order['id'] == id); 
        });
      });
      } else {
        print('Failed to delete products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }
  Future<void> fetchOrder() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Orders'));
      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
           orders.sort((a, b) {
            DateTime dateA = DateTime.parse(a['createdAt']);
            DateTime dateB = DateTime.parse(b['createdAt']);
            return dateB.compareTo(dateA); // Sắp xếp giảm dần (mới nhất ở đầu)
          });
        });
      } else {
        print('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
    finally {
      setState(() {
        isLoading = false; 
      });
    }
  }
   Future<void> fetchOrderDetails() async {
    setState(() {
      isLoading = true;
    });
      try {
        final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/OrderDetails'));
        if (response.statusCode == 200) {
          setState(() {
            orderDetails = jsonDecode(response.body);
          });
        } else {
          print('Failed to load categories: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching categories: $e');
      }finally {
      setState(() {
        isLoading = false; 
      });
    }
    }
   Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Products'));
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
        });
      } else {
        print('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
       setState(() {
      isLoading = false;
    });
  }
  

  void _showOrderDetails(Map<String, dynamic> order) {
    //List<dynamic> selectedOrderDetails = getOrderDetailsByOrderId(order['id']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, 
          title: Text("Chi tiết đơn hàng",
                  style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 120, 127, 199),
                  ),),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: OrderDetail(orderDetails: orderDetails, orders: orders, products: products,orderId:  order['id']),
            actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
    ? const Center(child: CircularProgressIndicator())
    :  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Quản lý đơn hàng",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C53A5),
          ),
        ),
      ),
      body:  orders.length <= 0 ?
      const Center(child: Text("Không có đơn hàng nào"))
      :ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text( order['name'] != null ?
                        order['name'] : "",
                        maxLines: 1, 
                                 overflow: TextOverflow.ellipsis, 
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C53A5)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tổng tiền: ${ NumberFormat('###,###').format( order['totalPrice'])} đ',
                        style: TextStyle(fontSize: 16, color: Color(0xFF4C53A5)),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: order['status'] == 'Chờ xác nhận'
                              ? const Color.fromARGB(255, 255, 154, 59)
                              : order['status'] == 'Đã hủy'
                                  ? Colors.red
                                  : Colors.green,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ' ${order['status']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 47, 47, 47)),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _showOrderDetails(order);
                          },
                          icon: Icon(Icons.remove_red_eye),
                          color: Color.fromARGB(255, 68, 128, 202),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(context, 
                             MaterialPageRoute(
                                    builder: (context) => OrderUpdateWidget(orderDetails: orderDetails, orders: orders, products: products,orderId:  order['id'])
                              ),);
                          },
                          icon: Icon(Icons.edit),
                          color: Colors.orange,
                        ),
                        IconButton(
                          onPressed: () {
                           deleteOrders(order['id']);
                          },
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
