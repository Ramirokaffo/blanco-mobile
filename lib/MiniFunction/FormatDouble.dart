//2039.0

String doubleToString(double value, {String separator = " "}) {
  List<String> listAllValue = value.toString().split(".");
  if (listAllValue[0].length >= 4) {
    String newValue = listAllValue[0];
    String j = "";
    List<String> listTree = [];
    for (var i in (newValue.split("")).reversed) {
      j = i + j;
      if (j.length == 3) {
        listTree.add(j);
        j = "";
      }
    }
    listTree.add(j);
    if (listAllValue[1] != "0") {
      listTree[0] += listAllValue[1];
    }
    listTree = listTree.reversed.toList();


    return listTree.join(separator);
  } else {
    if (listAllValue[1] != "0") {
      return value.toString();
    } else {
      return listAllValue[0];
    }
  }
}