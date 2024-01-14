
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';

import '../../StateManager/EditArticlePageState.dart';


class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name!, style: const TextStyle(fontSize: 18),),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      // body: BlocBuilder<EditArticlePageState, bool>(
      //     builder: (BuildContext contxt, state) {
      //       return Container(
      //         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      //         decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(10),
      //             color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1)
      //         ),
      //         child: CustomScrollView(
      //           slivers: [
      //             SliverList(delegate: SliverChildListDelegate(
      //                 [
      //                   const SizedBox(height: 20,),
      //                   Form(
      //                       key: _formKey,
      //                       child: Column(
      //                         children: [
      //                           existingProduct(),
      //                           oneTextFormField(title: "Code *", controller: codeController, hinText: "Entrez ou scannez le code du produit", required: true,
      //                               suffix: IconButton(onPressed: onScanCodeTap, icon: const Icon(Icons.document_scanner)), onTapOutside: onCodeTapOutside,
      //                               onTap: (){_codeIsVerify = false;}),
      //                           oneTextFormField(title: "Nom *", controller: nameController, hinText: "Entrez le nom du produit", required: true, onTapOutside: onNameTapOutside,
      //                               onTap: (){_nameIsVerify = false; onCodeTapOutside(codeController.text);}, suffix: IconButton(onPressed: () async {nameController.text =
      //                               await TextRecognitionService.readTextFromImage(context, title: "Selectionnez le nom du produit");
      //                               setState(() {});}, icon: const Icon(Icons.document_scanner_outlined))),
      //                           oneTextFormField(title: "Marque", controller: brandController, hinText: "Entrez la marque du produit",
      //                               onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}, suffix: IconButton(onPressed: () async {brandController.text =
      //                               await TextRecognitionService.readTextFromImage(context, title: "Selectionnez la marque du produit");
      //                               setState(() {});}, icon: const Icon(Icons.document_scanner_outlined))),
      //                           oneTextFormField(title: "Catégorie *", controller: categoryController, hinText: "Choisissez la catégorie du produit", required: true,
      //                               onTap: (){onArticleCategoryTap(product, categoryController, context); onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}, keyboardType: TextInputType.none,
      //                               suffix: IconButton(onPressed: (){onArticleCategoryTap(product, categoryController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
      //                           oneTextFormField(title: "Rayon *", controller: rayonController, hinText: "Choisissez le rayon du produit", required: true,
      //                               onTap: (){onArticleRayonTap(product, rayonController, context); onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}, keyboardType: TextInputType.none,
      //                               suffix: IconButton(onPressed: (){onArticleRayonTap(product, rayonController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
      //                           oneTextFormField(title: "Gamme", controller: gammeController, hinText: "Choisissez la gamme du produit", required: false,
      //                               onTap: (){onArticleGammeTap(product, gammeController, context); onNameTapOutside(gammeController.text); onCodeTapOutside(codeController.text);}, keyboardType: TextInputType.none,
      //                               suffix: IconButton(onPressed: (){onArticleGammeTap(product, gammeController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
      //                           oneTextFormField(title: "Grammage", controller: grammageController, hinText: "Entrez le grammage du produit", keyboardType: TextInputType.number,
      //                               onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}),
      //                           oneTextFormField(title: "Type de grammage", controller: grammageTypeController, hinText: "Choisissez le type de grammage du produit",
      //                               onTap: (){onProductGrammageTypeTap(product, grammageTypeController, context); onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}, keyboardType: TextInputType.none,
      //                               suffix: IconButton(onPressed: (){onProductGrammageTypeTap(product, grammageTypeController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
      //                           oneTextFormField(title: "Stock *", controller: stockController, hinText: "Début de stock du produit", keyboardType: TextInputType.number, required: true,
      //                               onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}),
      //                           oneTextFormField(title: "Prix unitaire *", controller: unitPriceController, hinText: "Prix unitaire de vente du produit", keyboardType: TextInputType.number, required: true,
      //                               onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}),
      //                           oneTextFormField(title: "Coût unitaire *", controller: unitCoastController, hinText: "Coût unitaire d'achat du produit", keyboardType: TextInputType.number, required: true,
      //                               onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}),
      //                           oneTextFormField(title: "Description", controller: descriptionController, hinText: "Entrez ou scannez la description du produit", maxLines: 10,
      //                               suffix: descriptionSuffix(), onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}),
      //                         ],
      //                       ))
      //                 ]
      //             )),
      //             SliverToBoxAdapter(
      //               child: Container(
      //                 padding: const EdgeInsets.all(15),
      //                 child: const Text("Images", style: TextStyle(fontWeight: FontWeight.bold),),
      //               ),
      //             ),
      //             SliverPadding(
      //               padding: const EdgeInsets.symmetric(horizontal: 10),
      //               sliver: SliverGrid(
      //                 gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      //                   maxCrossAxisExtent: 200.0,
      //                   mainAxisSpacing: 10.0,
      //                   crossAxisSpacing: 5.0,
      //                   childAspectRatio: 0.85,
      //                 ),
      //                 delegate: SliverChildBuilderDelegate(
      //                       (BuildContext context, int index) {
      //                     if (index == product.images!.length) {
      //                       return addImageBox(context, product);
      //                     } else {
      //                       return oneImageBox(context, product, index, onChangeImageTap, onDeleteImageTap);
      //                     }
      //                   },
      //                   childCount: product.images!.length + 1,
      //                 ),
      //               ),
      //             ),
      //             SliverToBoxAdapter(
      //               child: Column(
      //                 children: [
      //                   // _addSaleProductWidget(),
      //                   // const Divider(),
      //                   const SizedBox(height: 10,),
      //                   Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       const Text("Nettoyer le formulaire après envoi"),
      //                       Switch(value: _clearInput, onChanged: (value) {
      //                         setState(() {
      //                           _clearInput = !_clearInput;
      //                         });
      //                       },),
      //                     ],
      //                   )
      //                 ],
      //               ),
      //             ),
      //
      //             const SliverToBoxAdapter(
      //               child: SizedBox(height: 30,),
      //             ),
      //           ],
      //         ),
      //       );}),
    );
  }
}
