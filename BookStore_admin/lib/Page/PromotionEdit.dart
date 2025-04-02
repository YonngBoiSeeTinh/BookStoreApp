import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../Widget/Alter.dart';
import '../AppConfig.dart';
import 'HomePage.dart';


class PromotionUpdatePage extends StatefulWidget {

  final Map<String, dynamic> promotion;
  const PromotionUpdatePage({super.key, required this.promotion});

  @override
  _CategoryUpdatePageState createState() => _CategoryUpdatePageState();
}

class _CategoryUpdatePageState extends State<PromotionUpdatePage> {
  final TextEditingController nameController =TextEditingController();
  final TextEditingController codeController =TextEditingController();
  final TextEditingController endController =TextEditingController();
  final TextEditingController minPriceController =TextEditingController();
  final TextEditingController maxValueController =TextEditingController();
  final TextEditingController valueController =TextEditingController();


  
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    nameController.text = widget.promotion?['name'] ?? '';
    codeController.text = widget.promotion?['code'] ?? '';
    minPriceController.text = widget.promotion?['minPrice'].toString() ?? '';
    maxValueController.text = widget.promotion?['maxValue'].toString() ?? '';
    endController.text = widget.promotion?['endAt'].toString() ?? '';
    valueController.text = widget.promotion?['value'].toString() ?? '';
  }
  Future<void> updatePromotion() async {
    var uri = Uri.parse('${ApiConfig.baseUrl}/api/Promotions/${widget.promotion['id']}');
    final body = jsonEncode({
      "createdAt": widget.promotion?['createdAt'],
      "code": codeController.text,
      "minPrice": minPriceController.text,
      "name": nameController.text,
      "maxValue": maxValueController.text, 
      "value":valueController.text,
      "endAt":endController.text  
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
        showDialog(
      context: context,
      builder: (BuildContext context) {
        return Alter(message: 'Cập nhật khuyến mãi thành công!');
      },
    ).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Homepage(index: 5),
        ),
      );
    });
    } else {
      Alter(message: 'Cập nhật mã giảm giá, vui lòng thử lại!');
      print('Failed to update category: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
 Future<void> _selectEndDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Chọn ngày kết thúc',
    );
    if (pickedDate != null) {
      setState(() {
        endController.text = pickedDate.toIso8601String().split('T').first;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return isLoading
      ? const Center(child: CircularProgressIndicator())
      : Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        title: Text("Cập nhật khuyến mãi",style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF4C53A5),
        iconTheme: IconThemeData(
          color: Colors.white,
         ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(nameController.text ,style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 74, 87, 227),
              ),),
              SizedBox(height: 30,),
            Text("Thông tin khuyến mãi" ,style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C53A5),
              ),),
           
            _buildTextField("Tên khuyến mã", nameController),
            _buildTextField("Giá trị giảm (%)", valueController),
            _buildTextField("Tối thiểu", minPriceController),
            _buildTextField("Tối đã", maxValueController),
            _buildTextField(
                    "Ngày kết thúc",
                    endController,
                    onTap: () => _selectEndDate(context),
                    readOnly: true,
                  ),
            _buildTextField("Mã giảm giá", codeController),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                updatePromotion();
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

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1,
      VoidCallback? onTap,
      bool readOnly = false,
  }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
        ),
      );
    }
  }
