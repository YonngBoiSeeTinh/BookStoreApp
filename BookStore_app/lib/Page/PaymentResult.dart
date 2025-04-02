import 'dart:convert';

import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/Page/AccountPage.dart';
import 'package:GOSY/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentResult extends StatefulWidget {
   List<dynamic> products = [];
     PaymentResult({super.key, required this.products});
  @override
  _PaymentResultState createState() => _PaymentResultState();
}

class _PaymentResultState extends State<PaymentResult> {
  String? paymentStatus; // Biến để lưu trạng thái thanh toán
  late AppLinks _appLinks; 
  StreamSubscription<Uri?>? _sub;
  List<dynamic> selectedCarts = [];
  String? totalPrice;
  bool isLoading = false;
  dynamic user;
  List<dynamic> colorSizes = [];
  @override
  void initState() {
    super.initState();
    fetchColorSizes();
    handelAddOrder();
  }

  @override
  void dispose() {
    _sub?.cancel(); // Hủy lắng nghe khi widget bị hủy
    super.dispose();
  }

  Future<void> _initDeepLinkListener() async {
    _appLinks = AppLinks();
   
    // Lấy deep link khởi tạo 
    try {
      final initialUri = await _appLinks.getInitialAppLink();
     
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      setState(() {
        paymentStatus = "Lỗi xảy ra khi xử lý Deep Link khởi tạo.";
      });
    }

    // Lắng nghe Deep Link
    _sub = _appLinks.uriLinkStream.listen(
      (Uri? deepLink) {
        if (deepLink != null) {
          _handleDeepLink(deepLink);
        }
      },
      onError: (err) {
        setState(() {
          paymentStatus = "Lỗi xảy ra khi xử lý Deep Link.";
        });
      },
    );
  }

  void _handleDeepLink(Uri deepLink) async{
    final status = deepLink.queryParameters['message']; 
    setState(() {
      paymentStatus = status;
    });
   
  }
  
  Future<void> fetchColorSizes() async {
  setState(() {
      isLoading = true; 
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/ColorSizes'));
      if (response.statusCode == 200) {
        setState(() {
          colorSizes = jsonDecode(response.body);
        });
      } else {
        print('Failed to load ColorSizes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ColorSizes: $e');
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void>  getUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await  userProvider.loadSavedLogin();
    setState(() {
      user = userProvider.user;
    });
  }
  Future<void> loadDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Lấy dữ liệu giỏ hàng đã chọn
    String? selectedCartsJson = prefs.getString('cart');
    if (selectedCartsJson != null) {
      selectedCarts = jsonDecode(selectedCartsJson);
      print('Loaded selected carts: $selectedCarts');
    } else {
      print('No selected carts found in SharedPreferences');
    }
    // Lấy dữ liệu đơn hàng
    setState(() {
       totalPrice = prefs.getString('total');
      print('totalPrice: $totalPrice');
    });
   
  }
  Future<void> handelAddOrder() async {
    setState(() {
      isLoading = true;
    });
    await _initDeepLinkListener();
     
    if(paymentStatus != null){
      await getUser();
      await loadDataFromSharedPreferences();
      if (paymentStatus == "Success"){
         if(user != null){
          if (selectedCarts.length > 0) {
             await addOrder();
          }
         }
         
      }
    }
     setState(() {
      isLoading = false;
    });
  }
Future<void> addOrder() async {
  dynamic order = {
    "userId": user?['id'],
    "totalPrice":  totalPrice,
    "status": "Đã thanh toán",
    "name": user?['name'],
    "paymentMethod": "Momo",
    "paymentStatus": "Đã thanh toán",
    "cancellationReason": "",
    "note": "",
    "phone": user?['phone'],
    "address": user?['address']
  };
   {
    List<int> ids = selectedCarts.map((cart) => cart['id'] as int).toSet().toList(); // Loại bỏ các ID trùng lặp
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
        for (var cartItem in selectedCarts) {
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
              updateColorSizes(orderDetail['colorSizeId'], orderDetail['quantity']);
            
            }
          } catch (e) {
            print('Error adding order detail: $e');
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đơn hàng đã được tạo thành công, vui lòng đợi')),
        );
      
      
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
 dynamic getColorSize (int id){
    return colorSizes.firstWhere((item) => item['id'] == id);
}
Future<void> updateColorSizes(int id, int quantity)async {
  dynamic colorSize= getColorSize(id);
    try {
    
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/ColorSizes/${id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "id": colorSize["id"].toString(),
          "color": colorSize["color"],
          "size": colorSize["size"],
          "quantity":( colorSize["quantity"] - quantity).toString(),
          "productId":colorSize['productId'].toString(), 
          "code": colorSize["code"],
          "createdAt": colorSize["createdAt"],
          "price":0
        }),
      );

      if (response.statusCode == 204) {
        print('Successfully updated color size: ${response.body}');
      } else {
        print('Failed to update color size: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating color size: $e');
    }
  }

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kết quả thanh toán", style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: const Color.fromARGB(255, 129, 95, 198),
      ),
      body: Center(
        child: paymentStatus == null || isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    paymentStatus == "Success"
                        ? Icons.check_circle
                        : Icons.error,
                    size: 100,
                    color: paymentStatus == "Success" ? Colors.green : Colors.red,
                  ),
                  SizedBox(height: 20),
                  Text(
                    paymentStatus == "Success"
                        ? "Thanh toán thành công!"
                        : "Thanh toán thất bại!",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      context.go('/account');
                    },
                    child: Container(
                      width: 230,
                      padding: EdgeInsets.symmetric(vertical: 13),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: const Color.fromARGB(255, 26, 201, 70), width: 2),
                        color: const Color.fromARGB(255, 164, 209, 166)
                      ),
                      child: Text(
                        'Xem đơn hàng của bạn',
                        style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 27, 77, 6)),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
