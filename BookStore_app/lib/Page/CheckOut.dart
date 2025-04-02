import 'dart:convert';
import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/Page/AccountPage.dart';
import 'package:GOSY/Page/EditProfile.dart';
import 'package:GOSY/UserProvider.dart';
import 'package:GOSY/Widget/CartAppBar.dart';
import 'package:GOSY/Widget/CheckOutAppBar.dart';
import 'package:GOSY/Widget/ChoosePromoWidget.dart';
import 'package:GOSY/Widget/ItemWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class CheckoutPage extends StatefulWidget {
  List<dynamic> selectedCarts = [];
  List<dynamic> products = [];
   double total; 
   CheckoutPage({super.key, required this.selectedCarts, required this.total, required this.products});
 @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {

 String? selectedMethod;
 final List<String> paymentMethods = ["Tiền mặt", "Thanh toán qua Momo"];
 bool isLoading = false;
 dynamic user;
 dynamic promotion;
  void initState() {
    super.initState();
   
    getUser();
  }
 
 void getUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await  userProvider.loadSavedLogin();
    setState(() {
      user = userProvider.user;
    });
  }

Future<void> redirectToPayment(String payUrl) async {
  final Uri uri = Uri.parse(payUrl);
  if (await canLaunchUrl(uri)) {
    // Sử dụng chế độ mở trong ứng dụng bên ngoài
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw Exception("Không thể mở URL: $payUrl");
  }
}
Future<void> saveOrderToSharedPreferences(dynamic order) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  await prefs.setString('total', widget.total.toString());
  print('total shared ${widget.total.toString()}');
  String cartJson = jsonEncode(widget.selectedCarts);
  print('cart shared ${cartJson}');
  await prefs.setString('cart', cartJson);
}
Future<void> addOrder() async {
  dynamic order = {
    "userId": user?['id'],
    "totalPrice": widget.total,
    "status": "Chờ xác nhận",
    "name": user?['name'],
    "paymentMethod": selectedMethod,
    "paymentStatus": "Chưa thanh toán",
    "cancellationReason": "",
    "note": "",
    "phone": user?['phone'],
    "address": user?['address']
  };
  if(selectedMethod == "Thanh toán qua Momo")  {
    final momoRequest = {
      "amount": widget.total.toInt().toString(),
      "orderInfo": "Thanh toán đơn hàng qua MoMo cho ${user?['name']}",
    };
    print("momoRequest ${momoRequest}");
     try {
      // Gửi HTTP POST request
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/Payment/create-paymentandroid"), // Địa chỉ API
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(momoRequest),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['errorCode'] == 0) {
          order['status'] = "Đã thanh toán";
          await saveOrderToSharedPreferences(order);
          // Thành công: Chuyển hướng người dùng đến trang thanh toán MoMo
          final payUrl = responseData['payUrl'];
           if (payUrl != null) {
            print("Redirecting to: $payUrl");
            await redirectToPayment(payUrl); // Gọi hàm mở URL
          }
        } else {
          print("Lỗi thanh toán: ${responseData['message']}");
        }
      } else {
        print("Lỗi kết nối API: ${response.statusCode}");
      }
    } catch (error) {
      print("Lỗi khi gọi API thanh toán: $error");
    }
  
  }
  else{
    List<int> ids = widget.selectedCarts.map((cart) => cart['id'] as int).toSet().toList(); // Loại bỏ các ID trùng lặp
  // Xóa giỏ hàng trước
  bool cartDeleted = await deleteCart(ids,user['id']);
  if (!cartDeleted) {
    print('Không thể xóa giỏ hàng, dừng quá trình thêm đơn hàng');
    SnackBar(content: Text('Không thể tạo đơn hàng, vui lòng thử lại'));
    return;
  }
  // Nếu xóa giỏ hàng thành công, tiếp tục thêm đơn hàng
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/Orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final orderId = responseData['id'];
      for (var cartItem in widget.selectedCarts) {
        dynamic orderDetail = {
          'orderId': orderId,
          'colorSizeId': cartItem['colorSizeId'],
          'quantity': cartItem['quantity'],
          'price': cartItem['price'],
          'productId': cartItem['productId']
        };
        try {
          final detailResponse = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/api/OrderDetails'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(orderDetail),
          );

          if (detailResponse.statusCode != 200 && detailResponse.statusCode != 201) {
            print('Failed to add order detail: ${detailResponse.statusCode}');
          }
          if(detailResponse.statusCode == 201){
            updateProductSold(orderDetail['productId'], orderDetail['quantity']);      
          }
        } catch (e) {
          print('Error adding order detail: $e');
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đơn hàng đã được tạo thành công, vui lòng đợi')),
      );
    
      context.go('/account');
    } else {
      print('Failed to add order: ${response.statusCode}');
      SnackBar(content: Text('Tạo đơn hàng bị lỗi, vui lòng thử lại'));
    }
  } catch (e) {
    print('Error adding order: $e');
  }
  }   
}
 
 Future<bool> deleteCart(List<int> ids,int id) async {
  print('user id ${id} IDS ${ids}');
  var uri = Uri.parse('${ApiConfig.baseUrl}/api/Carts/BySelectedItem/${id}');
  var payload = jsonEncode(ids);
   print('payload ${payload}');
  try {
    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );
    if (response.statusCode == 204) {
      print('Cart deleted successfully');
      return true;
    } else {
      print('Failed to update cart: ${response.statusCode}');
      print('Response: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}
 double originPrice = 0;

dynamic getProduct (int id){
    return widget.products.firstWhere((item) => item['id'] == id);
}
Future<void> updateProductSold(int id, int quantity)async {
  dynamic product= getProduct(id);
   var uri = Uri.parse('${ApiConfig.baseUrl}/api/Products/${id}');
   var request = http.MultipartRequest('PUT', uri);

    // Thêm các trường văn bản
    request.fields['name'] = product?['name'];
    request.fields['promo'] = product['promo'].toString();
    request.fields['startRate'] =product['startRate'].toString() ;
    request.fields['unit'] = product['unit'].toString();
    request.fields['createdAt'] = product?['createdAt'] ?? '';
    request.fields['brand'] = product?['brand'] ?? '';
    request.fields['price'] = product['price'].toString();
    request.fields['description'] = product['description'];
    request.fields['categoryId'] = product['categoryId'].toString();
    request.fields['sold'] = (product?['sold'] + quantity).toString();

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');
    if (response.statusCode == 204) {
      print('update product successfully');
    } 
    else {
      print('Failed to update product: ${response.statusCode}');
      var responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');
    }
}

void setPromotion(dynamic promo) {
  setState(() {
    if (promotion == null ) {
      promotion = promo;
      originPrice = widget.total;
      widget.total = widget.total - promo['value'] * 0.01 * widget.total;
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Mỗi đơn hàng chỉ có thể chọn 1 khuyến mãi')),
        );
    }
  });
}
void canclePromotion(dynamic promo) {
  setState(() {
      print("CanclePromotion called");
    widget.total = originPrice;
    promotion = null;
  });
}

void showPromotion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, 
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Chọn khuyến mãi ",
                      style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 120, 127, 199),
              ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: SizedBox(height: 300, width: 290, child: 
            ChoosePromoWidet(setPromotion: setPromotion,selectedPromo: promotion,
            canclePromotion: canclePromotion,totalPrice: widget.total,)
          ),
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
    return Scaffold (
      body:
       Column(
        children: [
          CheckOutAppBar(),
          Expanded(
            child: Container(
                padding: EdgeInsets.only(top:15),
                decoration:BoxDecoration (
                  color: Color(0xFFEDECF2),
                  borderRadius: BorderRadius.only(topLeft:Radius.circular(30) , topRight: Radius.circular(30) ),
                ),
               child: 
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   buildUserInfor(),
                    Padding(padding: EdgeInsets.only(left: 20, top: 15),
                      child: Text("Sản phẩm :",
                        style:TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 48, 48, 49),
                          )
                      ),),
                   Expanded(child: buildCheckoutItem()),

                 ],
               ), 
                  
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Color(0xFFEDECF2),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: DropdownButton<String>(
                    value: selectedMethod,
                    hint: Text("Chọn phương thức thanh toán" ,style: TextStyle(color: Color.fromARGB(255, 28, 28, 28) , fontSize: 18)),
                    items: paymentMethods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method,style: TextStyle(color: Color.fromARGB(255, 25, 25, 25) , fontSize: 18)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMethod = newValue;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 20, bottom: 5),
            height: 60,
            color: Color(0xFFEDECF2),
            child:
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 120, 75, 35) ,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: (){
                      showPromotion();
                    },
                    child: Icon(
                      Icons.add, 
                      color: Colors.white,),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Thêm khuyến mãi",
                      style:TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 214, 114, 48),
                      )
                    ),
                     Text(
                      promotion != null ? promotion['name'] : '',
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis, 
                      style:TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 214, 114, 48),
                        )
                    ),
                  ],
                ),),
                
              ],),
          ),
        ],
      ),
      bottomNavigationBar: buildCheckoutBottom(),
    );
    }
  
  Widget buildUserInfor(){
    return
    user != null ?
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
        color: Color(0xFFEDECF2),
          border: Border(
            bottom: BorderSide(
              color: Color(0xFF4C53A5), 
              width: 1.0, 
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
             children: [
               Text('${user?['name']} ',
               style:TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 46, 45, 45),
                  )
                ),
                Spacer(),
                InkWell(
                      onTap: (){
                         Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(),
                                  ),
                        );
                      },
                      child: Container(
                        width: 90,
                        padding:  EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 108, 114, 188)
                        ),
                        child:  Center(child: Text('Chỉnh sửa', style: TextStyle(fontSize: 15, color:Color.fromARGB(255, 255, 255, 255)),)),
                      ),
              ),
             ],
           ),
            Text('Địa chỉ: ${user['address']} ',
            style:TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 89, 89, 89),
                )
              ),
              Text('Số điện thoại: ${user['phone']} ',
              style:TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 89, 89, 89),
                )
            ),
          ],
        ),
      ),
    )
    :Container(
      height: 75,
    );
  }
  Widget buildCheckoutItem() {
    return   isLoading? Center(child: CircularProgressIndicator())
             :ListView.builder(
                itemCount: widget.selectedCarts.length,
                itemBuilder: (context, index) {
                final cart = widget.selectedCarts[index];
                final product = widget.products.firstWhere((product)=>product?['id'] == cart?['productId'] ,orElse: () => null);
                final finalPrice = product['promo'] > 0 ? (product['price'] -  product['promo']*0.01 * product['price']) *cart['quantity'] : product['price'] *cart['quantity'] ;
                return 
                Container(
                  margin:EdgeInsets.only(left: 15,right: 15, bottom: 10) ,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 10,),
                    //image
                    Center(
                        child: product == null  ? Icon(Icons.image_not_supported, size: 50, color: Colors.grey)
                              : product['image'] != null && product['image'].isNotEmpty
                              ? Image.memory(base64Decode(product['image']), height: 50)
                              : Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          
                      ),
                      //infor cart
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                     
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Text('${product['name']}',
                                              maxLines: 2, 
                                              overflow: TextOverflow.ellipsis,  
                                            style:TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(255, 235, 131, 45),
                                              )
                                         ),
                                    
                                      Row(
                                        
                                          children: [
                                              SizedBox(
                                                width: 120,
                                                child: Text('Số lượng: ${cart['quantity']} ',
                                                    style:TextStyle(
                                                        fontSize: 16,
                                                        color:Color.fromARGB(255, 51, 51, 51),
                                                      )
                                                 ),
                                              ),
                                              
                                                Text(
                                                'Giá: ${NumberFormat('###,###.###').format(finalPrice)} VNĐ',
                                                  style:TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color.fromARGB(255, 51, 51, 51),
                                                    )
                                                  ),
                                          ],
                                        ),
                                    
                                  ],
                                                       ),
                              
                          ],
                        ),  
                      ),                               
                  ]
                )
              );
             }
      );   
  }
 
  Widget buildCheckoutBottom() {
    return Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tạm tính",
                        style: TextStyle(
                          color: Color.fromARGB(255, 28, 28, 28),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          (promotion != null && originPrice > 0) ?
                          Text(
                          '${NumberFormat('###,###.###').format(originPrice)}',
                            style:TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 51, 51, 51),
                                decoration: TextDecoration.lineThrough,
                              )
                          ):SizedBox(),
                          SizedBox(width: 10,),
                          Text(
                             '${NumberFormat('###,###').format(widget.total)} VNĐ',
                            style: TextStyle(
                              color: Color.fromARGB(255, 22, 22, 22),
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      addOrder();
                    },
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 235, 131, 45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "Tiếp tục",
                          style: TextStyle(
                            color: Colors.white,
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



  