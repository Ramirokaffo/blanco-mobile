
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_to_text/UI/AddProduct/AddProductPage.dart';

import '../../AppService/BarCodeService.dart';
import '../../DATA/DataClass/Inventory.dart';
import '../../DATA/DataClass/MyUser.dart';
import '../../DATA/DataClass/Product.dart';
import '../../StateManager/InventoryPageState.dart';
import '../ListProduct/ListProductPage.dart';
import '../MiniWidget/UniversalSnackBar.dart';
import 'OneInventoryWidget.dart';

class InventoryPage extends StatefulWidget {
  final Widget? myDrawer;
  const InventoryPage({Key? key, this.myDrawer}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {

  List<Inventory> listInventory = [];


  void onSearchProductTap(Product product) {
    Product.getProductByCode(product.code!).then((Product? myProduct){
      if (myProduct != null) {
        Navigator.pop(context);
        setState(() {
          listInventory.add(Inventory(product: product, staff: MyUser.currentUser));
        });
      } else {
        showUniversalSnackBar(context: context, message: "Une erreur s'est produite");
      }
    }).onError((error, stackTrace) {
      print(error);
      showUniversalSnackBar(context: context, message: "Une erreur s'est produite ici $error");
    });
  }

  void onAddProductTap() async {
    await BarCodeService.scanBarCode(context: context).then((code)  {
      if (code.isNotEmpty) {
        Product.getProductByCode(code).then((Product? product) {
          if (product != null ) {
            setState(() {
              listInventory.add(Inventory(product: product, staff: MyUser.currentUser));
            });
          } else {
            showUniversalSnackBar(context: context, message: "Aucun produit trouvé pour ce code");
          }
        }).onError((error, stackTrace) {
          showUniversalSnackBar(context: context, message: "Une erreur s'est produite");
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.myDrawer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Inventaire"),
        actions: [IconButton(onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListProductPage(onSaleTap: onSearchProductTap, actionText: "Ajouter",),));
        }, icon: const Icon(Icons.search),
          style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(
              Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2))),)],
      ),
      body: BlocBuilder<InventoryPageState, bool>(
          builder: (BuildContext contxt, state) {
            int index = 0;
            return Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomScrollView(
            slivers: [
              SliverList(delegate: SliverChildListDelegate(listInventory.map((e) => OneInventoryWidget(listInventory: listInventory, index: index++)).toList())),
              SliverList(delegate: SliverChildListDelegate(
               <Widget>[
                  const SizedBox(height: 30,),
                  TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
                        foregroundColor: const MaterialStatePropertyAll(Colors.white),
                        // padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 10))
                      ),
                      onPressed: onAddProductTap, child: const Text("Scanner le code")),
                  const SizedBox(height: 20,),
                  TextButton(
                      style: ButtonStyle(
                        backgroundColor: const MaterialStatePropertyAll(Colors.white),
                        // foregroundColor: const MaterialStatePropertyAll(Colors.white),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                              side: BorderSide(color: Theme.of(context).colorScheme.primary), borderRadius: BorderRadius.circular(30)))
                        // padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 10))
                      ),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddProductPage(isInventoryMode: true),));
                      }, child: const Text("Nouveau produit")),
                ]
              ))
              // ListView(
              //   children: [
              //     // for r in listInventory {
              //     // OneInventoryWidget
              //     // }
              //     // listInventory.forEach((element) { }),
              //
              //   ],
              // ),
            ],
          ),
      );})
    );
  }
}
