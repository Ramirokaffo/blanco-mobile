import 'package:flutter/material.dart';

import '../UI/ConstantFile.dart';


Future showTransparentUniversalFooter(List<Widget> buttons, BuildContext context, {Color backgroundColor = Colors.white, String? title, double? height}) async {
  await showModalBottomSheet(
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),),
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Container(
          height: height?? MediaQuery.of(context).size.height * 2 / 4,
          decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20))),
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: IconButton(
                        color: Colors.red,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: themeColor,
                          shadows: [Shadow(color: themeColor, offset: Offset(0.1, 0.8), blurRadius: 1)],
                        )),
                  ),
                  Expanded(
                      flex: 8,
                      child: title != null? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FittedBox(
                            fit: BoxFit.fill,
                            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), textAlign: TextAlign.center,)),
                      ): const SizedBox())
                ],
              ),
            ] + [const Divider(color: themeColor,)]
                + buttons,
          ),
        );
      });
}