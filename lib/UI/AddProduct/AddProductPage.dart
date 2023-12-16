import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_to_text/DATA/DataClass/GrammageType.dart';
import 'package:image_to_text/DATA/DataClass/Rayon.dart';
import 'package:image_to_text/LocalBdManager/LocalBdManager.dart';
import 'package:image_to_text/MiniFunction/GlobalTestConnectivity.dart';
import 'package:image_to_text/UI/AddProduct/Actions/OneProductCategoryTap.dart';
import 'package:image_to_text/UI/AddProduct/Actions/onPorductGammeTap.dart';
import 'package:image_to_text/UI/MiniWidget/UniversalSnackBar.dart';

import '../../DATA/DataClass/Category.dart';
import '../../DATA/DataClass/Gamme.dart';
import '../../DATA/DataClass/Product.dart';
import '../../StateManager/AddArticlePageState.dart';
import '../../StateManager/SendDataProgressBarState.dart';
import '../ProductDetails/ProductDetailsPage.dart';
import 'Actions/OnProductGrammageTypeTap.dart';
import 'Actions/OneProductRayonTap.dart';
import 'Component/AddImageBox.dart';
import 'Component/OneImageBox.dart';
import '../../AppService/BarCodeService.dart';
import '../../AppService/TextRecognitionService.dart';

class AddProductPage extends StatefulWidget {
  final bool? isInventoryMode;
  const AddProductPage({Key? key, this.isInventoryMode}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {

  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController grammageController = TextEditingController();
  TextEditingController grammageTypeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController unitPriceController = TextEditingController();
  TextEditingController rayonController = TextEditingController();
  TextEditingController gammeController = TextEditingController();
  Product product = Product(images: []);
  final _formKey = GlobalKey<FormState>();
  bool _codeExist = false;
  bool _nameExist = false;
  bool _codeIsVerify = true;
  bool _nameIsVerify = true;
  bool _clearInput = true;
  late int _existingProductId;


  Future onCodeTapOutside(String value) async {
    if (_codeIsVerify) return;
    await Product.makeGetRequest("/get_product_by_code/$value").then((value) {
      print(value);
      if (value != null) {
        _existingProductId = value["id"];
        setState(() {
          _codeExist = true;
        });
      } else {
        if (_codeExist) {
          setState(() {
            _codeExist = false;
          });
        }
      }
      _codeIsVerify = true;
    }).onError((error, stackTrace) {
      if (_codeExist) {
        _codeExist = false;
      }
      _codeIsVerify = true;
    });
  }

  Future onNameTapOutside(String value) async {
    if (_nameIsVerify) return;

    await Product.makeGetRequest("/get_product_by_name/$value").then((value) {
      print(value);
      if (value != null) {
        _existingProductId = value["id"];
        setState(() {
          _nameExist = true;
        });
      } else {
        if (_nameExist) {
          setState(() {
            _nameExist = false;
          });
        }
      }
      _nameIsVerify = true;
    }).onError((error, stackTrace) {
      if (_nameExist) {
        _nameExist = false;
      }
      _nameIsVerify = true;
    });

  }

  Widget oneTextFormField({required String title,
    required TextEditingController controller,
    Widget? suffix, String? hinText, int? maxLines = 1,
    TextInputType? keyboardType = TextInputType.text, Function? onTap,
    bool required = false, Function(String value)? onTapOutside
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10,),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
        const SizedBox(height: 10,),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
          ),
          child: TextFormField(
            onTap: () => (onTap?? (){})(),
            onTapOutside: (event) {
              if (onTapOutside != null) {
                onTapOutside(controller.text);
              }
            },
            validator: !required? (value) => null:  (value){
              if (value == null || value.isEmpty) {
                return "Ce champs est obligatoire !";
              }
              return null;
            },
            maxLines: maxLines,
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
                border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              hintText: hinText,
              suffixIcon: suffix,
            ),
          ),
        ),
        const SizedBox(height: 10,),

      ],
    );
  }

  Widget descriptionSuffix() {
    return Column(
      children: [
        IconButton(onPressed: () async {
          descriptionController.text =  await TextRecognitionService.readTextFromImage(context, checkByDefault: true);
          setState(() {
          });
        }, icon: const Icon(Icons.document_scanner_outlined), tooltip: "Scanner du texte",),
        Visibility(
          visible: descriptionController.text.isNotEmpty,
            child: IconButton(onPressed: () async {
          descriptionController.text = "${descriptionController.text}\n\n${await TextRecognitionService.readTextFromImage(context)}";
          setState(() {});
        }, icon: const Icon(Icons.add_circle_outline_outlined), tooltip: "Ajouter du texte à l'existant",)),
        Visibility(
          visible: descriptionController.text.isNotEmpty,
          child: IconButton(onPressed: () async {
            descriptionController.text =  "";
            setState(() {
            });
          }, icon: const Icon(Icons.cancel_outlined), tooltip: "Tout effacer",),
        ),

      ],
    );
  }


  void onScanDescriptionTap() async {
    descriptionController.text =  await TextRecognitionService.readTextFromImage(context);
    setState(() {
    });
  }

  void onScanCodeTap() async {
    codeController.text = await BarCodeService.scanBarCode(context: context);
    setState(() {
    });
  }

  void onSendDataTap() async {
    if (!_nameIsVerify) {
      await onNameTapOutside(nameController.text);
    } else if (!_codeIsVerify) {
      await onCodeTapOutside(codeController.text);
    }
    if (_codeExist || _nameExist) {
      showUniversalSnackBar(context: context, message: "Un produit existe déjà avec ce ${_codeExist? 'code': ''} ${_nameExist? 'nom': ''}");
      return;
    }
    if (!_formKey.currentState!.validate()) {
    return;
    }
    product.name = nameController.text;
    product.stock = int.tryParse(stockController.text);
    product.brand = brandController.text;
    product.description = descriptionController.text;
    product.unitPrice = double.tryParse(unitPriceController.text);
    product.code = codeController.text;
    product.grammage = double.tryParse(grammageController.text);
    if (categoryController.text.isNotEmpty) {
      product.categoryId = Category.allCategoryList
        .firstWhere((Category category) =>
    category.name.toString() == categoryController.text)
        .id;
    }
    if (gammeController.text.isNotEmpty) {
      product.gammeId = Gamme.allGammeList
        .firstWhere((Gamme gamme) =>
      gamme.name.toString() == gammeController.text)
        .id;
    }
    if (rayonController.text.isNotEmpty) {
      product.rayonId = Rayon.allRayonList
        .firstWhere((Rayon rayon) =>
    rayon.name.toString() == rayonController.text)
        .id;
    }
    if (grammageTypeController.text.isNotEmpty) {
      product.grammageTypeId = GrammageType.allGrammageTypeList
        .firstWhere((GrammageType grammageType) =>
      grammageType.name.toString() == grammageTypeController.text)
        .id;
    }
    await product.createProduct(await LocalBdManager.localBdSelectSetting("serverUri"),
      progressCallBack: (progress) => refreshSendDataProgressBarState(context, progress), inventoryMode: (widget.isInventoryMode?? false)? 1: 0).then((value) {
      if (_clearInput) {
        nameController.text = "";
        codeController.text = "";
        brandController.text = "";
        categoryController.text = "";
        grammageController.text = "";
        unitPriceController.text = "";
        grammageTypeController.text = "";
        descriptionController.text = "";
        stockController.text = "";
        rayonController.text = "";
        gammeController.text = "";
        product = Product(images: []);
        setState(() {

        });
      }

      showUniversalSnackBar(context: context, message: "Produit enregistré avec succès !");
    }).onError((error, stackTrace) {
      showUniversalSnackBar(context: context, message: "Une erreur s'est produite !");
    });
    _nameIsVerify = false;
    _codeIsVerify = false;
  }

  Widget existingProduct() {
    return Visibility(
        visible: _codeExist || _nameExist,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
          ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  child: Icon(Icons.info, color: Colors.red),
                ),
                Text("Ce ${_codeExist? 'code': ''} ${_nameExist? 'nom': ''} est déjà utilisé", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductDetailsPage(productId: _existingProductId),));
                  },
                  child: const Text("Détails", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                )
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text("Ajouter un produit"),
        actions: [IconButton(onPressed: (){globalConnectivityTest(context);}, icon: const Icon(Icons.qr_code),
            style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2))))],
        bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, (widget.isInventoryMode?? false)? 30: 0),
            child: Visibility(
              visible: widget.isInventoryMode?? false,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer
                ),
                child: const Text("Vous êtes en mode inventaire", textAlign: TextAlign.center,),
              ),
            )),
      ),
      bottomSheet: SizedBox(
        height: 10,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            BlocBuilder<SendDataProgressBarState, double>(
                builder: (BuildContext contxt, state) {
                  return ![0.0, 1.0].contains(state)
                      ? LinearProgressIndicator(minHeight: 7, value: state)
                      : const SizedBox(
                    height: 0.01,
                    width: 0.01,
                  );
                }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: InkWell(
          onTap: onSendDataTap,
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
            ),
              child: const Text("Envoyer", style: TextStyle(fontWeight: FontWeight.bold),)),
        ),
      ),
      body: BlocBuilder<AddArticlePageState, bool>(
          builder: (BuildContext contxt, state) {
            return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1)
        ),
        child: CustomScrollView(
          slivers: [
            SliverList(delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 20,),
                Form(
                  key: _formKey,
                    child: Column(
                  children: [
                    existingProduct(),
                    oneTextFormField(title: "Code", controller: codeController, hinText: "Entrez ou scannez le code du produit", required: true,
                        suffix: IconButton(onPressed: onScanCodeTap, icon: const Icon(Icons.document_scanner)), onTapOutside: onCodeTapOutside,
                    onTap: (){_codeIsVerify = false;}),
                    oneTextFormField(title: "Nom", controller: nameController, hinText: "Entrez le nom du produit", required: true, onTapOutside: onNameTapOutside,
                        onTap: (){_nameIsVerify = false; onCodeTapOutside(codeController.text);}, suffix: IconButton(onPressed: () async {nameController.text =
                        await TextRecognitionService.readTextFromImage(context, title: "Selectionnez le nom du produit");
                        setState(() {});}, icon: const Icon(Icons.document_scanner_outlined))),
                    oneTextFormField(title: "Marque", controller: brandController, hinText: "Entrez la marque du produit",
                        onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}, suffix: IconButton(onPressed: () async {brandController.text =
                        await TextRecognitionService.readTextFromImage(context, title: "Selectionnez la marque du produit");
                        setState(() {});}, icon: const Icon(Icons.document_scanner_outlined))),
                    oneTextFormField(title: "Catégorie", controller: categoryController, hinText: "Choisissez la catégorie du produit", required: true,
                        onTap: (){onArticleCategoryTap(product, categoryController, context); onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}, keyboardType: TextInputType.none,
                        suffix: IconButton(onPressed: (){onArticleCategoryTap(product, categoryController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
                    oneTextFormField(title: "Rayon", controller: rayonController, hinText: "Choisissez le rayon du produit", required: true,
                        onTap: (){onArticleRayonTap(product, rayonController, context); onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}, keyboardType: TextInputType.none,
                        suffix: IconButton(onPressed: (){onArticleRayonTap(product, rayonController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
                    oneTextFormField(title: "Gamme", controller: gammeController, hinText: "Choisissez la gamme du produit", required: false,
                        onTap: (){onArticleGammeTap(product, gammeController, context); onNameTapOutside(gammeController.text); onCodeTapOutside(codeController.text);}, keyboardType: TextInputType.none,
                        suffix: IconButton(onPressed: (){onArticleGammeTap(product, gammeController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
                    oneTextFormField(title: "Grammage", controller: grammageController, hinText: "Entrez le grammage du produit", keyboardType: TextInputType.number,
                    onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}),
                    oneTextFormField(title: "Type de grammage", controller: grammageTypeController, hinText: "Choisissez le type de grammage du produit",
                        onTap: (){onProductGrammageTypeTap(product, grammageTypeController, context); onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}, keyboardType: TextInputType.none,
                        suffix: IconButton(onPressed: (){onProductGrammageTypeTap(product, grammageTypeController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
                    oneTextFormField(title: "Stock", controller: stockController, hinText: "Début de stock du produit", keyboardType: TextInputType.number, required: true,
                    onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}),
                    oneTextFormField(title: "Prix unitaire", controller: unitPriceController, hinText: "Prix unitaire de vente du produit", keyboardType: TextInputType.number, required: true,
                        onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}),
                    oneTextFormField(title: "Description", controller: descriptionController, hinText: "Entrez ou scannez la description du produit", maxLines: 10,
                        suffix: descriptionSuffix(), onTap: (){onNameTapOutside(nameController.text); onCodeTapOutside(codeController.text);}),
                  ],
                ))
              ]
            )),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(15),
                child: const Text("Images", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.0,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 5.0,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    if (index == product.images!.length) {
                      return addImageBox(context, product);
                    } else {
                      return oneImageBox(context, product, index);
                    }
                  },
                  childCount: product.images!.length + 1,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // _addSaleProductWidget(),
                  // const Divider(),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Nettoyer le formulaire après envoi"),
                      Switch(value: _clearInput, onChanged: (value) {
                        setState(() {
                          _clearInput = !_clearInput;
                        });
                      },),
                    ],
                  )
                ],
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 30,),
            ),
          ],
        ),
      );}),
    );
  }
}
