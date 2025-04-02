import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/Page/AccountPage.dart';
import 'package:GOSY/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
class ChoosePromoWidet extends StatefulWidget {
  final void Function(dynamic) setPromotion;
  final void Function(dynamic) canclePromotion;
  final dynamic selectedPromo;
  final double totalPrice;
  const ChoosePromoWidet({super.key, 
    required this.setPromotion,
    required this.selectedPromo,
    required this.totalPrice,
    required this.canclePromotion,
  }) ;

  @override
  _ChoosePromoWidetState createState() => _ChoosePromoWidetState();
}

  
  
class _ChoosePromoWidetState extends State<ChoosePromoWidet> {

  List<dynamic> promotions = [];
  bool isLoading = false;
  void initState() {
    super.initState();
    fetchPromotion();
   
  }
  Future<void> fetchPromotion() async {
    setState(() {
      isLoading = true; 
    });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Promotions'));
      if (response.statusCode == 200) {
       final data = jsonDecode(response.body);
        final currentDate = DateTime.now();
        setState(() {
          promotions = data.where((promotion) {
            final endAt = DateTime.parse(promotion['endAt']);
            return endAt.isAfter(currentDate);
          }).toList();
        });
         addMemberPromo();
        print('promotions ${promotions}');
      } else {
        print('Failed to load promotions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching promotions: $e');
    } finally {
      setState(() {
        isLoading = false; // Kết thúc tải dữ liệu
      });
    }
  }
  int idSelected = 0 ;
  void addMemberPromo() async{
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await  userProvider.loadSavedLogin();
      dynamic user = userProvider.user;
      dynamic memberPromo;
      if(user != null ){
        if (  user['role'] != 1 && user['role']!=2  && user['role'] != 3 && user['role']!=4){
          final today = DateTime.now();
        final tomorrow = today.add(Duration(days: 1));
        if(user['role'] == 5 ){
          memberPromo = {
            'id' : 99999,
            'name': 'Thành viên Bạc',
            'value': 7,
            'minPrice': 100000,
            'maxValue': 300000,
            'code': 'memberPromo',
          };
        }
        else if(user['role'] == 6){
          memberPromo = {
            'id' : 99999,
            'name': 'Thành viên Vàng',
            'value': 10,
            'minPrice': 100000,
            'maxValue': 350000,
            'code': 'memberPromo',
          };
        }
        else if(user['role'] == 7){
          memberPromo = {
            'id' : 99999,
            'name': 'Thành viên Kim cương',
            'value': 15,
            'minPrice': 100000,
            'maxValue': 400000,
            'code': 'memberPromo',
          };
        }
        setState(() {
          promotions.add(memberPromo);
        });
        }
        
      }
      
  }
  @override
  Widget build(BuildContext context) {
    return isLoading
      ? const Center(child: CircularProgressIndicator())
      : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Danh sách khuyến mãi: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                Expanded(
                  child: ListView.builder(
                    itemCount: promotions.length,
                    itemBuilder: (context, index){
                      final promo = promotions[index];
                      bool isAvailbe = (widget.totalPrice >= promo?['minPrice']);
                      return Container(
                        margin:EdgeInsets.symmetric( vertical: 5) ,
                        padding: EdgeInsets.only(bottom: 5, top: 5, left: 10),
                        decoration: BoxDecoration(
                          color:isAvailbe?
                           const Color.fromARGB(255, 255, 255, 255):
                           const Color.fromARGB(177, 148, 148, 148),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                             color:  ( widget.selectedPromo != null &&  widget.selectedPromo['id'] == promo['id']) ?
                              const Color.fromARGB(255, 98, 42, 182):
                              const Color.fromARGB(255, 97, 97, 97)
                            )
                        ),
                       
                        child: Row(
                          children: [
                            InkWell(
                              onTap: (){
                                if(isAvailbe){
                                  widget.setPromotion(promo); 
                                  Navigator.pop(context);
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đơn hàng chưa đạt đủ điều kiện !')),
                                  );
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  !isAvailbe ?
                                  Text( 'Chưa đủ điều kiện' ,
                                    style:TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 93, 93, 93),
                                    )
                                  ):SizedBox(),
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                     children: [
                                       Text('${promo['name']}: ',
                                          maxLines: 2, 
                                          overflow: TextOverflow.ellipsis,  
                                          style:TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color:isAvailbe ? Color(0xFF4C53A5) : const Color.fromARGB(255, 139, 139, 139),
                                          )
                                        ),
                                        Text('- ${promo['value']}%',
                                          maxLines: 2, 
                                          overflow: TextOverflow.ellipsis,  
                                          style:TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color:isAvailbe ? Color(0xFF4C53A5) : const Color.fromARGB(255, 165, 165, 165),
                                          )
                                        ),
                                     ],
                                   ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tối thiểu: ${NumberFormat('###,###').format(promo['minPrice'])} VNĐ',
                                          style:TextStyle(
                                              fontSize: 16,
                                              color:isAvailbe ? Color.fromARGB(255, 59, 59, 59) : const Color.fromARGB(255, 89, 88, 88),
                                            )
                                          ),
                                         Text(
                                          'Giảm tối đa: ${NumberFormat('###,###').format(promo['maxValue'])} VNĐ',
                                          style:TextStyle(
                                              fontSize: 15,
                                              color: isAvailbe ? Color.fromARGB(255, 59, 59, 59) : const Color.fromARGB(255, 165, 165, 165),
                                            )
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                             Spacer(),
                            widget.selectedPromo != null && widget.selectedPromo['id'] == promo['id'] ?
                            Column(children: [
                              InkWell(
                                onTap: (){
                                  widget.canclePromotion(null);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 6),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4C53A5),
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Text('Hủy', style:TextStyle(color: Colors.white),)
                                ),
                              )
                            ],) : SizedBox()
                          ],
                        ),
                      );
                    }),
                )
                ],
            );
  }
}
