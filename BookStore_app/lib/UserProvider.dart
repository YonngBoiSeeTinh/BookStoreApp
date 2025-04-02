import 'dart:convert';
import 'package:GOSY/AppConfig.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;
  int? _userId;
  final String loginUrl = '${ApiConfig.baseUrl}/api/Accounts/login';
  final String userInfoUrl = '${ApiConfig.baseUrl}/api/Users';
  // Lưu thông tin đăng nhập
  Future<void> _saveLogin(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  // Tải thông tin đăng nhập từ bộ nhớ
  Future<void> loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');

    if (_userId != null) {
      await fetchUserInfo(_userId!);
    }
  }
  //lamnt108@gmail.com
  // Hàm đăng nhập
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        _userId = jsonDecode(response.body);
         print('_userId ${_userId} ${_userId.runtimeType}');
        await _saveLogin(_userId!); 
        await fetchUserInfo(_userId!);
        return true;
      } else {
        throw Exception("Login failed: ${jsonDecode(response.body)['message']}");
      }
    } catch (error) {
      print("Error during login: $error");
      return false;
    }
  }
  // Hàm lấy thông tin người dùng
  Future<void> fetchUserInfo(int id) async {
    try {
      final url = '$userInfoUrl/$id';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _user = jsonDecode(response.body);
        notifyListeners();
      } else {
        throw Exception("Failed to fetch user: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching user: $error");
    }
  }
  // Đăng xuất
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Xóa thông tin khỏi SharedPreferences
    _user = null;
    _userId = null;
    notifyListeners();
  }
}
