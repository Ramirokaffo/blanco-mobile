import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/MyUser.dart';
import 'package:image_to_text/UI/Login/Component/AuthentificationPage.dart';
import 'package:image_to_text/UI/Login/Component/FindAccountPage.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../../AppService/BarCodeService.dart';
import '../MiniWidget/UniversalSnackBar.dart';
import 'Component/CreateFormPage.dart';


class LoginPage extends StatefulWidget {
  final int? initialPage;
  const LoginPage({Key? key, this.initialPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  late PageController controller;

  void startAppManager() async {
    await LocalBdManager.localBdSelectSetting("serverUri").then((serverUri) async {
      if (serverUri == "none") {
        await BarCodeService.scanBarCode(context: context).then((serverUri) async  {
          await MyUser.testServerConnection(serverUri: serverUri).then((value) async {
            if (value["status"] == "1") {
              await LocalBdManager.localBdSelectSetting("user").then((user) async {
                if (user != "none") {
                  var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AuthentificationPage(title: "Votre mot de passe")));
                }
              });
            }
          });
        }).onError((error, stackTrace) {
          showUniversalSnackBar(context: context, message: "Erreur de scan");
        });
      }

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = PageController(initialPage: widget.initialPage?? 0);
    // startAppManager();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(60)),
                color: Theme.of(context).colorScheme.primary
              ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("DEL BLANCO", style: TextStyle(color: Colors.white,
                        fontSize: 30, fontWeight: FontWeight.bold),),
                  ],
                )),
          ),
          SizedBox(
            height: 600,
            child: PageView(
              controller: controller,
              children: [
                FindAccountPage(onNoAccount: (){
                  controller.animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.bounceIn);
                },),
                CreateFormPage(onAccountAlreadyExist: (){
                  controller.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.bounceIn);
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
