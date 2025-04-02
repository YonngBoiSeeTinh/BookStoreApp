import 'package:flutter/material.dart';

import '../Widget/AdminAppBar.dart';
import 'CategoryManager.dart';
import 'Dashboard.dart';
import 'OrderManager.dart';
import 'ProductManager.dart';
import 'PromotionManager.dart';
import 'UserManager.dart';

class Homepage extends StatefulWidget {
  
  final int index;
  const Homepage({super.key, required this.index});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
 
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index; 
  }

  bool _isMenuOpen = false; // Trạng thái của sidebar

  final List<Widget> _pages = [
    Center(child: DashboardPage()),
    Center(child: ProductManager()),
    Center(child: OrderManager()),
    Center(child: UserManager()),
    Center(child: CategoryManager()),
    Center(child: PromotionManager()),
  ];
  Widget _menuTitle(String title, IconData icon, int index){
    return Container(
      decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                      color: Colors.grey, 
                      width: 1.0, 
                      ),
                    )
                  ),
      margin: EdgeInsets.symmetric(vertical: 10),
     
      child: ListTile(
         leading: Icon(icon, color: Colors.white),
          title: Text(title, style: TextStyle(color: Colors.white)),
          onTap: () {
            setState(() {
              _currentIndex = index;
              _isMenuOpen = false;
            });
          },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AdminAppBar(),
          // Hiển thị trang hiện tại
          Padding(
            padding: const EdgeInsets.only(top:70),
            child: _pages[_currentIndex],
          ),
          // Sidebar động
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _isMenuOpen ? 250 : 0, // Điều chỉnh độ rộng sidebar
            color: Color.fromARGB(255, 88, 96, 183),
            child: _isMenuOpen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 70), // Khoảng cách từ trên
                      _menuTitle("Trang chủ",Icons.dashboard,0),
                      _menuTitle("Quản lý sản phẩm",Icons.shopping_cart,1),
                      _menuTitle("Quản lý đơn hàng",Icons.shopping_bag,2),
                      _menuTitle("Quản lý người dùng",Icons.contact_page,3),
                      _menuTitle("Quản lý danh mục",Icons.category,4),
                      _menuTitle("Quản lý khuyến mãi",Icons.money,5),
                    ],
                  )
                : SizedBox.shrink(), // Nếu menu ẩn, không hiển thị gì
          ),
          // Nút mở/đóng sidebar
          Positioned(
            top: 10,
            left: 8,
            child: _isMenuOpen
                ? Padding(
                    padding: const EdgeInsets.only(top:12),
                  child: Row(
                        children: [
                          Text("Shop App Manager", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          IconButton(
                            icon: Icon(Icons.close, color: const Color.fromARGB(255, 255, 255, 255), size: 30,),
                            onPressed: () {
                              setState(() {
                                _isMenuOpen = !_isMenuOpen; 
                              });
                            },
                          ),
                        ],
                      ),
                )
                : Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: IconButton(
                      icon: Icon(Icons.menu, color: Color.fromARGB(255, 255, 255, 255), size: 38,),
                      onPressed: () {
                        setState(() {
                          _isMenuOpen = !_isMenuOpen; // Đảo trạng thái sidebar
                        });
                      },
                    ),
                ),
          ),
        ],
      ),
    );
  }
}
