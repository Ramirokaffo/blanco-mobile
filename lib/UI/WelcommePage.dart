
import 'package:flutter/material.dart';
import 'package:image_to_text/UI/Home/HomePage.dart';
import 'package:image_to_text/UI/Login/LoginPage.dart';

import '../DATA/DataClass/MyUser.dart';
import '../LocalBdManager/LocalBdManager.dart';
import '../AppService/BarCodeService.dart';
import 'Login/Component/AuthentificationPage.dart';
import 'MiniWidget/UniversalSnackBar.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  String serverBaseUrl = '';
  bool connexionError = false;

  Widget noConnexionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Oups !", style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold, fontSize: 30),),
          const SizedBox(height: 30,),
          Text("Nous ne parvenons pas à nous connecter au serveur: ${serverBaseUrl.split(":").first}", style: TextStyle(), textAlign: TextAlign.center,),
          const SizedBox(height: 30,),
          TextButton(
            style: ButtonStyle(
              minimumSize: const MaterialStatePropertyAll(Size(300, 50)),
              backgroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
                foregroundColor: const MaterialStatePropertyAll(Colors.white),
                side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.primary))),
              onPressed: (){
                onServerUriReady(serverBaseUrl);
              }, child: const Text("Reessayer")),
          const SizedBox(height: 20,),
          TextButton(
            style: ButtonStyle(
                minimumSize: const MaterialStatePropertyAll(Size(300, 50)),
                side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.primary))),
              onPressed: onRescan, child: const Text("Scanner le code")),
        ],
      ),
    );
  }

void onServerUriReady(String serverUri) async {
  await MyUser.testServerConnection(serverUri: serverUri).then((value) async {
    if (value["status"] == 1) {
      connexionError = false;
      await LocalBdManager.localBdSelectSetting("user").then((user) async {
        if (user != "none") {
          await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) =>
                  AuthentificationPage(title: "Votre mot de passe",
                    onCompleted: (password) async {
                      var status = 0;
                      await MyUser.logUserIn(password, serverUri: serverUri).then((result) {
                        if (result["status"] == 1) {
                          status = 1;
                          Navigator.popUntil(context, (route) => false);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage(),));
                          // showUniversalSnackBar(context: context, message: "Une erreur s'est produite");
                        } else {
                          showUniversalSnackBar(context: context, message: "Login ou mot de passe incorrect");
                        }
                      }).onError((error, stackTrace) {
                        print(error);
                        showUniversalSnackBar(context: context, message: "Une erreur s'est produite");
                      });
                      if (status == 1) {
                        return true;
                      } else {
                        return false;
                      }
                    },)));
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage(initialPage: 1,),));
        }
      });
    } else {
      setState(() {
        connexionError = true;
      });
    }
  }).onError((error, stackTrace) {
    setState(() {
      connexionError = true;
    });
  });
}

void onRescan() async {
  await BarCodeService.scanBarCode(context: context).then((serverUri) async  {
    LocalBdManager.localBdChangeSetting("serverUri", serverUri);
    serverBaseUrl = serverUri;
    onServerUriReady(serverUri);
  }).onError((error, stackTrace) {
    showUniversalSnackBar(context: context, message: "Erreur de scan");
  });
}

  void startAppManager() async {
    await LocalBdManager.localBdSelectSetting("serverUri").then((serverUri) async {
      if (serverUri == "none") {
        onRescan();
      } else {
        serverBaseUrl = serverUri;
        onServerUriReady(serverUri);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startAppManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: connexionError? noConnexionWidget(): Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
              colors: [Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary,
                Colors.white],
              center: Alignment.topLeft,
              radius: 1.1,
              tileMode: TileMode.mirror,
              stops: [0.1, 0.3, 0.1, 0.1])
        ),
        child: Center(
          child: Container(
            // width: MediaQuery.of(context).size.width,
            height: 300,
            width: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle
            ),
              child: const Text("DEL BLANCO",
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 40, fontFamily: "Noto Mono"),)),
        ),
      ),
    );
  }
}

