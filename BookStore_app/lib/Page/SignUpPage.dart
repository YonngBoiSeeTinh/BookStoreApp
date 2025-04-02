import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/Page/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class SignupPage extends StatefulWidget {

  const SignupPage({super.key, this.title});
  final String? title;

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  Widget _backButton() {
      return InkWell(
        onTap: () {
        Navigator.pop(context);
        },child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 80),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black, size: 30,),
            ),
          ],
        ),
            
      );
  }
  Future<void> signup(int userId )async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/Accounts'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': _emailController.text, 'password': _passwordController.text,'userId':userId, 'username':_userNameController.text}),
      );
      if (response.statusCode == 201) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng ký thành công!')),
          );
      } else {
        throw Exception("Sign up failed: ${jsonDecode(response.body)['message']}");
      }
    } catch (error) {
      print("Error during Sign up: $error");
     
    }
  }
  Widget _submitButton() {
  return InkWell(
    onTap: () async {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();
      final name = _nameController.text.trim();
      final userName = _nameController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email và mật khẩu không được để trống!')),
        );
        return;
      }

      try {
        // Gọi API tạo user trước
        var uri = Uri.parse('${ApiConfig.baseUrl}/api/Users');
        var request = http.MultipartRequest('POST', uri);
        request.fields['name'] = name;
        request.fields['address'] = address;
        request.fields['phone'] = phone;
        request.fields['totalBuy'] = "0";
        request.fields['account'] = "0";
        request.fields['role'] = "1";

        var response = await request.send();

        if (response.statusCode == 201) {
         
          var responseBody = await response.stream.bytesToString();
          var userId = jsonDecode(responseBody)['id']; 

          // Gọi API tạo account với `userId` vừa tạo
          await signup(userId);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          var responseBody = await response.stream.bytesToString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tạo người dùng thất bại: $responseBody')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $error')),
        );
      }
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromARGB(255, 51, 126, 223).withAlpha(100),
            offset: Offset(2, 4),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ],
        color: Colors.white,
      ),
      child: Text(
        'Đăng ký',
        style: TextStyle(fontSize: 20, color: Color(0xFF4C53A5)),
      ),
    ),
  );
}

   Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Boo',
          style: GoogleFonts.portLligatSans(
            
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: 'k S',
              style: TextStyle(color: Colors.black, fontSize: 40),
            ),
            TextSpan(
              text: 'hop',
              style: TextStyle(color: Colors.white, fontSize: 40),
            ),
          ]),
    );
  }
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Widget _entryField(String title,TextEditingController controller, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              controller: controller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }
 
   Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bạn đã có tài khoản ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Đăng nhập',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SingleChildScrollView(
        child:Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.shade200,
                      offset: Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color.fromARGB(255, 187, 191, 234), Color(0xFF4C53A5)])),
              child: Stack(
                children: [
                  Positioned(top: 20, left: 0, child: _backButton()),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 15,),
                      _title(),
                      
                      _entryField("Email", _emailController),
                      _entryField("Họ và tên", _nameController),
                      _entryField("Tên tài khoản", _userNameController),
                      _entryField("Số điện thoại", _phoneController),
                      _entryField("Địa chỉ", _addressController),
                      _entryField("Mật khẩu", _passwordController,isPassword: true),
                      SizedBox(height: 20),
                      _submitButton(),
                      SizedBox(  height: 20,   ),
                      _loginAccountLabel(),
                    
                    ],
                  ),
                ],
              ),
          ),
      ),
    );
  }
}
