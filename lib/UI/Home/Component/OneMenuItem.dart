
import 'package:flutter/material.dart';

class OneMenuItem extends StatelessWidget {
  final String titleText;
  final IconData leadingIcon;
  final Function onTap;
  const OneMenuItem({Key? key, required this.titleText, required this.leadingIcon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onTap();
      },
      child: ListTile(
        iconColor: Colors.white,
        textColor: Colors.white,
        title: Text(titleText),
        leading: Icon(leadingIcon),
        trailing: const Icon(Icons.arrow_forward_ios_outlined),
      ),
    );
  }
}
