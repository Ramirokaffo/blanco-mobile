
import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../Actions/OnAddImageTap.dart';

Widget addImageBox(BuildContext context, Product article) {
  return Material(
    borderRadius: BorderRadius.circular(5),
    elevation: 1,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 120,
              height: 50,
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: (){
                    onAddImageTap(context, article);
                  },
                      icon: const Icon(Icons.add_a_photo, size: 40,)),
                  // Visibility(
                  //   visible: !article.images!.any((ArticleImage articleImage) => articleImage.isVideo!),
                  //   child: IconButton(onPressed: (){
                  //     onAddImageTap(context, article, isVideo: true);
                  //   },
                  //       icon: const Icon(Icons.video_camera_back_sharp, size: 40)),
                  // )
                ],
              ),
            ),
          )
        ],
      ),
    ),
  );
}
