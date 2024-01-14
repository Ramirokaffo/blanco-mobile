import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/Product.dart';
import 'package:image_to_text/AppService/TextRecognitionService.dart';
import 'package:image_to_text/UI/MiniWidget/UniversalSnackBar.dart';

import '../../AppService/BarCodeService.dart';
import '../ProductDetails/ProductDetailsPage.dart';
import '../SaleProduct/SaleProductPage.dart';

class ListProductPage extends StatefulWidget {
  final Function(Product product)? onSaleTap;
  final String? actionText;
  final bool? autofocus;
  const ListProductPage({Key? key, this.onSaleTap, this.actionText, this.autofocus}) : super(key: key);

  @override
  State<ListProductPage> createState() => _ListProductPageState();
}

class _ListProductPageState extends State<ListProductPage> {
  final List<Product> _productList = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isViewFinish = false;
  int _currentPage = 0;
  bool _notMatchedData = false;
  bool _anErrorOccur = false;

  void getProductList() async {
    _anErrorOccur = false;
    setState(() {_isLoading = true;});
    Product.getProductList().then((List<Product>? products) {
      _isLoading = false;
      if (products != null) {
        _productList.addAll(products);
      }
      setState(() {});
    }).onError((error, stackTrace) {
      _anErrorOccur = true;
      setState(() {_isLoading = false;});
      showUniversalSnackBar(context: context, message: "Une erreur s'est produite !", backgroundColor: Colors.red);
    });
  }


  void fetchData(String searchInput) async {
    _anErrorOccur = false;
    Product.getSearchResult(searchInput, page: _currentPage).then((List<Product>? products) {
      _isViewFinish = false;
      _isLoading = false;
      if (products != null) {
        if (products.isNotEmpty) {
          _notMatchedData = false;
          _productList.addAll(products);
        } else {
          _notMatchedData = true;
        }
      }
      setState(() {});
    }).onError((error, stackTrace) {
      _isViewFinish = false;
      _notMatchedData = false;
      _anErrorOccur = true;
      _isLoading = false;
      setState(() {});
    showUniversalSnackBar(context: context, message: "Une erreur s'est produite !", backgroundColor: Colors.red);
    });
  }

  Widget _notMatchedDataWidget() {
    return const Center(
      child: Text("Aucun produit ne correspond à votre recherche"),
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
              setState(() {
                _isLoading = true;
                fetchData(_searchController.text);
              });
            }, child: const Text("Rafraichir la page"))
          ],
        ),
      ),
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductList();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
          if (!_isViewFinish) {
            _currentPage++;
            fetchData(_searchController.text);
            setState(() {
            _isViewFinish = true;
          });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int itemLength = _productList.length;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(35)
          ),
          child: TextFormField(
            controller: _searchController,
            onChanged: (value) {
              _productList.clear();
              _currentPage = 0;
              fetchData(value);
            },
            autofocus: widget.autofocus?? true,
            decoration: InputDecoration(
              hintText: "Rechercher",
              prefixIcon: const Icon(Icons.search),
              border: InputBorder.none,
              suffixIcon: InkWell(
                onTap: () async {
                  await TextRecognitionService.readTextFromImage(context, title: "Selectionnez le texte à rechercher").then((value) {
                    if (value.isNotEmpty) {
                      _productList.clear();
                      _currentPage = 0;
                      fetchData(value);
                      _searchController.text = value;
                    }
                  });
                },
                  child: const Icon(Icons.document_scanner_outlined)),
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: () async {
            await BarCodeService.scanBarCode(context: context).then((code) async  {
              Product.getProductByCode(code).then((value) {
                if (value != null) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductDetailsPage(productId: value.id!),));
                } else {
                  showUniversalSnackBar(context: context, message: 'Aucun produit trouvé');
                }
              }).onError((error, stackTrace) {
                showUniversalSnackBar(context: context, message: 'Une erreur s\'est produite !', backgroundColor: Colors.red);
              });
            });
          }, icon: const Icon(Icons.document_scanner))
        ],
      ),
      body: _anErrorOccur? _errorWidget(): _isLoading? const Center(child: CircularProgressIndicator(),): _notMatchedData && _currentPage == 0? _notMatchedDataWidget(): Container(
        padding: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1)
        ),
        child: ListView.separated(
          controller: _scrollController,
            itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(5),
                  elevation: 1,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_productList[index].name!),
                        const Divider(),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  style: ButtonStyle(
                                      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 30)),
                                      foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
                                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                          borderRadius: BorderRadius.circular(40)))
                                  ),
                                  onPressed: () {
                                    if (widget.onSaleTap != null) {
                                      widget.onSaleTap!(_productList[index]);
                                    } else {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SaleProductPage(code: _productList[index].code!,)));
                                    }
                                  },
                                  child: Text(widget.actionText?? "Vendre")),
                              const SizedBox(width: 20,),
                              TextButton(
                                  style: ButtonStyle(
                                      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 30)),
                                      foregroundColor: const MaterialStatePropertyAll(Colors.black),
                                      backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                                          side: const BorderSide(color: Colors.black),
                                          borderRadius: BorderRadius.circular(40)))
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductDetailsPage(productId: _productList[index].id!),));
                                  },
                                  child: const Text("Détails")),
                              // VerticalDivider(),
                              // const Text("Détails"),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: index == itemLength - 1 && _isViewFinish,
                  child: const Column(
                    children: [
                      SizedBox(height: 20,),
                      CircularProgressIndicator(),
                    ],
                  ))
            ],
          );
        }, separatorBuilder: (context, index) {
          return const SizedBox(height: 10,);
        }, itemCount: itemLength)),
    );
  }
}


