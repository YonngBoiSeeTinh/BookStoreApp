import 'package:clippy_flutter/arc.dart';
import 'package:flutter/material.dart';

import '../Widget/ItemAppBarWidget.dart';
import '../Widget/ItemBottomAppBar.dart';


class ProductDetailPage extends StatefulWidget {
  @override
  final int id;

  const ProductDetailPage({super.key, required this.id});
  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDECF2),
      body: ListView(
        children: [
          Itemappbarwidget(),
          _buildProductImage(),
          _buildProductDetails(),
        ],
      ),
      bottomNavigationBar: ItemBottomNavBar(),
    );
  }

  Widget _buildProductImage() {
    return Arc(
      height: 30,
      edge: Edge.BOTTOM,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Image.asset(
            "image/1.png",
            height: 300,
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Product name",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C53A5),
                ),
              ),
              Text(
                "\$250",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C53A5),
                ),
              ),
            ],
          ),
        ),
        _buildColorSizeOptions(),
       
        _buildDescription(),
       
      ],
    );
  }

  Widget _buildColorSizeOptions() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "Color size:",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C53A5),
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: List.generate(
              8,
              (index) => Container(
                height: 30,
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color.fromARGB(255, 146, 148, 175),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    "White - M",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF4C53A5),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDescription() {
  return Column(
    children: [
       Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child:Row(
            children: [
              Text(
                "Sold: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C53A5),
                ),
              ),
              Text( "0",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.normal,
                  color: Color.fromARGB(255, 129, 136, 208),
                ),
              ),
            ],
          ),   
      ),
        Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child:Row(
            children: [
              Text(
                "Sold: ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C53A5),
                ),
              ),
              Text( "0",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.normal,
                  color: Color.fromARGB(255, 129, 136, 208),
                ),
              ),
            ],
          ),   
      ),
      Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Description: ",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C53A5),
              ),
            ),
            TextSpan(
              text:
                  "description about product description about product description about product description about product description about product",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.normal,
                color: Color.fromARGB(255, 129, 136, 208),
              ),
            ),
          ],
        ),
        maxLines: 3, // Giới hạn dòng (tùy chọn)
        overflow: TextOverflow.ellipsis, // Dấu "..." khi bị cắt
      ),
      ),
    ],
  );


  }
}
