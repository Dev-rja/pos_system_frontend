import 'package:flutter/material.dart';
import '../List_Manager.dart';


class HistoryContentD extends StatelessWidget {
  const HistoryContentD({super.key});



  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.all(50),
      child: Column(
        children:[
          Container(
            height: 800,
            width: 1700,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 193, 225, 153,),
            ),
            child: TransHistoryBuilder(),
          ),

          SizedBox(height: 10,),

        ],
      ),
    );
  }
}
