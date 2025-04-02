import 'dart:convert'; // Để decode Base64
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../AppConfig.dart';
import '../Widget/Alter.dart';
import 'CategoryAdd.dart';
import 'CategoryEdit.dart';
import 'PromotionEdit.dart';

class PromotionManager extends StatefulWidget {
  const PromotionManager({super.key});

  @override
  _CategoryManagerState createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<PromotionManager> {
  List<dynamic> promotions = []; 
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchPromotion();
  }
  Future<void> fetchPromotion() async {
    setState(() {
      isLoading = true; 
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Promotions'));
      if (response.statusCode == 200) {
        setState(() {
          promotions = jsonDecode(response.body);
        });
      } else {
        print('Failed to load promotions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching promotions: $e');
    }finally {
      setState(() {
        isLoading = false; // Kết thúc tải dữ liệu
      });
    }
  }

 
  Future<void> deletePromotion(int id) async {
    try {
      final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/api/Promotions/$id')); 
      if (response.statusCode == 204) {
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return Alter(message: 'Cập nhật sản phẩm thành công!');
        },
      ).then((_) {
        setState(() {
          promotions.removeWhere((order) => order['id'] == id); 
        });
      });
      } else {
        print('Failed to delete Categorys: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Categorys: $e');
    }
  }
 
   void _showPromotionDetailDialog(BuildContext context, dynamic promotion) {
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
            child: Container(
              padding: EdgeInsets.all(16),
              height: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${promotion['name']}",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4C53A5),
                    ),
                  ),

                  SizedBox(height: 16),
                  Text(
                    'Giảm       : ${promotion['value']} %',
                    style: TextStyle(fontSize: 23, color: const Color.fromARGB(255, 142, 179, 136)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tối thiểu : ${promotion['minPrice']}',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                   SizedBox(height: 8),
                  Text(
                    'Tối đa      : ${promotion['maxValue']}',
                    style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 43, 43, 43)),
                  ),
                    SizedBox(height: 8),
                  Text(
                    'Mã           : ${promotion['code']}',
                    style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 40, 40, 40)),
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
          "Quản lý khuyến mãi",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF4C53A5)),
        ),
      ),
       body:ListView.builder(
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promotion = promotions[index];
               
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
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              promotion['name'],
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
                              '${promotion['value']} %',
                               maxLines: 2, 
                              overflow: TextOverflow.ellipsis, 
                              style: TextStyle(fontSize: 18, color: Color(0xFF4C53A5)),
                            ),
                            SizedBox(height: 4),
                            
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _showPromotionDetailDialog(context, promotion);
                            },
                            icon: Icon(Icons.remove_red_eye),
                            color: Color.fromARGB(255, 68, 128, 202),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PromotionUpdatePage(promotion: promotion,), 
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
                                  deletePromotion(promotion['id']);
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
