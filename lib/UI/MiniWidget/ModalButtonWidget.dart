
import 'package:flutter/material.dart';

Widget modalButtonWidget({required String title, required Function onTap, IconData? icon = Icons.circle_outlined}) {
  return InkWell(
    onTap: (){
      onTap();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10,),
              Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15,), softWrap: true, overflow: TextOverflow.ellipsis,),
            ],
          ),
          const Icon(Icons.arrow_forward_ios_outlined)
        ],
      ),
    ),
  );
}