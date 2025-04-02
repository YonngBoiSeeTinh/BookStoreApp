import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
     margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(5),
      height: 60,
      child: Row(
        children: [
          Icon(Icons.sort,
          size: 40,
          color: const Color.fromARGB(255, 219, 121, 9)),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child:  RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                    text: 'Bo',
                    style: GoogleFonts.portLligatSans(
                      
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: const Color.fromARGB(255, 219, 121, 9),
                    ),
                    children: [
                      TextSpan(
                        text: 'ok S',
                        style: TextStyle(color: const Color.fromARGB(255, 186, 186, 186), fontSize: 30),
                      ),
                      TextSpan(
                        text: 'hop',
                        style: TextStyle(color: const Color.fromARGB(255, 219, 121, 9), fontSize: 30),
                      ),
                    ]),
              )
          ),
          Spacer(),
          
        ],
      ),
    );
  }
}