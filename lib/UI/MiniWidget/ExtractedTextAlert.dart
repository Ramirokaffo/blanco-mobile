
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ExtractedTextItem.dart';

class ExtractedTextAlert extends StatefulWidget {
  final RecognizedText recognizedText;
  final bool? checkByDefault;
  final String? title;
  const ExtractedTextAlert({Key? key, required this.recognizedText, this.checkByDefault, this.title}) : super(key: key);
  @override
  State<ExtractedTextAlert> createState() => _ExtractedTextAlertState();
}

class _ExtractedTextAlertState extends State<ExtractedTextAlert> {
  List<ExtractedTextItem> listExtractedTextItem = [];
  late List<TextBlock> _listTextBlock;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listTextBlock = widget.recognizedText.blocks;
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    listExtractedTextItem = _listTextBlock.map((TextBlock textBlock) {
      ExtractedTextItem extractedTextItem = ExtractedTextItem(itemText: textBlock.text, index: index++, onDismissed: (index) {
        setState(() {
          _listTextBlock.removeAt(index);
          listExtractedTextItem.removeAt(index);
        });
      },);
      extractedTextItem.isCheck = widget.checkByDefault?? false;
      return extractedTextItem;
    }).toList();
    return AlertDialog(
      title: Text(widget.title?? "Texte extrait", textAlign: TextAlign.center,),
      content: ListView(
        children: listExtractedTextItem,
      ),
      actions: [
        TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("Annuler")),
        TextButton(onPressed: (){
          Navigator.of(context).pop(listExtractedTextItem.fold("", (previousValue, element) =>  element.isCheck? "$previousValue  ${element.itemText}": previousValue));
        }, child: const Text("Ok")),
      ],
    );
  }
}
