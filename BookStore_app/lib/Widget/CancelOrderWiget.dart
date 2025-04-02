import 'package:GOSY/AppConfig.dart';
import 'package:GOSY/Page/AccountPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
class CancleOrder extends StatefulWidget {
  final dynamic order; 

  const CancleOrder({super.key, 
    required this.order,
  }) ;

  @override
  _CancleOrderState createState() => _CancleOrderState();
}
  TextEditingController cancelnReasonController = TextEditingController();
  
  
class _CancleOrderState extends State<CancleOrder> {
  
Future<void> updateOrder() async {
  if(cancelnReasonController == "" || cancelnReasonController == null){
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vui lòng nhập lý do hủy')),
    );
    return;
  }
  else
    {try {
      Map<String, dynamic> orderUpdate = Map<String, dynamic>.from(widget.order);
      orderUpdate['cancellationReason'] = cancelnReasonController.text;
      orderUpdate['status'] = 'Đã hủy';
       print('orderUpdate: ${orderUpdate}');
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/Orders/${widget.order?['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderUpdate),
      );
     
      if (response.statusCode == 204) {
        
        await ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hủy đơn thành công!')),
        ); 
       Navigator.pushNamed(context, '/account');
        
      } else {
        var responseBody = await response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hủy đơn thất bại: $responseBody')),
        );
      }
    } catch (error) {
        print('Error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi: $error')),
      );
    }}
  }

  @override
  Widget build(BuildContext context) {
    return 
    Container(
      height: 250,
      width: 270,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bạn có chắc muốn hủy đơn này ?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),),
          SizedBox(height: 8,),
          Text('Lý do hủy: ?',style: TextStyle(fontSize: 16),),
          SizedBox(height: 6,),
          Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextField(
            controller: cancelnReasonController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Lý do hủy',
              border: OutlineInputBorder(),
            ),
            ),
          ),
           Spacer(),
           InkWell(
            onTap: updateOrder,
            child: Container(
              width: 280,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color.fromARGB(255, 165, 76, 76)),
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              child: Center(
                child: Text(
                  'Hủy đơn',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 255, 0, 0),
                  ),
                ),
              ),
            ),
          ),
],
      ),
    );
  }
}
