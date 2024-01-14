
import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';
import 'package:image_to_text/MiniFunction/FormatDouble.dart';
import 'package:image_to_text/UI/EditProduct/EditProductPage.dart';
import 'package:image_to_text/UI/ProductDetails/ProductImagesCaroussel.dart';

import '../AddProduct/AddProductPage.dart';
import '../SaleProduct/SaleProductPage.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;
  const ProductDetailsPage({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}



class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Product product;
  bool isLoading = true;
  bool anErrorOccur = false;
  void loadProduct() async {
    Product.getProductById(widget.productId).then((Product? myProduct) {
      isLoading = false;
      if (myProduct != null) {
        anErrorOccur = false;
        product = myProduct;
      }
      setState(() {});

    }).onError((error, stackTrace) {
      anErrorOccur = true;
      setState(() {});
    });
  }

  Widget oneDetailsLine(String title, String value) {
    return Column(
      children: [
        const Divider(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold),),
          ],
        )
      ],
    );
  }

  Widget _errorWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Oups !", style: TextStyle(fontSize: 25, color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 20,),
            const Text("Impossible de charger la page, rassurez-vous que le "
                "serveur est en marche et que vous êtes connecté sur le même réseau local !",
              style: TextStyle(fontSize: 15),),
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
                  loadProduct();
                }, child: const Text("Rafraichir la page"))
          ],
        ),
      ),
    );
  }


  void _onEditProductTap() async {
    bool? result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddProductPage(product: product),));
    if (result != null && result) {
      setState(() {
        isLoading = true;
        anErrorOccur = false;
      });
      loadProduct();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProduct();
  }
  @override
  Widget build(BuildContext context) {
    return isLoading? Container(
      color: Colors.white,
        alignment: Alignment.center,
        child: const CircularProgressIndicator()): anErrorOccur? _errorWidget(): Scaffold(
      appBar: AppBar(
        title: Text(product.name!, style: const TextStyle(fontSize: 15),),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [IconButton.filledTonal(onPressed: _onEditProductTap, icon: const Icon(Icons.edit),
            style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2))))],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SaleProductPage(code: product.code!),));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(30)
            ),
            child: const Text("Vendre", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                margin: const EdgeInsets.only(top: 20),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(10),
                  child: product.images!.isNotEmpty? ArticleImagesCarousel(images: product.images!):
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white
                  ),
                  child: const Icon(Icons.image_not_supported, size: 100,),),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                // padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                        oneDetailsLine("Code", product.code?? "Aucun"),
                        oneDetailsLine("Catégorie", product.category!.name?? "Aucune"),
                        oneDetailsLine("Marque", product.brand?? "Aucune"),
                        oneDetailsLine("Rayon", product.rayon!.name?? "Aucun"),
                        oneDetailsLine("Grammage", product.grammage == null? "Aucun": doubleToString(product.grammage!)),
                        oneDetailsLine("Type de grammage", product.grammageType!.name?? "Aucun"),
                        oneDetailsLine("Quantité en stock", product.stock!.toString()),
                        oneDetailsLine("Prix unitaire", "${doubleToString(product.rightSupply!.unitPrice?? 0)} FCFA"),
                      ],
                      ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                        const Divider(),
                        Text(product.description??"Aucune",),
                      ],
                      ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 50,),
            )
          ],
        ),
      ),
    );
  }
}
