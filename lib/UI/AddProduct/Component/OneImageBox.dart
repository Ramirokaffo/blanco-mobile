
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../../../DisplayImage/DisplayImage.dart';



Widget oneImageBox(BuildContext context, Product article, int imageIndex,
    void Function(BuildContext context, Product article, int imageIndex) onChangeImageTap,
    void Function(BuildContext context, Product article, int imageIndex) onDeleteImageTap,
{bool isLocalImage = true}) {
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
                      builder: (context) => DisplaysImage(image: isLocalImage? article.images![imageIndex].imageFile!.path: article.images![imageIndex].url!, title: "Image", islocal: isLocalImage,),
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
                        child: isLocalImage? Image.file(File(article.images![imageIndex].imageFile!.path), fit: BoxFit.contain,):
                        Image.network(article.images![imageIndex].url!,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
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
            child: Visibility(
              visible: isLocalImage,
              child:
              InkWell(
                onTap: (){
                  onChangeImageTap(context, article, imageIndex);
                },
                  child: const Icon(Icons.edit, color: Colors.green,)),
            ),
          ),
        ],
      ),
    ),
  );
}
