
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_to_text/DATA/DataClass/MyUser.dart';

import 'package:image_to_text/UI/AddProduct/AddProductPage.dart';
import 'package:image_to_text/UI/MiniWidget/ModalButtonWidget.dart';
import 'package:image_to_text/UI/SaleProduct/SaleProductPage.dart';
import 'package:image_to_text/MiniFunction/UniversalFooterShown.dart';

import '../../AppService/BarCodeService.dart';
import '../InventoryPage/InventoryPage.dart';
import '../ListProduct/ListProductPage.dart';
import '../MiniWidget/UniversalSnackBar.dart';
import 'Component/MyDrawer.dart';
import 'Component/TestConnectionWidget.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool _isReloadingUser = false;

  Future<void> _scanQR({ScanMode? scanType}) async {
      await BarCodeService.scanBarCode(context: context, scanType: scanType).then((code)  {
        if (code != "-1") {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SaleProductPage(code: code),));
        }
      });
  }

  void _editProduct() {
    showTransparentUniversalFooter([
      modalButtonWidget(title: 'Choisir dans la liste', onTap: (){}, icon: Icons.list_alt_outlined),
      modalButtonWidget(title: 'Scanner son code', onTap: (){}, icon: Icons.document_scanner_sharp),
    ], context, title: "Editer un produit");
  }

  void _showListProduct() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ListProductPage(),));
  }

  void _showAddProductPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddProductPage(),));
  }

  Widget _oneCard(String title, IconData icon, Function onTap, Color color, {Function? onLongTap}) {
    return InkWell(
      onLongPress: (){
        if (onLongTap != null) {
          onLongTap();
        }
      },
      onTap: (){
        onTap();
      },
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 6,
        child: Container(
          height: 150,
          width: MediaQuery.of(context).size.width / 2 - 20,
          // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          padding: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                      child: Icon(icon, size: 40, color: color,)),
                ],
              ),
              Container(
                height: 70,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                      child: Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),),
                    ],
                  )))
            ],
          ),
        ),
      ),
    );
  }

  void _onReloadUserTap() async {
    setState(() {
      _isReloadingUser = true;
    });
    MyUser.reloadUser().then((MyUser? user) {
      _isReloadingUser = false;
      if (user != null) {
        if (user.isActive?? false) {
          showUniversalSnackBar(context: context, message: "Votre compte est désormais actif");
        }
      }
      setState(() {});
    }).onError((error, stackTrace) {
      _isReloadingUser = false;
      setState(() {});
      showUniversalSnackBar(context: context, message: 'Une erreur s\'est produite');
    });
  }

  Widget _inactiveAccountWidget() {
    return Center(
      child: _isReloadingUser? const CircularProgressIndicator(): Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.info, color: Theme.of(context).colorScheme.primary, size: 40,),
                  ),
                  const SizedBox(height: 10,),
                  const Text("Votre compte n'est pas encore actif", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  const SizedBox(height: 10,),
                  const Text("Un administrateur doit activer votre compte"),
                  const SizedBox(height: 10,),
                  TextButton(
                    style: ButtonStyle(
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            borderRadius: BorderRadius.circular(40)))
                    ),
                      onPressed: (){
                    _onReloadUserTap();
                  }, child: const Text("Rafraichir")),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MyUser.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return MyUser.currentUser.role == "guest" ? (!MyUser.currentUser.isActive!? Scaffold(
        drawer: const MyDrawerMenu(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          title: const Text("DEL BLANCO"),
        ),
        body: _inactiveAccountWidget()): const InventoryPage(myDrawer: MyDrawerMenu(),)): Scaffold(
      drawer: const MyDrawerMenu(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text("DEL BLANCO"),
      ),
      body:
      // !MyUser.currentUser.isActive!? _inactiveAccountWidget():
      Container(
        padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
        child: ListView(
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _oneCard("Vendre", Icons.document_scanner_outlined, (){_scanQR(scanType: ScanMode.BARCODE);}, Colors.green,
              onLongTap: (){_scanQR(scanType: ScanMode.QR);}),
              _oneCard("Ajouter un produit", Icons.add_circle, _showAddProductPage, Colors.red),
            ],
          ),
          const SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _oneCard("Editer un produit", Icons.edit, editProduct, Theme.of(context).colorScheme.inversePrimary),
              _oneCard("Liste des produits", Icons.list, _showListProduct, Colors.blue),
            ],
          ),
            const SizedBox(height: 30,),
            const TestConnectionWidget()
          ],
        ),
      ),
    );
  }
}
