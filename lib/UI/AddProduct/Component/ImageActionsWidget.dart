
import 'package:flutter/material.dart';

import '../../../DATA/DataClass/Product.dart';
import '../Actions/OnChangeImageTap.dart';
import '../Actions/OnDeleteImageTap.dart';


Widget imageActionsWidget(BuildContext context, Product article, int imageIndex) {
  return Container(
    margin: const EdgeInsets.all(2),
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(5)
    ),
    child: Column(
      children: [
        // Divider(),
        Container(
          decoration: const BoxDecoration(
            // border: Border.all(color: Colors.black.withOpacity(0.05))
          ),
          padding: const EdgeInsets.all(5),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    onChangeImageTap(context, article, imageIndex);
                  },
                  child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: Theme.of(context).colorScheme.inversePrimary,),
                        Text("Editer", style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                      ]),
                ),
                const VerticalDivider(),
                InkWell(
                  onTap: () {
                    onDeleteImageTap(context, article, imageIndex);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.close, size: 18, color: Theme.of(context).colorScheme.inversePrimary),
                      Text("Suppr.", style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        // InkWell(
        // onTap: () {
        //   if (!article.images![imageIndex].isPrincipal!) {
        //     onImageTypeTap(context, article, imageIndex);
        //   }
        // },
        //   child: Text(article.images![imageIndex].isPrincipal!? "Image principale": "Image sécondaire",
        //     textAlign: TextAlign.center,),
        // ),
      ],
    ),
  );
}