
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CheckOutAppBar extends StatelessWidget {
  const CheckOutAppBar({super.key});

  @override
  Widget build(BuildContext context){
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(25),
        child: Row(
          children: [
             InkWell(
              onTap: () {
               Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back, 
                size: 30,
                color: Color.fromARGB(255, 194, 122, 35)),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                          text: 'Thanh toán',
                          style: GoogleFonts.portLligatSans(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 194, 122, 35),
                          ),
                        ),
                    ),
                   
                  ],
                ),
              ),
              Spacer(),
               Icon(Icons.money_off,
                    size: 33,
                    color: Color.fromARGB(255, 194, 122, 35),
                  ),
          ]
         ),
    );
  }
}