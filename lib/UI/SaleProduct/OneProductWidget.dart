
import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/Sale.dart';

import '../../StateManager/SaleProductPageState.dart';
import '../ProductDetails/ProductDetailsPage.dart';

class OneProductWidget extends StatefulWidget {
  final Sale sale;
  final int index;
  const OneProductWidget({Key? key, required this.sale, required this.index}) : super(key: key);

  @override
  State<OneProductWidget> createState() => _OneProductWidgetState();
}

class _OneProductWidgetState extends State<OneProductWidget> {

  TextEditingController countController = TextEditingController(text: "1");
  TextEditingController priceController = TextEditingController();

  void onIncrementOrDecrementProductCount(bool isDecrement)  {
    int currentValue = int.tryParse(countController.text)?? 0;
    if (!isDecrement) {
      if (currentValue + 1 <=
          widget.sale.saleProducts![widget.index].product!.stock!) {
        countController.text = (currentValue + 1).toString();
      }
    } else {
      if (currentValue != 1) {
        countController.text = (currentValue - 1).toString();
      }
    }
    widget.sale.saleProducts![widget.index].productCount = int.tryParse(countController.text)?? 0;
    refreshSaleProductPageState(context);
  }

  void onChangeProductCount(String value)  {
    int currentValue = int.tryParse(value)?? 0;
      if (currentValue > widget.sale.saleProducts![widget.index].product!.stock!) {
        countController.text = widget.sale.saleProducts![widget.index].product!.stock!.toString();
      } else if (currentValue < 0) {
        countController.text = "1";
      }
    widget.sale.saleProducts![widget.index].productCount = int.tryParse(value)?? 0;
    refreshSaleProductPageState(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.sale.saleProducts![widget.index].product!.rightSupply != null) {
      priceController.text = widget.sale.saleProducts![widget.index].product!.rightSupply!.unitPrice!.toString();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.sale.saleProducts![widget.index].product!.name!, style: const TextStyle(fontWeight: FontWeight.bold),),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                SizedBox(
                  width: 150,
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){
                      onIncrementOrDecrementProductCount(true);
                    },
                    child: const Icon(Icons.remove_circle_outline),
                  ),
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all()
                  ),
                  child: TextFormField(
                    controller: countController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: onChangeProductCount,
                  ),
                ),
                  InkWell(
                    onTap: (){
                      onIncrementOrDecrementProductCount(false);
                    },
                    child: const Icon(Icons.add_circle_outline_outlined),
                  ),
                ],
                  ),
                ),
                  Text("${widget.sale.saleProducts![widget.index].product!.stock?? 0} pièces en stock")
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("P.U."),
                      const SizedBox(width: 20,),
                      Container(
                        width: 102,
                        height: 30,
                        decoration: BoxDecoration(
                            border: Border.all()
                        ),
                        child: TextFormField(
                          controller: priceController,
                          readOnly: !widget.sale.saleProducts![widget.index].product!.isPriceReducible!,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                            onChanged: (value) {
                              widget.sale.saleProducts![widget.index].unitPrice = double.tryParse(value)?? 0;
                              refreshSaleProductPageState(context);
                            },
                        ),
                      ),
                    ],
                  ),
                  Text("Total ${widget.sale.saleProducts![widget.index].getTotalPrice().toString().split('.')[0]} FCFA")
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 30)),
                        foregroundColor: const MaterialStatePropertyAll(Colors.red),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(40)))
                    ),
                      onPressed: (){
                    widget.sale.saleProducts!.removeAt(widget.index);
                    refreshSaleProductPageState(context);
                  }, child: const Text("Retirer")),
                  const SizedBox(width: 10,),
                  TextButton(
                      style: ButtonStyle(
                          padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 30)),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                              side: BorderSide(color: Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(40)))
                      ),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductDetailsPage(productId: widget.sale.saleProducts![widget.index].product!.id!),));
                      }, child: const Text("Détails", style: TextStyle(fontWeight: FontWeight.bold),)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
