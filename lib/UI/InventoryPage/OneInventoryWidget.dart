
import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/Inventory.dart';
import 'package:image_to_text/StateManager/InventoryPageState.dart';
import 'package:image_to_text/UI/MiniWidget/UniversalSnackBar.dart';

import '../../DATA/DataClass/MyUser.dart';
import '../ProductDetails/ProductDetailsPage.dart';


class OneInventoryWidget extends StatefulWidget {
  final List<Inventory> listInventory;
  final int index;
  const OneInventoryWidget({Key? key, required this.listInventory, required this.index}) : super(key: key);

  @override
  State<OneInventoryWidget> createState() => _OneInventoryWidgetState();
}

class _OneInventoryWidgetState extends State<OneInventoryWidget> {
  final TextEditingController validProductCountController = TextEditingController();

  final TextEditingController invalidProductCountController = TextEditingController();
  bool _isSending = false;

  void onSendInventory() async {

    if (validProductCountController.text.isEmpty && invalidProductCountController.text.isEmpty) {
      showUniversalSnackBar(context: context, message: "Veuillez entrer le nombre de produit compté physiquement");
      return;
    }
    setState(() {
      _isSending = true;
    });
    int validProductCount = int.tryParse(validProductCountController.text)?? 0;
    int invalidProductCount = int.tryParse(invalidProductCountController.text)?? 0;
    Inventory inventory = Inventory(validProductCount: validProductCount,
        invalidProductCount: invalidProductCount, staff: MyUser.currentUser, product: widget.listInventory[widget.index].product);
    await inventory.save().then((value) {
      if (value != null) {
        widget.listInventory.removeAt(widget.index);
        refreshInventoryPageStateState(context);
        showUniversalSnackBar(context: context, message: "Enregistrement effectué avec succès !", backgroundColor: Colors.green);
      }
    }).onError((error, stackTrace) {
      showUniversalSnackBar(context: context, message: "Une erreur s'est produite !", backgroundColor: Colors.red);
    });
    setState(() {
      _isSending = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Material(
        elevation: 2,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.listInventory[widget.index].product!.name!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Nombre de produits valides"),
                  // const SizedBox(width: 40,),
                  Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                        border: Border.all()),
                    child: TextFormField(controller: validProductCountController,),
                  )
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Nombre de produits invalides"),
                  // const SizedBox(width: 40,),
                  Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                        border: Border.all()),
                    child: TextFormField(controller: invalidProductCountController,),
                  )
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  TextButton(
                    style: ButtonStyle(
                        backgroundColor: const MaterialStatePropertyAll(Colors.white),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            side: const BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(30)))
                    ),
                      onPressed: (){
                        widget.listInventory.removeAt(widget.index);
                        refreshInventoryPageStateState(context);
                      }, child: const Text("Retirer", style: TextStyle(color: Colors.red),)),
                  const SizedBox(width: 20,),
                  TextButton(
                      style: ButtonStyle(
                          backgroundColor: const MaterialStatePropertyAll(Colors.white),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.blue), borderRadius: BorderRadius.circular(30)))
                      ),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductDetailsPage(productId: widget.listInventory[widget.index].product!.id!),));
                      }, child: const Text("Détails", style: TextStyle(color: Colors.blue),)),
                  const SizedBox(width: 20,),
                  _isSending? const CircularProgressIndicator(color: Colors.green,): TextButton(
                      style: ButtonStyle(
                          backgroundColor: const MaterialStatePropertyAll(Colors.white),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.green), borderRadius: BorderRadius.circular(30)))
                      ),
                      onPressed: onSendInventory, child: const Text("Valider", style: TextStyle(color: Colors.green))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
