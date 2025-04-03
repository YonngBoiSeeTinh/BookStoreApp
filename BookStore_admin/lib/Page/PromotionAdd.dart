import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Widget/Alter.dart';
import '../AppConfig.dart';
import 'HomePage.dart';

class PromotionAddPage extends StatefulWidget {
  const PromotionAddPage({super.key});

  @override
  _PromotionAddPageState createState() => _PromotionAddPageState();
}

class _PromotionAddPageState extends State<PromotionAddPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxValueController = TextEditingController();
  final TextEditingController valueController = TextEditingController();

  bool isLoading = false;

  Future<void> addPromotion() async {
    var uri = Uri.parse('${ApiConfig.baseUrl}/api/Promotions');
    final body = jsonEncode({
      "name": nameController.text,
      "code": codeController.text,
      "minPrice": minPriceController.text,
      "maxValue": maxValueController.text,
      "value": valueController.text,
      "endAt": endController.text,
      "createdAt": DateTime.now().toIso8601String(),
    });

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Alter(message: 'Thêm khuyến mãi thành công!');
          },
        ).then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage(index: 5)),
          );
        });
      } else {
        Alter(message: 'Thêm khuyến mãi thất bại, vui lòng thử lại!');
        print('Failed to add promotion: ${response.statusCode}');
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
              title: Text(
                "Thêm khuyến mãi",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: Color(0xFF4C53A5),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Thông tin khuyến mãi",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C53A5)),
                  ),
                  _buildTextField("Tên khuyến mãi", nameController),
                  _buildTextField("Giá trị giảm (%)", valueController),
                  _buildTextField("Tối thiểu", minPriceController),
                  _buildTextField("Tối đa", maxValueController),
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
                  addPromotion();
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
                  child: Row(
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
                            "Thêm mới",
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
