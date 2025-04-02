import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:convert';

class Categorywidget extends StatefulWidget {
  final List<dynamic> categories;
  const Categorywidget({super.key, required this.categories});

  @override
  _CategorywidgettState createState() => _CategorywidgettState();
}

class _CategorywidgettState extends State<Categorywidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.categories.length,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(), // Cuộn mượt hơn
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        final imageBase64 = category['image'];
        Uint8List? imageBytes;
        if (imageBase64 != null && imageBase64 is String) {
          try {
            imageBytes = Base64Decoder().convert(imageBase64);
          } catch (e) {
            print("Invalid image data at index $index: $e");
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orangeAccent, // Viền màu cam
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(2, 4), // Hiệu ứng bóng
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hình ảnh nền
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        width: 175,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 160,
                        height: 120,
                        color: Colors.blueGrey,
                        child: Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
              ),

              Positioned(
                bottom: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
