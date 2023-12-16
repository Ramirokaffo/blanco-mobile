
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';
import 'package:image_to_text/UI/AddProduct/Actions/OnChangeImageTap.dart';
import 'package:image_to_text/UI/AddProduct/Actions/OnDeleteImageTap.dart';

import '../../../DisplayImage/DisplayImage.dart';



Widget oneImageBox(BuildContext context, Product article, int imageIndex) {
  return Material(
    borderRadius: BorderRadius.circular(5),
    elevation: 1,
    child: Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        // border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2))
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplaysImage(image: article.images![imageIndex].imageFile!.path, title: "Image", islocal: true,),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Image.file(File(article.images![imageIndex].imageFile!.path), fit: BoxFit.contain,),
                      ),
                    ),
                    // Expanded(
                    //   flex: 2,
                    //   child: imageActionsWidget(context, article, imageIndex),
                    // )
                  ],
                )
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: (){
                onDeleteImageTap(context, article, imageIndex);
              },
                child: const Icon(Icons.cancel_presentation, color: Colors.red,)),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: (){
                onChangeImageTap(context, article, imageIndex);
              },
                child: const Icon(Icons.edit, color: Colors.green,)),
          ),
        ],
      ),
    ),
  );
}
