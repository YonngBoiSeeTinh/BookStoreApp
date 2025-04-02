import 'dart:typed_data';
import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/Page/ProductDetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Promowidget extends StatefulWidget {
   Map<String, dynamic>? product;
   Promowidget({super.key, required this.product});
  @override
  _PromowidgetState createState() => _PromowidgetState();
}

class _PromowidgetState extends State<Promowidget> {
 
  @override
  void initState() {
    super.initState();
    
  }

    @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Color.fromARGB(255, 106, 107, 122),
          ),
        ],
      ),
      child: widget.product == null
              ?  Container(
                  width: 380,
                  height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                )
              : buildPromoContent(context),
    );
  }

  Widget buildPromoContent(BuildContext context) {

    return Stack(
      children: [
        // Ảnh nền
        Container(
          width: 380,
          height: 230,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage('assets/banner.jpg'),
              fit: BoxFit.cover, // Giúp ảnh lấp đầy container
            ),
          ),
        ),
        // Chữ nổi
        Positioned(
          top: 170,
          left: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        product:  widget.product,
                      ), 
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFF4C53A5), // Màu viền
                      width: 2, // Độ dày viền
                    ),
                  ),
                ),
                child: const Text(
                  'Mua ngay',
                  style: TextStyle(
                    color: Color(0xFF4C53A5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
