import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';
import 'package:image_to_text/DATA/DataClass/Sale.dart';
import 'package:image_to_text/UI/MiniWidget/UniversalSnackBar.dart';

import '../../DATA/DataClass/SaleProduct.dart';
import '../../MiniFunction/GlobalTestConnectivity.dart';
import '../../StateManager/SaleProductPageState.dart';
import '../../AppService/BarCodeService.dart';
import '../ListProduct/ListProductPage.dart';
import '../MiniWidget/showSimpleDialog.dart';
import 'Componenent/OneProductWidget.dart';

class SaleProductPage extends StatefulWidget {
  final String code;
  const SaleProductPage({Key? key, required this.code}) : super(key: key);

  @override
  State<SaleProductPage> createState() => _SaleProductPageState();
}

class _SaleProductPageState extends State<SaleProductPage> {
  bool _isFetching = true;
  bool _andErrorOccur = false;
  bool _notFound = false;
  final Sale _sale = Sale(saleProducts: []);


  void _getCodeProduct() async {
    Product.getProductByCode(widget.code).then((Product? product) {
      if (product != null ) {
        _sale.saleProducts!.add(SaleProduct(product: product, unitPrice: product.rightSupply != null? product.rightSupply!.unitPrice: 0, productCount: product.rightSupply != null? 1: 0));
        _notFound = false;
      } else {
        _notFound = true;
      }
      setState(() {
        _isFetching = false;
        _andErrorOccur = false;
      });
    }).onError((error, stackTrace) {
      setState(() {
        _isFetching = false;
        _andErrorOccur = true;
      });
    });

  }

  void _onAddProductTap() async {
    await BarCodeService.scanBarCode(context: context).then((code)  {
      if (code.isNotEmpty) {
        Product.getProductByCode(code).then((Product? product) {
          if (product != null ) {
            setState(() {
              _sale.saleProducts!.add(SaleProduct(product: product, unitPrice: product.rightSupply != null? product.rightSupply!.unitPrice: 0, productCount: product.rightSupply != null? 1: 0));
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

  Widget _addSaleProductWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 30, bottom: 20),
      decoration: const BoxDecoration(
      ),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: const MaterialStatePropertyAll(Colors.blue),
          elevation: const MaterialStatePropertyAll(5),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                side: const BorderSide(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(40)))
        ),
        onPressed: _onAddProductTap,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner_outlined),
          SizedBox(width: 20,),
          Text("Ajouter un produit", style: TextStyle(fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Une erreur s'est produite"),
          TextButton(onPressed: (){
            print('object');
            _getCodeProduct();
            }, child: Text("Rafraîchir"))
        ],
      ),
    );
  }

  Widget _notFoundWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Aucun produit trouvê"),
          TextButton(onPressed: (){
            _getCodeProduct();
            }, child: Text("Rafraîchir"))
        ],
      ),
    );
  }

  void _onSearchProductTap(Product product) {
Product.getProductByCode(product.code!).then((Product? myProduct){
    if (myProduct != null) {
      Navigator.pop(context);
      setState(() {
        _sale.saleProducts!.add(SaleProduct(product: myProduct, unitPrice: myProduct.rightSupply != null? myProduct.rightSupply!.unitPrice: 0, productCount: myProduct.rightSupply != null? 1: 0));
      });
    } else {
      showUniversalSnackBar(context: context, message: "Une erreur s'est produite", backgroundColor: Colors.red);
    }
}).onError((error, stackTrace) {
  showUniversalSnackBar(context: context, message: "Une erreur s'est produite", backgroundColor: Colors.red);
});
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
    _getCodeProduct();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_sale.saleProducts!.isNotEmpty) {
          return _onTryToPop();
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Vente des produits"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(onPressed: (){globalConnectivityTest(context);}, icon: const Icon(Icons.qr_code),
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2)))),
            IconButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListProductPage(onSaleTap: _onSearchProductTap,),));
          }, icon: const Icon(Icons.search),
          style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2))),)],
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: InkWell(
            onTap: (){
              _sale.createBasket().then((value) {
                _sale.saleProducts!.clear();
                setState(() {});
                showUniversalSnackBar(context: context, message: "Envoyé avec succès !");
              }).onError((error, stackTrace) {
                showUniversalSnackBar(context: context, message: "Une erreur s'est produite");
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(30)
              ),
              child: const Text("Envoyer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            ),
          ),
        ),
        body: _notFound? _notFoundWidget(): _andErrorOccur? _errorWidget():  _isFetching? const Center(child: CircularProgressIndicator(),):  BlocBuilder<SaleProductPageState, bool>(
      builder: (BuildContext context, state) {
        int index = 0;
        List<Widget> listSaleProduct = _sale.saleProducts!.map((e) => OneProductWidget(sale: _sale, index: index++)).toList();
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        ),
        padding: const EdgeInsets.only(right: 10, left: 10),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: 20,),
              ),
              SliverList.list(children: listSaleProduct),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all()
                  ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Montant total", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
                        Text("${_sale.getTotalPrice().toString().split(".")[0]} FCFA", style: const TextStyle(fontWeight: FontWeight.bold))
                      ],
                    )),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _addSaleProductWidget(),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Ajouter à la vente courante"),
                        Switch(value: _sale.addToCurrentSale!, onChanged: (value) {
                          setState(() {
                            _sale.addToCurrentSale = !_sale.addToCurrentSale!;
                          });
                        },),
                      ],
                    )
                  ],
                ),
              ),

            ],
          ),
        );}),
      ),
    );
  }
}
