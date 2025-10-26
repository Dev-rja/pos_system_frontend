import 'package:flutter/material.dart';
import '../List_Manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';


class HistoryContentD extends StatelessWidget {
  const HistoryContentD({super.key});



  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.all(50),
      child: Column(
        children:[
          Container(
            height: 700,
            width: 1700,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 193, 225, 153,),
            ),
            child: TransHistoryBuilder(),
          ),

          SizedBox(height: 10,),

          Container(
            height: 150,
            width: 1500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromRGBO(0, 113, 80, 1),
            )
          ),
        ],
      ),
    );
  }
}
