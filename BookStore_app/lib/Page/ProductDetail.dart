import 'dart:convert';
import 'dart:typed_data';
import 'package:GOSY/AppConfig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:GOSY/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic>? product;
  ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  int stock = 10;

  void changeQuantity(String action) {
    setState(() {
      if (action == "add" && quantity < stock) {
        quantity++;
      } else if (action == "minus" && quantity > 1) {
        quantity--;
      }
    });
  }
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
        'quantity': quantity.toString(),
        'userId': user?['id'].toString(),
        'price': widget.product?['price'].toString(),
        'colorSizeId': '0',
      };
     
      if (check is Map<String, dynamic>){
        var uriUpdate = Uri.parse('${ApiConfig.baseUrl}/api/Carts/${check?['id']}');
        var bodyUpdate = Map<String, dynamic>.from(check);
        bodyUpdate['quantity'] +=quantity;    
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDECF2),
      body: Column(
        children: [
          _buildAppBar(),
          _buildProductImage(widget.product),
          _buildProductDetails(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(onTap: (){
            Navigator.pop(context);
          }, child: Icon(Icons.arrow_back,size: 30, color: const Color.fromARGB(255, 236, 106, 12))),
          Icon(Icons.share,size: 30, color: const Color.fromARGB(255, 236, 106, 12)),
        ],
      ),
    );
  }

  Widget _buildProductImage(dynamic product) {
    Uint8List? bytesImage;
    if (product != null && product['image'] != null && product['image'].isNotEmpty) {
      bytesImage = const Base64Decoder().convert(product['image']);
    } else {
      bytesImage = Uint8List(0);
    }
    return Container(
      height: 450,
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: bytesImage.isNotEmpty
          ? Image.memory(bytesImage, fit: BoxFit.cover)
          : Icon(Icons.image, size: 100, color: Colors.grey),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.product?['name'] ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 201, 109, 63))
                ),
              ),
              Icon(Icons.favorite_border, color: const Color.fromARGB(255, 201, 109, 63)),
            ],
          ),
          SizedBox(height: 5),
         
          Row(
            children: [
              Text("Đánh giá", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(width: 10),
              ...List.generate(5, (index) => Icon(Icons.star, color: Colors.orange, size: 22)),
            ],
          ),
        
          SizedBox(height: 10),
          _buildQuantitySelector(),
           SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text("Mô tả", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text( 
                widget.product?['description'] ?? '', 
               style: TextStyle(fontSize: 19,color: Colors.grey),
               maxLines: 4,
              ),
          ],),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            _buildQuantityButton(CupertinoIcons.minus, "minus"),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                quantity.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildQuantityButton(CupertinoIcons.plus, "add"),
          ],
        ),
        Spacer(),
          
            
            widget.product?['promo'] > 0 ?
              Text(
              '${NumberFormat('###,###').format(widget.product?['price'])} đ',
                style: TextStyle(
                  color: Color.fromARGB(255, 61, 61, 61),
                  fontSize: 18,
                
                  decoration: TextDecoration.lineThrough,
                ),
              ):SizedBox(width: 20,),
              SizedBox(width: 10,),
              Text(
              '${NumberFormat('###,###').format(widget.product?['price'] -  widget.product?['promo']*0.01 * widget.product?['price'])} đ',
                style: TextStyle(
                  color: Color.fromARGB(255, 188, 94, 48),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, String action) {
    return InkWell(
      onTap: () => changeQuantity(action),
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {addProduct();},
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 196, 113, 58),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text("Thêm vào giỏ hàng", style: TextStyle(fontSize: 22, color: Colors.white)),
      ),
    );
  }
}