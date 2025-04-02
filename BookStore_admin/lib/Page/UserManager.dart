import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../AppConfig.dart';


class UserManager extends StatefulWidget {
  const UserManager({super.key});

  @override
  _UserManagerState createState() => _UserManagerState();
}

class _UserManagerState extends State<UserManager> {
  List<dynamic> users = [];
  List<dynamic> roles = [];
 @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchRoles();
  }
  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Users'));
      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
        });
      } else {
        print('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }
  Future<void> fetchRoles() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Roles'));
      if (response.statusCode == 200) {
        setState(() {
          roles = jsonDecode(response.body);
        });
      } else {
        print('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }
  String getRole (int? roleId) {
    if (roleId == null || roles.isEmpty) {
    return "";
    }
   
      final role = roles.firstWhere((role) => role['id'] == roleId);
      return role?['name'] ?? "";
    
  }
  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Chi tiết người dùng",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Text("Tên: ${user['name']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
               Text("${getRole(user['role'])}", 
                style: TextStyle(
                  fontSize: 18,
                  color: user['role'] == 2
                        ? Colors.green
                        : const Color.fromARGB(255, 95, 165, 195)
                )
              ),
              SizedBox(height: 8),
              Text("Địa chỉ: ${user['address']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text("Số điện thoại: ${user['phone']}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text("Đã chi: ${ NumberFormat('###,###').format( user['totalBuy'])} đ", style: TextStyle(fontSize: 18)),
              
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.white,
        title: Text(
          "Quản lý người dùng",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color:  Color(0xFF4C53A5),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: EdgeInsets.all(16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100)
                            ),
                        child: user?['image'] != null
                            ? SizedBox(
                              height: 40,
                              width: 40,
                              child: ClipOval(
                                child: Image.memory(
                                    base64Decode(user['image']),
                                    fit: BoxFit.cover,
                                    height: 40,
                                ),
                              ),
                            )
                          : Container(
                              child: Icon(Icons.account_circle_rounded, size: 35,),
                            ),
                    ),
                  
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            user['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        Text(user['phone'], style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                     Container(
                      width: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: user['role'] == 2
                              ? Colors.green
                              : const Color.fromARGB(255, 95, 165, 195),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        getRole(user['role']),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromARGB(255, 47, 47, 47)),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _showUserDetails(user);
                          },
                          icon: Icon(Icons.remove_red_eye),
                          color: Colors.blue,
                        ),
                        IconButton(
                          onPressed: () {
                            print('Edit user: ${user['name']}');
                          },
                          icon: Icon(Icons.edit),
                          color: Colors.orange,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              users.removeAt(index);
                            });
                          },
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
