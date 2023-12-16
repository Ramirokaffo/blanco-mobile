import 'package:flutter/material.dart';

class ExtractedTextItem extends StatefulWidget {
  final String itemText;
  late bool isCheck;
  final int index;
  final Function(int index) onDismissed;

  ExtractedTextItem({Key? key, required this.itemText, required this.index, required this.onDismissed}) : super(key: key);

  @override
  State<ExtractedTextItem> createState() => _ExtractedTextItemState();
}

class _ExtractedTextItemState extends State<ExtractedTextItem> {
  int myIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: (direction) {
        widget.onDismissed(myIndex);
      },
      key: UniqueKey(),
      child: InkWell(
        onTap: () {
          setState(() {
            widget.isCheck = !widget.isCheck;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(5)),
          child: Material(
            elevation: 1,
            borderRadius: BorderRadius.circular(5),
            child: Row(
              children: [
                Radio(
                  value: widget.isCheck,
                  groupValue: true,
                  onChanged: (value) {
                    setState(() {
                      widget.isCheck = !widget.isCheck;
                    });
                  },
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.itemText,
                        textAlign: TextAlign.left,
                      ),
                      Divider()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
