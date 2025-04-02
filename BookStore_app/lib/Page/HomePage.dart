import 'dart:convert';
import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/Page/AccountPage.dart';
import 'package:GOSY/Page/CartPage.dart';
import 'package:GOSY/Page/ProductHomePage.dart';
import 'package:http/http.dart' as http;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
 

class Homepage extends StatefulWidget {
  
  List<dynamic> products = [];
  List<dynamic> categories = [];
   Homepage({super.key, required this.products, required this.categories});
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    // Trang hiện tại dựa trên `_currentIndex`
    Widget currentPage;
    if (_currentIndex == 0) {
      currentPage = ProductHomepage(products: widget.products, categories: widget.categories,);
    } else if (_currentIndex == 1) {
      currentPage =  Cartpage(products:widget.products);
    } else {
      currentPage =  AccountWidget(products:widget.products);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: currentPage, 
      bottomNavigationBar: CurvedNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        color: const Color.fromARGB(255, 218, 139, 43),
        items: const [
          Icon(
            Icons.home_filled,
            size: 30,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          Icon(
            Icons.shopping_bag,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.account_circle_rounded,
            size: 30,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
