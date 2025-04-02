import 'dart:convert';
import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/UserProvider.dart';
import 'package:GOSY/Widget/CartAppBar.dart';
import 'package:GOSY/Page/CheckOut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class Cartpage extends StatefulWidget {
  List<dynamic> products = [];
  Cartpage({super.key, required this.products} );
 @override
  _CartpageState createState() => _CartpageState();
}
class _CartpageState extends State<Cartpage> {
  
  List<dynamic> carts = [];
  bool isLoading = false;
  List<dynamic> selectedCarts = []; 
  dynamic user ;
  double total = 0;
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
    
    setState(() {
      isLoading = true;
    });
    try {
      await Future.wait([
        fetchCarts(),
      ]);
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
}
   Future<void> fetchCarts() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Carts/User/${user['id']}'));
      if (response.statusCode == 200) {
        setState(() {
          carts = jsonDecode(response.body);
        });
        print('product at home ${response.body}');
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    } 
  }
 
  void updateSelectedCart(dynamic cart) {
      setState(() {
       final existingCart = selectedCarts.firstWhere(
          (item) => item['id'] == cart['id'],
          orElse: () => null,
        );
        if (existingCart != null) {
          selectedCarts.remove(existingCart);
        } else {
          selectedCarts.add(cart);
        }

        total = selectedCarts.fold(  0, (sum, item) => sum + (item['price'] * item['quantity'] ?? 0),  ); 
      });
    print('Selected cart: $selectedCarts');
  }
 
  Future<void> updateQuantity(String action, dynamic cart,int quantity) async {
    var uri = Uri.parse('${ApiConfig.baseUrl}/api/Carts/${cart['id']}');
      final body = Map<String, dynamic>.from(cart);
      if(action == 'add') {
         body['quantity'] ++;
      }else if(action == "minus" && quantity > 1){
        body['quantity'] --;
      }
    try {
      final response = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 204) {
        setState(() {
        // Tìm và cập nhật cart trong danh sách carts
          final cartIndex = carts.indexWhere((item) => item['id'] == cart['id']);
          final cartSelectdIndex = selectedCarts.indexWhere((item) => item['id'] == cart['id']);
          if (cartIndex != -1) {
            carts[cartIndex]['quantity'] = body['quantity'];
          }
          if (cartSelectdIndex != -1) {
            selectedCarts[cartSelectdIndex]['quantity'] = body['quantity'];
            total = selectedCarts.fold( 0, (sum, item) => sum + (item['price']*item['quantity'] ?? 0), );
          }
        });
      } else {
        
        print('Failed to update cart: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteCart( dynamic cart) async {
    var uri = Uri.parse('${ApiConfig.baseUrl}/api/Carts/${cart['id']}');
    try {
      final response = await http.delete(
        uri,
      );
      if (response.statusCode == 204) {
        fetchCarts();
      } else {
        print('Failed to update cart: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Column(
        children: [
          CartAppbar(),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(top:15),
              decoration:BoxDecoration (
                color: Color(0xFFEDECF2),
                borderRadius: BorderRadius.only(topLeft:Radius.circular(30) , topRight: Radius.circular(30) ),
              ),
              child: BuildCartItem(),  
            ),
          )
        ],
      ),
      bottomNavigationBar: buildCartBottom(),
    );
    }


 Widget BuildCartItem() {
    return isLoading
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
                itemCount: carts.length,
                itemBuilder: (context, index) {
                final cart = carts[index];
                final product = widget.products.firstWhere((product)=>product?['id'] == cart?['productId'] ,orElse: () => null,);
                
                final finalPrice = product['promo'] > 0 ? (product['price'] -  product['promo']*0.01 * product['price'])  : product['price']  ;
                dynamic selected = Map<String, dynamic>.from(cart);
                selected['price'] = finalPrice;
                
                final isSelected = selectedCarts.any((item) => item['id'] == selected['id']);

               
                return 
                Container(
                  margin:EdgeInsets.symmetric(horizontal: 12, vertical: 5) ,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(children: [
                    //selected cart
                    Transform.translate(
                      offset: Offset(-8, 0), 
                      child: Column(
                        children: [
                          InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Xác nhận'),
                                            content: Text('Bạn có chắc chắn muốn xóa đơn hàng?'),
                                            backgroundColor: Colors.white,
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(); 
                                                },
                                                child: Text('Hủy'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  deleteCart(cart);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Xóa',style: TextStyle(color: Colors.red),),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }, child: Icon(Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                            
                          IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                color: isSelected ?Color.fromARGB(255, 224, 141, 58) : Colors.grey,
                              ),
                              onPressed: () {
                                updateSelectedCart(selected);
                              }
                          ),
                        ],
                      ),
                    ),
                    //image
                    Transform.translate(
                      offset: Offset(-15, 0), 
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: product == null ?Icon(Icons.image_not_supported, size: 50, color: Colors.grey)
                              : product['image'] != null && product['image'].isNotEmpty
                              ? Image.memory(base64Decode(product['image']), height: 50)
                              : Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                              
                      ),
                    ),
                    //infor cart
                    Container(
                      width: 130,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(product['name'],
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,  
                            style:TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 225, 122, 37),
                              )
                            ), 
                            SizedBox(height: 4,), 
                            Text(
                              'Giá: ${ NumberFormat('###,###').format(finalPrice)} đ',
                              style:TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 66, 66, 66),
                                )
                              ),
                           
                            ],
                      ),   
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        
                         Container(
                                  width: 120,
                                  height: 40,
                                  child: Row( 
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end, 
                                    children: [
                                      InkWell(
                                        onTap: (){updateQuantity("minus", cart, cart['quantity']);},
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blueGrey,
                                                spreadRadius: 1,
                                                blurRadius: 10,
                                              )
                                            ]
                                          ),
                                          child:Icon(CupertinoIcons.minus, 
                                          size: 18,
                                          ) ,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child:Text (
                                          cart['quantity'].toString(), 
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 232, 126, 27),
                                          ) ,
                                        ) ,
                                      ),
                                      InkWell(
                                        onTap: (){updateQuantity("add", cart, cart['quantity']);},
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blueGrey,
                                                spreadRadius: 1,
                                                blurRadius: 10,
                                              )
                                            ]
                                          ),
                                          child:Icon(CupertinoIcons.plus, 
                                          size: 18,
                                          ) ,
                                        ),
                                      ),
                                    ],
                                  ),
                                ), 
                        
                      ],
                    )
                    ],
                  ),
                );
             }
          );  
  }
 
 Widget buildCartBottom() {
    return Container(
              height: 70,
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all( Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200,
                    child: 
                        Text(
                          'Tổng: ${NumberFormat('###,###').format(total)} đ',
                          style: TextStyle(
                            color: Color.fromARGB(255, 59, 59, 59),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                     
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      if(selectedCarts.length > 0 )
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(products: widget.products, selectedCarts: selectedCarts,total: total,), 
                        ),
                      );
                      else{
                        print('Vui long chon san pham de tiep tuc');
                        return;
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 209, 130, 52),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "Thanh toán",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          );
  } 

}   



  