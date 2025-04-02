import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../AppConfig.dart';
import '../Widget/Alter.dart';
import 'HomePage.dart';
class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController promoController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<Map<String, String>> colorSizeList = [];
  List<dynamic> categories = []; 
  Map<String, dynamic>? product;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }
  Future<void> fetchCategories() async {
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
  }
}

  Future<void> addProduct(File? imageFile) async {
  var uri = Uri.parse('${ApiConfig.baseUrl}/api/Products');
  var request = http.MultipartRequest('POST', uri);

  // Thêm các trường văn bản
  request.fields['name'] = nameController.text;
  request.fields['promo'] = promoController.text;
  request.fields['unit'] = unitController.text;
  request.fields['brand'] =  'Test';
  request.fields['startRate'] =  0.toString();
  request.fields['price'] = priceController.text;
  request.fields['description'] = descriptionController.text;
  request.fields['categoryId'] = selectedCategoryId ?? '';

  // Thêm tệp hình ảnh nếu có
  if (imageFile != null) {
    var multipartFile = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
    );
    request.files.add(multipartFile);
  }

  // Gửi yêu cầu
  var response = await request.send();

  if (response.statusCode == 201) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Alter(message: 'Thêm sản phẩm thành công!');
      },
    ).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Homepage(index: 1),
        ),
      );
    });
    } else {
      Alter(message: 'Thêm sản phẩm thất bại, vui lòng thử lại!');
      print('Failed to add product: ${response.statusCode}');
      var responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        title: Text("Add Product"),
        backgroundColor: Color(0xFF4C53A5),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildProductImage(),
          Text("Product info" ,style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C53A5),
            ),),
          _buildTextField("Product Name", nameController),
          _buildTextField("Price", priceController, keyboardType: TextInputType.number),
          _buildTextField("Unit", unitController),
          _buildTextField("Promo", promoController, keyboardType: TextInputType.number),
          _buildCategorySelection(),
          _buildTextField("Description", descriptionController, maxLines: 3),
          SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                addProduct(imageFile);
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
                                "Add",
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
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
  Widget _buildProductImage() {
      return  Container(
          width: double.infinity,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                imageFile != null
                    ? Image.file(
                        imageFile!,
                        height: 200,
                      )
                    :product?['image'] != null ?Image.memory(
                              base64Decode(product?['image']),
                              height: 200,
                      )
                     :Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(
                        color: Color(0xFF4C53A5),
                        width: 2,
                      ),
                    ),
                    shadowColor: Colors.black,
                    elevation: 6,
                  ),
                  child: Text(
                    "Thêm Ảnh",
                    style: TextStyle(color: Color(0xFF4C53A5), fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        );
      }
  String? selectedCategoryId;

  Widget _buildCategorySelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Category",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C53A5),
            ),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedCategoryId,
            items: categories.map<DropdownMenuItem<String>>((category) {
              return DropdownMenuItem<String>(
                value: category['id'].toString(),
                child: Text(category['name']),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                selectedCategoryId = value;
              });
            },
            hint: Text("Select a category"),
          ),
        ],
      ),
    );
  }


  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

 }
