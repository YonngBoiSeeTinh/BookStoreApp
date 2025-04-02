import 'dart:convert';

import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ItemBottomNavBar extends StatefulWidget {
   Map<String, dynamic>? product;
   int? quantity;
   ItemBottomNavBar({super.key, required this.product, required this.quantity});
  
  @override
  _ItemBottomNavBarState createState() => _ItemBottomNavBarState();
}
  
class _ItemBottomNavBarState extends State<ItemBottomNavBar> {
  dynamic user ;
  List<dynamic> carts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadSavedLogin(); 
    setState(() {
      user = userProvider.user; 
    });
    fetchCarts(); 
  }

  Future<void> fetchCarts() async {
    setState(() {
      isLoading = true; 
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Carts/User/${user['id']}'));
      if (response.statusCode == 200) {
        setState(() {
          carts = jsonDecode(response.body);
        });
      } else {
        print('Failed to load carts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching carts: $e');
    } finally {
      setState(() {
        isLoading = false; // Kết thúc tải dữ liệu
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {

    Future<dynamic> checkCart() async  {
      final check = carts.firstWhere(
        (cart) => cart['productId'] == widget.product?['id'] ,
        orElse: () => null, // Trả về `null` nếu không tìm thấy
      );
      return Future.value(check);
    }



    Future<void> addProduct() async {

     
      if(user==null){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Vui lòng đăng nhập!')),
          );
        return;
      }
    
      dynamic check = await checkCart();
    
      var uri = Uri.parse('${ApiConfig.baseUrl}/api/Carts');
      // Tạo body với dữ liệu cần gửi
      var body = {
        'productId': widget.product?['id'].toString(),
        'quantity': widget.quantity.toString(),
        'userId': user?['id'].toString(),
        'price': widget.product?['price'].toString(),
        'colorSizeId': '0',
      };
     
      if (check is Map<String, dynamic>){
        var uriUpdate = Uri.parse('${ApiConfig.baseUrl}/api/Carts/${check?['id']}');
        var bodyUpdate = Map<String, dynamic>.from(check);
        bodyUpdate['quantity'] += widget.quantity;    
        print('check cart ${bodyUpdate}');
        var response = await http.put(
          uriUpdate,
          headers: {'Content-Type': 'application/json'}, 
          body: bodyUpdate != null ? jsonEncode(bodyUpdate) : null, 
        );
        if (response.statusCode == 204) {
          print('cart update successfully');
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã thêm vào giỏ hàng'))
          );
          
        } else {
          print('Failed to update cart: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        
      }else{
        var response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'}, 
          body: body != null ? jsonEncode(body) : null, 
        );
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã thêm vào giỏ hàng'))
          );
          
          print('Product added successfully');
        } else {
          print('Failed to add product: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }    
    }

    return  Positioned(
            bottom: 0,
            left: 0,
            right: 0,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     
                        Row(
                          children: [
                            Text(
                            NumberFormat('###,###').format(widget.product?['price'] -  widget.product?['promo']*0.01 * widget.product?['price']),
                              style: TextStyle(
                                color: Color(0xFF4C53A5),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            widget.product?['promo'] > 0 ?
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4C53A5),
                                borderRadius: BorderRadius.circular(1000),
                              ),
                              child: Text(
                                "- ${widget.product?['promo']}%",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ):SizedBox(width: 20,)
                          ],
                        ),
                      
                        InkWell(
                          onTap: ()async{
                              await addProduct();
                          },
                          child: Container(
                            height: 50,
                            width: 170,
                            decoration: BoxDecoration(
                              color: Color(0xFF4C53A5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Thêm vào ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(Icons.add_shopping_cart, color: Colors.white,)
                                ],
                              ),
                          ),
                        ),
                    ],
                    
                  ),
                 
             
            ),
          );
    }
}
