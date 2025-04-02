import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../AppConfig.dart';
import '../Widget/Alter.dart';
import 'HomePage.dart';


class CategoryUpdatePage extends StatefulWidget {

  final Map<String, dynamic> category;
  const CategoryUpdatePage({super.key, required this.category});

  @override
  _CategoryUpdatePageState createState() => _CategoryUpdatePageState();
}

class _CategoryUpdatePageState extends State<CategoryUpdatePage> {
  final TextEditingController nameController =TextEditingController();
  final TextEditingController descriptionController =TextEditingController();
  File? imageFile;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    nameController.text = widget.category?['name'] ?? '';
    descriptionController.text = widget.category?['description'] ?? '';
  }
  Future<void> updatecategory(File? imageFile) async {
  var uri = Uri.parse('${ApiConfig.baseUrl}/api/Categories/${widget.category['id']}');
  var request = http.MultipartRequest('PUT', uri);

  // Thêm các trường văn bản
  request.fields['name'] = nameController.text;
  request.fields['description'] = descriptionController.text;
  request.fields['createdAt'] = widget.category['createdAt'];

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

  if (response.statusCode == 204) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Alter(message: 'Cập nhật danh mục thành công!');
      },
    ).then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Homepage(index: 4),
        ),
      );
    });
    } else {
      Alter(message: 'Cập nhật sản phẩm thất bại, vui lòng thử lại!');
      print('Failed to update category: ${response.statusCode}');
      var responseBody = await response.stream.bytesToString();
      print('Response body: $responseBody');
    }
}
  @override
  Widget build(BuildContext context) {
    return isLoading
      ? const Center(child: CircularProgressIndicator())
      : Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        title: Text("Update category",style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF4C53A5),
        iconTheme: IconThemeData(
          color: Colors.white,
         ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildcategoryImage(),
          Text("category info" ,style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C53A5),
            ),),
          _buildTextField("category Name", nameController),
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
                updatecategory(imageFile);
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
                                "Update",
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
  Widget _buildcategoryImage() {
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
                    :widget.category?['image'] != null ?Image.memory(
                              base64Decode(widget.category?['image']),
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
