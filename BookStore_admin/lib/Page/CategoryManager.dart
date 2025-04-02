import 'dart:convert'; // Để decode Base64
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import '../AppConfig.dart';
import '../Widget/Alter.dart';
import 'CategoryAdd.dart';
import 'CategoryEdit.dart';
import 'ProductEdit.dart';
class CategoryManager extends StatefulWidget {
  const CategoryManager({super.key});

  @override
  _CategoryManagerState createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  List<dynamic> products = []; 
  List<dynamic> categories = []; 
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchProducts(); 
    fetchCategories();
  }
  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true; 
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
      isLoading = true; 
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
        isLoading = false; 
      });
    }
  }

   Future<void> deleteCategory(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/api/Categories/$id')); 
      if (response.statusCode == 204) {
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return Alter(message: 'Xóa thành công!');
        },
      ).then((_) {
        setState(() {
          categories.removeWhere((order) => order['id'] == id); 
        });
      });
      } else {
        print('Failed to delete Categorys: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Categorys: $e');
    }
  }
 
   void _showCategortDetailDialog(BuildContext context, dynamic category) {
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
                  Text(
                    "${category['name']}",
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
                      child: category['image'] != null
                          ? Image.memory(
                              base64Decode(category['image']),
                              height: 200,
                            )
                          : Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description: ",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      Expanded( 
                        child: Text(
                          category['description'],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis, // Thêm dấu "..." nếu nội dung vượt quá maxLines
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 90, 90, 90),
                          ),
                        ),
                      ),
                    ],
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
          "Quản lý danh mục",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF4C53A5)),
        ),
      ),
       body:ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
               
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
                    children: [
                      // Hiển thị ảnh từ Base64
                     category['image'] != null
                          ? Image.memory(
                              base64Decode(category['image']),
                              height: 80,
                              width: 80,
                            )
                          : Container(
                              height: 80,
                                 width: 80,
                              color: Colors.grey[80],
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4C53A5),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${category['description']}',
                               maxLines: 2, 
                              overflow: TextOverflow.ellipsis, 
                              style: TextStyle(fontSize: 15, color: Color(0xFF4C53A5)),
                            ),
                            SizedBox(height: 4),
                            
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _showCategortDetailDialog(context, category);
                            },
                            icon: Icon(Icons.remove_red_eye),
                            color: Color.fromARGB(255, 68, 128, 202),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryUpdatePage(category: category,), 
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
                                content: "Bạn có chắc muốn xóa danh mục này không?",
                                onConfirm: () {
                                  deleteCategory(category['id']);
                                },
                              );
                            },
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                          ),
                        ],
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
            builder: (context) => (CategoryAddPage()), 
          ),);
        },
        backgroundColor: Color(0xFF4C53A5),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
