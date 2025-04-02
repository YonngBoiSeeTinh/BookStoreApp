import 'dart:convert'; // Để decode Base64
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../AppConfig.dart';
import '../Widget/Alter.dart';
import 'ProductAdd.dart';
import 'ProductEdit.dart';
class ProductManager extends StatefulWidget {
  const ProductManager({super.key});

  @override
  _ProductManagerState createState() => _ProductManagerState();
}

class _ProductManagerState extends State<ProductManager> {
  List<dynamic> products = []; 
  List<dynamic> categories = []; 
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchProducts(); 
    fetchCategories();// Gọi API khi khởi tạo
  }
  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true; // Bắt đầu tải dữ liệu
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Categories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = jsonDecode(response.body);
        });
      } else {
        print('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }finally {
      setState(() {
        isLoading = false; // Kết thúc tải dữ liệu
      });
    }
  }

  Future<void> fetchProducts() async {
     setState(() {
      isLoading = true; // Bắt đầu tải dữ liệu
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Products')); 
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }finally {
      setState(() {
        isLoading = false; // Kết thúc tải dữ liệu
      });
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/api/Products/$id')); 
      if (response.statusCode == 204) {
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return Alter(message: 'Cập nhật sản phẩm thành công!');
        },
      ).then((_) {
       setState(() {
          products.removeWhere((pro) => pro['id'] == id); 
        });
      });
      } else {
        print('Failed to delete products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }
  String getCategoryName(int categoryId) {
    final category = categories.firstWhere(
      (category) => category['id'] == categoryId,
      orElse: () => null,
    );
    return category != null ? category['name'] : 'Unknown Category';
  }
  String formatCurrency(double amount) {
    final pattern = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return amount.toStringAsFixed(0).replaceAllMapped(pattern, (match) => '${match[1]}.') + ' ₫';
  }
  void _showProductDetailDialog(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: SizedBox(
             width: MediaQuery.of(context).size.width * 0.7, 
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    "${product['name']}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4C53A5),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Image
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: product['image'] != null
                          ? Image.memory(
                              base64Decode(product['image']),
                              height: 200,
                              width: 200,
                            )
                          : Container(
                              height: 200,
                               width: 200,
                              color: Colors.grey[200],
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                    ),
                  ),
                  SizedBox(height: 8),
                   Text(
                    "Category: ${getCategoryName(product['categoryId'])}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  // Price
                   SizedBox(height: 8),
                  Text(
                    "Price: ${formatCurrency(product['price'])}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                     Text(
                        'Promotion: ${product['promo']}%',
                        style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 104, 176, 239)),
                      ),
                  SizedBox(height: 8),
                  // Rate
                  // Sold
                  Text(
                    "Sold: ${product['sold']}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
               
                 Text(
                  product['description'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis, // Thêm dấu "..." nếu nội dung vượt quá maxLines
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 90, 90, 90),
                  ),
                ),
                    
                ],
              ),
            ),
          ),
        );
      },
    );
  }
    Future<void> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                onConfirm(); // Gọi hành động xác nhận
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text("Xóa"),
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
      :Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
        title: Text(
          "Quản lý sản phẩm",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF4C53A5)),
        ),
      ),
       body:ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                Uint8List? bytesImage;
                if (product != null && product?['image'] != null && product?['image'].isNotEmpty) {
                  bytesImage = const Base64Decoder().convert(product?['image']);
                } else {
                  bytesImage = Uint8List(0); // Hình ảnh trống
                }
   

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: EdgeInsets.all(14),
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
                    children: [
                      // Hiển thị ảnh từ Base64
                      bytesImage.isNotEmpty 
                          ? Image.memory(
                              bytesImage,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[200],
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                               maxLines: 1, 
                               overflow: TextOverflow.ellipsis, 
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4C53A5),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${formatCurrency(product['price'])}',
                              style: TextStyle(fontSize: 16, color: Color(0xFF4C53A5)),
                            ),
                            SizedBox(height: 4),
                            
                          ],
                        ),
                      ),
                      Container(
                        width: 144,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                _showProductDetailDialog(context, product);
                              },
                              icon: Icon(Icons.remove_red_eye),
                              color: Color.fromARGB(255, 68, 128, 202),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductUpdatePage(product: product,), // Truyền id vào ProductUpdatePage
                                    ),
                                  );
                               },
                              icon: Icon(Icons.edit),
                              color: Colors.orange,
                            ),
                            IconButton(
                              onPressed: () {
                                showConfirmDialog(
                                  context: context,
                                  title: "Xác nhận",
                                  content: "Bạn có chắc muốn xóa sản phẩm này không?",
                                  onConfirm: () {
                                    deleteProduct(product['id']);
                                  },
                                );
                              },
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         Navigator.push(context, 
          MaterialPageRoute(
            builder: (context) => (AddProductPage()), // Truyền id vào ProductUpdatePage
          ),);
        },
        backgroundColor: Color(0xFF4C53A5),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
