import 'package:GOSY/Widget/CategoryWidget.dart';
import 'package:GOSY/Widget/HomeAppBar.dart';
import 'package:GOSY/Widget/ItemWidget.dart';
import 'package:GOSY/Widget/PromoWidget.dart';
import 'package:GOSY/Widget/SearchItemWidget.dart';
import 'package:flutter/material.dart';
 
class ProductHomepage extends StatefulWidget {
  final List<dynamic> products ;
  final List<dynamic> categories ;
  const ProductHomepage({super.key, required this.products,required this.categories});
  @override
  _ProductHomepageState createState() => _ProductHomepageState(); 

}

class _ProductHomepageState extends State<ProductHomepage> {
  
  String? searchFilter;

  @override
  Widget build(BuildContext context) {
  dynamic productPromo = widget.products.firstWhere(
  (pro) => pro['id'] == 5,
  orElse: () => null,
);
    return Scaffold(
        backgroundColor: Colors.white,
        body:SingleChildScrollView(
          child: Column(
          children: [
                    HomeAppBar(),
                    Container(
                      padding: EdgeInsets.only(top: 15),
                      
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: 300,
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Tìm kiếm",
                                      icon: Icon(Icons.search),
                                    ),
                                    onFieldSubmitted: (value) {
                                      setState(() {
                                        searchFilter = value;
                                      });
                                    
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          (searchFilter == null || searchFilter!.isEmpty) ? SizedBox(height: 1,) : SizedBox(height: 40,),
                         
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: SizedBox(height: 150,child: Categorywidget(categories: widget.categories)),
                          ),
                          (searchFilter == null || searchFilter!.isEmpty) ? Promowidget(product: productPromo,) : SizedBox(height: 1,),
                          
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            child: Text(
                              "Bán chạy",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 221, 143, 33),
                              ),
                            ),
                          ),
                          (searchFilter == null || searchFilter!.isEmpty)
                            ? ItemWidget(products: widget.products,)
                            : SizedBox(height: 700, child: SearchItemWidget(filter: searchFilter, products: widget.products,)),
                        ],
                      ),
                    ),
                  ],
              
          ),
          ),
  
     );
  }
}
