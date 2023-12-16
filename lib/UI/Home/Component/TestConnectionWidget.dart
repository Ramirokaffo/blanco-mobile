

import 'package:flutter/material.dart';
import 'package:image_to_text/AppService/BarCodeService.dart';

import '../../../DATA/DataClass/MyUser.dart';

class TestConnectionWidget extends StatefulWidget {
  const TestConnectionWidget({Key? key}) : super(key: key);

  @override
  State<TestConnectionWidget> createState() => _TestConnectionWidgetState();
}

class _TestConnectionWidgetState extends State<TestConnectionWidget> {
  bool _isLoading = false;
  bool _connectionHasFail = false;
  
  void testConnectivity(bool byScan) async {
    String? code;
    if (byScan) {
     code = await BarCodeService.scanBarCode(context: context);
    }
    if (mounted) {
      setState(() {
      _isLoading = true;
    });
    }
    MyUser.testServerConnection(serverUri: code).then((value) {
      if (value["status"] == 1) {
        _connectionHasFail = false;
      } else {
        _connectionHasFail = true;
      }
      if (mounted) {
        setState(() {
        _isLoading = false;
      });
      }

    }).onError((error, stackTrace) {
      if (mounted) {
        setState(() {
        _connectionHasFail = true;
        _isLoading = false;
      });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    testConnectivity(false);
  }

  @override
  Widget build(BuildContext context) {
    print(_connectionHasFail);
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 6,
      child: Container(
        width: MediaQuery.of(context).size.width,
        // height: 100,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary,

        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Connectivité", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30),),
                const SizedBox(width: 20,),
                _connectionHasFail? const Icon(Icons.cancel, color: Colors.red,): const Icon(Icons.check_circle_rounded, color: Colors.green,)
              ],
            ),
            Text("Le dernier test de connectivité au serveur a ${_connectionHasFail?'échoué': 'réussi'} ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white60)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
              Visibility(
                  visible: _connectionHasFail,
                  child: TextButton(
                      onPressed: () { testConnectivity(true); },
                      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.white)),
                      child: const Text("Scanner le code", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))),
                const SizedBox(width: 10,),
                _isLoading? const CircularProgressIndicator(color: Colors.blue,):
                TextButton(onPressed: () { testConnectivity(false); },
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.white)),
                    child: const Text("Tester à nouveau", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
