import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_to_text/DATA/DataClass/GrammageType.dart';
import 'package:image_to_text/DATA/DataClass/Rayon.dart';
import 'package:image_to_text/MiniFunction/GlobalTestConnectivity.dart';
import 'package:image_to_text/UI/AddProduct/Actions/OneProductCategoryTap.dart';
import 'package:image_to_text/UI/AddProduct/Actions/onPorductGammeTap.dart';
import 'package:image_to_text/UI/MiniWidget/UniversalSnackBar.dart';
import 'package:image_to_text/UI/MiniWidget/showSimpleDialog.dart';

import '../../DATA/DataClass/Category.dart';
import '../../DATA/DataClass/Gamme.dart';
import '../../DATA/DataClass/Product.dart';
import '../../StateManager/AddArticlePageState.dart';
import '../../StateManager/SendDataProgressBarState.dart';
import '../ProductDetails/ProductDetailsPage.dart';
import 'Actions/OnChangeImageTap.dart';
import 'Actions/OnDeleteImageTap.dart';
import 'Actions/OnProductGrammageTypeTap.dart';
import 'Actions/OneProductRayonTap.dart';
import 'Component/AddImageBox.dart';
import 'Component/OneImageBox.dart';
import '../../AppService/BarCodeService.dart';
import '../../AppService/TextRecognitionService.dart';

class AddProductPage extends StatefulWidget {
  final bool? isInventoryMode;
  final Product? product;
  const AddProductPage({Key? key, this.isInventoryMode, this.product}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _grammageController = TextEditingController();
  final TextEditingController _grammageTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _unitCoastController = TextEditingController();
  final TextEditingController _rayonController = TextEditingController();
  final TextEditingController _gammeController = TextEditingController();
  Product _product = Product(images: []);
  final _formKey = GlobalKey<FormState>();
  bool _codeExist = false;
  bool _nameExist = false;
  bool _codeIsVerify = true;
  bool _nameIsVerify = true;
  bool _clearInput = true;
  bool _isSending = false;
  late int _existingProductId;
  CancelToken _cancelToken = CancelToken();


  Future _onCodeTapOutside(String value) async {
    if (_codeIsVerify || widget.product != null) return;
    await Product.makeGetRequest("/get_product_by_code/$value").then((value) {
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

  Future _onNameTapOutside(String value) async {
    if (_nameIsVerify || widget.product != null) return;

    await Product.makeGetRequest("/get_product_by_name/$value").then((value) {
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

  Widget _oneTextFormField({required String title,
    required TextEditingController controller,
    Widget? suffix, String? hinText, int? maxLines = 1,
    TextInputType? keyboardType = TextInputType.text, Function? onTap,
    bool required = false, Function(String value)? onTapOutside, bool disabled = false
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
            enabled: !disabled,
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

  Widget _descriptionSuffix() {
    return Column(
      children: [
        IconButton(onPressed: () async {
          _descriptionController.text =  await TextRecognitionService.readTextFromImage(context, checkByDefault: true);
          setState(() {
          });
        }, icon: const Icon(Icons.document_scanner_outlined), tooltip: "Scanner du texte",),
        Visibility(
          visible: _descriptionController.text.isNotEmpty,
            child: IconButton(onPressed: () async {
          _descriptionController.text = "${_descriptionController.text}\n\n${await TextRecognitionService.readTextFromImage(context)}";
          setState(() {});
        }, icon: const Icon(Icons.add_circle_outline_outlined), tooltip: "Ajouter du texte à l'existant",)),
        Visibility(
          visible: _descriptionController.text.isNotEmpty,
          child: IconButton(onPressed: () async {
            _descriptionController.text =  "";
            setState(() {
            });
          }, icon: const Icon(Icons.cancel_outlined), tooltip: "Tout effacer",),
        ),

      ],
    );
  }

  void _onScanCodeTap() async {
    String expectedCode = await BarCodeService.scanBarCode(context: context);
    if (expectedCode != "-1") {
      _codeController.text = expectedCode;
      setState(() {});
      _onCodeTapOutside(expectedCode);
    }

  }

  void _onSendDataTap() async {
    if (widget.product != null) {
      _updateProduct();
      return;
    }
    if (_isSending) {
      _cancelToken.cancel("Cancel by user");
      setState(() {
        _isSending = false;
      });
      _cancelToken = CancelToken();
      return;
    }
    if (!_nameIsVerify) {
      await _onNameTapOutside(_nameController.text);
    } else if (!_codeIsVerify) {
      await _onCodeTapOutside(_codeController.text);
    }
    if (_codeExist || _nameExist) {
      showUniversalSnackBar(context: context, message: "Un produit existe déjà avec ce ${_codeExist? 'code': ''} ${_nameExist? 'nom': ''}");
      return;
    }
    if (!_formKey.currentState!.validate()) {
    return;
    }
    _product.name = _nameController.text;
    _product.stock = int.tryParse(_stockController.text);
    _product.brand = _brandController.text;
    _product.description = _descriptionController.text;
    _product.unitPrice = double.tryParse(_unitPriceController.text);
    _product.unitCoast = double.tryParse(_unitCoastController.text);
    _product.code = _codeController.text;
    _product.grammage = double.tryParse(_grammageController.text);
    if (_categoryController.text.isNotEmpty) {
      _product.categoryId = Category.allCategoryList
        .firstWhere((Category category) =>
    category.name.toString() == _categoryController.text)
        .id;
    }
    if (_gammeController.text.isNotEmpty) {
      _product.gammeId = Gamme.allGammeList
        .firstWhere((Gamme gamme) =>
      gamme.name.toString() == _gammeController.text)
        .id;
    }
    if (_rayonController.text.isNotEmpty) {
      _product.rayonId = Rayon.allRayonList
        .firstWhere((Rayon rayon) =>
    rayon.name.toString() == _rayonController.text)
        .id;
    }
    if (_grammageTypeController.text.isNotEmpty) {
      _product.grammageTypeId = GrammageType.allGrammageTypeList
        .firstWhere((GrammageType grammageType) =>
      grammageType.name.toString() == _grammageTypeController.text)
        .id;
    }
    setState(() {_isSending = true;});
    await _product.createProduct(cancelToken: _cancelToken,
      progressCallBack: (progress) => refreshSendDataProgressBarState(context, progress), inventoryMode: (widget.isInventoryMode?? false)? 1: 0).then((value) {
      if (_clearInput) {
        _nameController.text = "";
        _codeController.text = "";
        _brandController.text = "";
        _categoryController.text = "";
        _grammageController.text = "";
        _unitPriceController.text = "";
        _unitCoastController.text = "";
        _grammageTypeController.text = "";
        _descriptionController.text = "";
        _stockController.text = "";
        _rayonController.text = "";
        _gammeController.text = "";
        _product = Product(images: []);
      }
      showUniversalSnackBar(context: context, message: "Produit enregistré avec succès !", backgroundColor: Colors.green);
    }).onError((error, stackTrace) {
      refreshSendDataProgressBarState(context, 0);
      if (!error.toString().contains("Cancel by user")) {
        showUniversalSnackBar(context: context, message: "Une erreur s'est produite !", backgroundColor: Colors.red);
      } else {
        showUniversalSnackBar(context: context, message: "Envoi annulé avec succès !", backgroundColor: Colors.orange);
      }
    });
    _nameIsVerify = false;
    _codeIsVerify = false;
    _isSending = false;
    setState(() {});
  }

  void _updateProduct() async {
    Product product = Product(id: widget.product!.id!);
    product.images = _product.images!.where((element) => element.imageFile != null).toList();
    // print(product.images);
    // return;
    if (_isSending) {
      _cancelToken.cancel("Cancel by user");
      setState(() {
        _isSending = false;
      });
      _cancelToken = CancelToken();
      return;
    }
    // if (!_nameIsVerify) {
    //   await onNameTapOutside(_nameController.text);
    // } else if (!_codeIsVerify) {
    //   await onCodeTapOutside(_codeController.text);
    // }
    // if (_codeExist || _nameExist) {
    //   showUniversalSnackBar(context: context, message: "Un produit existe déjà avec ce ${_codeExist? 'code': ''} ${_nameExist? 'nom': ''}");
    //   return;
    // }
    // if (!_formKey.currentState!.validate()) {
    // return;
    // }
    if (_nameController.text != widget.product!.name) {
      if (_nameController.text.isEmpty) {
        showUniversalSnackBar(context: context, message: "Le nom du produit est obligatoire", backgroundColor: Colors.red);
        return;
      }
      product.name = _nameController.text;
    }
    if (_brandController.text != widget.product!.brand) {
      product.brand = _brandController.text;
    }
    if (_descriptionController.text != widget.product!.description) {
      product.description = _descriptionController.text;
    }
    if (_codeController.text != widget.product!.code) {
      if (_codeController.text.isEmpty) {
        showUniversalSnackBar(context: context, message: "Le code du produit est obligatoire", backgroundColor: Colors.red);
        return;
      }
      product.code = _codeController.text;
    }
    if (_grammageController.text != widget.product!.grammage.toString()) {
      product.grammage = double.tryParse(_grammageController.text);
    }
      int? categoryId = Category.allCategoryList
        .firstWhere((Category category) =>
    category.name.toString() == _categoryController.text, orElse: () => Category(id: -1))
        .id;
    if (categoryId != -1) {
      if (widget.product!.category!.id == null || (widget.product!.category!.id != null && widget.product!.category!.id != categoryId)) {
        product.categoryId = categoryId;
      }
    }
      int? gammeId = Gamme.allGammeList
          .firstWhere((Gamme gamme) =>
      gamme.name.toString() == _gammeController.text, orElse: () => Gamme(id: -1))
          .id;
    if (gammeId != -1) {
      if (widget.product!.gamme!.id == null || (widget.product!.gamme!.id != null && widget.product!.gamme!.id != gammeId)) {
        product.gammeId = gammeId;
      }
    }
      int? rayonId = Rayon.allRayonList
          .firstWhere((Rayon rayon) =>
      rayon.name.toString() == _rayonController.text, orElse: () => Rayon(id: -1))
          .id;
    if (rayonId != -1) {
      if (widget.product!.rayon!.id == null || (widget.product!.rayon!.id != null && widget.product!.rayon!.id != rayonId)) {
        product.rayonId = rayonId;
      }
    }
      int? grammageTypeId = GrammageType.allGrammageTypeList
          .firstWhere((GrammageType grammageType) =>
      grammageType.name.toString() == _grammageTypeController.text, orElse: () => GrammageType(id: -1))
          .id;
    if (grammageTypeId != -1) {
      if (widget.product!.grammageType!.id == null || (widget.product!.grammageType!.id != null && widget.product!.grammageType!.id != grammageTypeId)) {
        product.grammageTypeId = grammageTypeId;
      }
    }

    // }
    // if (_gammeController.text.isNotEmpty) {
    //   _product.gammeId = Gamme.allGammeList
    //     .firstWhere((Gamme gamme) =>
    //   gamme.name.toString() == _gammeController.text)
    //     .id;
    // }
    // if (_rayonController.text.isNotEmpty) {
    //   _product.rayonId = Rayon.allRayonList
    //     .firstWhere((Rayon rayon) =>
    // rayon.name.toString() == _rayonController.text)
    //     .id;
    // }
    // if (_grammageTypeController.text.isNotEmpty) {
    //   _product.grammageTypeId = GrammageType.allGrammageTypeList
    //     .firstWhere((GrammageType grammageType) =>
    //   grammageType.name.toString() == _grammageTypeController.text)
    //     .id;
    // }
    if (!product.isNotEmpty()) {
      return;
    }
    setState(() {_isSending = true;});
    await product.updateProduct(cancelToken: _cancelToken,
      progressCallBack: (progress) => refreshSendDataProgressBarState(context, progress), inventoryMode: (widget.isInventoryMode?? false)? 1: 0).then((value) {
      if (_clearInput) {
        _nameController.text = "";
        _codeController.text = "";
        _brandController.text = "";
        _categoryController.text = "";
        _grammageController.text = "";
        _unitPriceController.text = "";
        _unitCoastController.text = "";
        _grammageTypeController.text = "";
        _descriptionController.text = "";
        _stockController.text = "";
        _rayonController.text = "";
        _gammeController.text = "";
        product = Product(images: []);
      }
      showUniversalSnackBar(context: context, message: "Mise à jour éffectuée avec succès !", backgroundColor: Colors.green);
      Navigator.pop(context, true);
    }).onError((error, stackTrace) {
      refreshSendDataProgressBarState(context, 0);
      if (!error.toString().contains("Cancel by user")) {
        showUniversalSnackBar(context: context, message: "Une erreur s'est produite !", backgroundColor: Colors.red);
      } else {
        showUniversalSnackBar(context: context, message: "Envoi annulé avec succès !", backgroundColor: Colors.orange);
      }
    });
    _nameIsVerify = false;
    _codeIsVerify = false;
    _isSending = false;
    setState(() {});
  }

  Widget _existingProduct() {
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

  Future<bool> _onTryToPop() async {
    return await showSimpleDialog(title: 'Confirmation', context: context, message: "Voulez-vous vraiment quitter ? Vos modifications seront perdues.",
    isimgvisible: true, actionText: "Quitter", onActionTap: (){
          Navigator.of(context).pop(true);
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name!;
      _codeController.text = widget.product!.code!;
      _brandController.text = widget.product!.brand?? "";
      _descriptionController.text = widget.product!.description?? "";
      _grammageController.text = (widget.product!.grammage?? "").toString();
      if (widget.product!.rightSupply != null) {
        _unitPriceController.text = widget.product!.rightSupply!.unitPrice!.toString();
      }
      if (widget.product!.rightSupply != null) {
        _unitCoastController.text = widget.product!.rightSupply!.unitCoast!.toString();
      }
      if (widget.product!.category != null) {
        _categoryController.text = widget.product!.category!.name?? "";
      }
      if (widget.product!.grammageType != null) {
        _grammageTypeController.text = widget.product!.grammageType!.name?? "";
      }
      if (widget.product!.rayon != null) {
        _rayonController.text = widget.product!.rayon!.name?? "";
      }
      if (widget.product!.gamme != null) {
        _gammeController.text = widget.product!.gamme!.name?? "";
      }
      _product.images = widget.product!.images;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _codeController.dispose();
    _gammeController.dispose();
    _grammageController.dispose();
    _grammageTypeController.dispose();
    _rayonController.dispose();
    _stockController.dispose();
    _unitCoastController.dispose();
    _unitPriceController.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_nameController.text.isNotEmpty || _codeController.text.isNotEmpty ||
            _categoryController.text.isNotEmpty || _gammeController.text.isNotEmpty ||
            _descriptionController.text.isNotEmpty || _unitPriceController.text.isNotEmpty ||
            _grammageTypeController.text.isNotEmpty || _stockController.text.isNotEmpty ||
            _rayonController.text.isNotEmpty || _brandController.text.isNotEmpty ||
            _unitCoastController.text.isNotEmpty || _product.images!.isNotEmpty) {
          return _onTryToPop();
        } else {
          return true;
        }
      },
      child: Scaffold(
        extendBody: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          title: Text(widget.product != null?"Editer - ${widget.product!.name!}": "Ajouter un produit", style: TextStyle(fontSize: widget.product != null? 15: 20),),
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
            onTap: _onSendDataTap,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white
              ),
                child: Text(_isSending? "Annuler l'envoi": widget.product != null? "Mettre à jour": "Envoyer", style: const TextStyle(fontWeight: FontWeight.bold),)),
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
                      _existingProduct(),
                      _oneTextFormField(title: "Code *", controller: _codeController, hinText: "Entrez ou scannez le code du produit", required: true,
                          suffix: IconButton(onPressed: _onScanCodeTap, icon: const Icon(Icons.document_scanner)), onTapOutside: _onCodeTapOutside,
                      onTap: (){_codeIsVerify = false;}),
                      _oneTextFormField(title: "Nom *", controller: _nameController, hinText: "Entrez le nom du produit", required: true, onTapOutside: _onNameTapOutside,
                          onTap: (){_nameIsVerify = false; _onCodeTapOutside(_codeController.text);}, suffix: IconButton(onPressed: () async {_nameController.text =
                          await TextRecognitionService.readTextFromImage(context, title: "Selectionnez le nom du produit");
                          setState(() {});}, icon: const Icon(Icons.document_scanner_outlined))),
                      _oneTextFormField(title: "Marque", controller: _brandController, hinText: "Entrez la marque du produit",
                          onTap: (){_onNameTapOutside(_nameController.text); _onCodeTapOutside(_codeController.text);}, suffix: IconButton(onPressed: () async {_brandController.text =
                          await TextRecognitionService.readTextFromImage(context, title: "Selectionnez la marque du produit");
                          setState(() {});}, icon: const Icon(Icons.document_scanner_outlined))),
                      _oneTextFormField(title: "Catégorie *", controller: _categoryController, hinText: "Choisissez la catégorie du produit", required: true,
                          onTap: (){onArticleCategoryTap(_product, _categoryController, context); _onNameTapOutside(_nameController.text); _onCodeTapOutside(_codeController.text);}, keyboardType: TextInputType.none,
                          suffix: IconButton(onPressed: (){onArticleCategoryTap(_product, _categoryController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
                      _oneTextFormField(title: "Rayon *", controller: _rayonController, hinText: "Choisissez le rayon du produit", required: true,
                          onTap: (){onArticleRayonTap(_product, _rayonController, context); _onNameTapOutside(_nameController.text); _onCodeTapOutside(_codeController.text);}, keyboardType: TextInputType.none,
                          suffix: IconButton(onPressed: (){onArticleRayonTap(_product, _rayonController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
                      _oneTextFormField(title: "Gamme", controller: _gammeController, hinText: "Choisissez la gamme du produit", required: false,
                          onTap: (){onArticleGammeTap(_product, _gammeController, context); _onNameTapOutside(_gammeController.text); _onCodeTapOutside(_codeController.text);}, keyboardType: TextInputType.none,
                          suffix: IconButton(onPressed: (){onArticleGammeTap(_product, _gammeController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
                      _oneTextFormField(title: "Grammage", controller: _grammageController, hinText: "Entrez le grammage du produit", keyboardType: TextInputType.number,
                      onTap: (){_onNameTapOutside(_nameController.text); _onCodeTapOutside(_codeController.text);}),
                      _oneTextFormField(title: "Type de grammage", controller: _grammageTypeController, hinText: "Choisissez le type de grammage du produit",
                          onTap: (){onProductGrammageTypeTap(_product, _grammageTypeController, context); _onNameTapOutside(_nameController.text); _onCodeTapOutside(_codeController.text);}, keyboardType: TextInputType.none,
                          suffix: IconButton(onPressed: (){onProductGrammageTypeTap(_product, _grammageTypeController, context);}, icon: const Icon(Icons.arrow_drop_down_circle_outlined))),
                      _oneTextFormField(title: "Stock *", controller: _stockController, hinText: "Début de stock du produit", keyboardType: TextInputType.number, required: true,
                      onTap: (){_onNameTapOutside(_nameController.text); _onCodeTapOutside(_codeController.text);}, disabled: widget.product != null),
                      _oneTextFormField(title: "Prix unitaire *", controller: _unitPriceController, hinText: "Prix unitaire de vente du produit", keyboardType: TextInputType.number, required: true,
                          onTap: (){_onNameTapOutside(_nameController.text); _onCodeTapOutside(_codeController.text);}, disabled: widget.product != null),
                      _oneTextFormField(title: "Coût unitaire *", controller: _unitCoastController, hinText: "Coût unitaire d'achat du produit", keyboardType: TextInputType.number, required: true,
                          onTap: (){_onNameTapOutside(_nameController.text); _onCodeTapOutside(_codeController.text);}, disabled: widget.product != null),
                      _oneTextFormField(title: "Description", controller: _descriptionController, hinText: "Entrez ou scannez la description du produit", maxLines: 10,
                          suffix: _descriptionSuffix(), onTap: (){_onNameTapOutside(_nameController.text); _onCodeTapOutside(_codeController.text);}),
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
                      if (index == _product.images!.length) {
                        return addImageBox(context, _product);
                      } else {
                        return oneImageBox(context, _product, index, onChangeImageTap, onDeleteImageTap, isLocalImage: _product.images![index].imageFile != null);
                      }
                    },
                    childCount: _product.images!.length + 1,
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
      ),
    );
  }
}
