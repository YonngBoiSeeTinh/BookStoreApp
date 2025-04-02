import 'dart:convert';
import 'dart:io';
import 'package:GOSY/Page/AccountPage.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/Page/welcomePage.dart';
import 'package:GOSY/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? account;
  dynamic user;
  final picker = ImagePicker();
  File? imageFile;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserStatus();
    });
  }

  Future<void> fetchUserAccount(int id) async {
    try {
      final url = '${ApiConfig.baseUrl}/api/Accounts/';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          account = jsonDecode(response.body).firstWhere((ac) => ac['userId'] == id);
        });
       
      } else {
        throw Exception("Failed to fetch user: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching user: $error");
    }
  }

  void _checkUserStatus() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await userProvider.loadSavedLogin();
    if (userProvider.user == null) {
      context.push('/welcomePage');
    } else {
      fetchUserAccount(userProvider.user?['id']);
      setState(() {
        user = userProvider.user;
      });
      nameController.text = userProvider.user?['name'] ?? '';
      phoneController.text = userProvider.user?['phone'] ?? '';
      addressController.text = userProvider.user?['address'] ?? '';
    }
  }
  //

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> updateUser() async {
    try {
      var uri = Uri.parse('${ApiConfig.baseUrl}/api/Users/${user['id']}');
      var request = http.MultipartRequest('PUT', uri);

      request.fields['name'] = nameController.text;
      request.fields['address'] = addressController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['createdAt'] = user?['createdAt'] ?? '';
      request.fields['totalBuy'] = user?['totalBuy'].toString() ?? '';
      request.fields['role'] = user?['role'].toString() ?? '';
    // request.fields['dateofBorth'] =  user?['dateofBorth'] ;

      if (imageFile != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          imageFile!.path,
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thông tin thành công!')),
        ); 
        context.go('/account');
      } else {
        var responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại: $responseBody')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $error')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget builtProfileAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      height: 90,
      child: Row(
        children: [
          InkWell(
            onTap: () {
             context.go('/');
            },
            child: Icon(
              Icons.arrow_back,
              size: 30,
              color: Color(0xFF4C53A5),
            ),
          ),
          SizedBox(width: 30),
          Text(
            'Cập nhật thông tin',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4C53A5),
            ),
          ),
        ],
      ),
    );
  }

  Widget builtProfileAvatar() {
    return Container(
      height: 222,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 175,
            height: 175, 
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: imageFile != null
                ? ClipOval(child: Image.file(imageFile!, fit: BoxFit.cover))
                : user!= null && user?['image'] != null?
                  ClipOval(child: Image.memory(base64Decode(user?['image']), fit: BoxFit.cover))
                : Icon(Icons.account_circle, size: 180),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: _pickImage,
            child: Container(
              width: 120,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFF4C53A5)),
                color: Color(0xFF6C72BC),
              ),
              child: Center(
                child: Text(
                  'Chọn ảnh',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: user != null
          ? SingleChildScrollView(
              child: Column(
                children: [
                  builtProfileAppBar(),
                  Container(
                     height: MediaQuery.of(context).size.height,
                    decoration:BoxDecoration (
                      color: Color(0xFFEDECF2),
                      borderRadius: BorderRadius.only(topLeft:Radius.circular(30) , topRight: Radius.circular(30) ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                         builtProfileAvatar(),
                        _buildTextField('Họ và tên', nameController),
                        _buildTextField('Số điện thoại', phoneController, keyboardType: TextInputType.phone),
                        _buildTextField('Địa chỉ', addressController),
                        SizedBox(height: 20),
                        InkWell(
                          onTap: updateUser,
                          child: Container(
                            width: 200,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Color(0xFF4C53A5)),
                              color: Color(0xFF6C72BC),
                            ),
                            child: Center(
                              child: Text(
                                'Cập nhật thông tin',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                       
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
