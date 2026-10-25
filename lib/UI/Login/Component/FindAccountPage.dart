import 'package:flutter/material.dart';

import '../../../DATA/DataClass/MyUser.dart';
import '../../Home/HomePage.dart';
import '../../MiniWidget/UniversalSnackBar.dart';
import 'AuthentificationPage.dart';

class FindAccountPage extends StatefulWidget {

  final Function onNoAccount;
  const FindAccountPage({Key? key, required this.onNoAccount}) : super(key: key);

  @override
  State<FindAccountPage> createState() => _FindAccountPageState();
}

class _FindAccountPageState extends State<FindAccountPage> {

TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topRight: Radius.circular(60))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30,),
          const Text("Login", style: TextStyle(fontWeight: FontWeight.bold),),
          const SizedBox(height: 20,),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                hintText: "Entrez votre login ici",
              ),
            ),
          ),
          const SizedBox(height: 40,),
          Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10)
            ),
            child: InkWell(
              onTap: () async {
                if (controller.text.trim().isEmpty) {
                  showUniversalSnackBar(context: context, message: "Veuillez entrer votre login");
                  return;
                }
                // Le login est vérifié par le serveur au moment de la connexion
                await MyUser.setLocalLogin(controller.text);
                if (!context.mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                      AuthentificationPage(title: "Votre mot de passe",
                        login: controller.text.trim(),
                        onCompleted: (password) async {
                          var status = 0;
                          await MyUser.logUserIn(password).then((result) {
                            if (result["status"] == 1) {
                              status = 1;
                              Navigator.popUntil(context, (route) => false);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage(),));
                            } else {
                              showUniversalSnackBar(context: context, message: result["message"]?? "Login ou mot de passe incorrect");
                            }
                          }).onError((error, stackTrace) {
                            showUniversalSnackBar(context: context, message: "Une erreur s'est produite");
                          });
                          return status == 1;
                        },)));
              },
              child: const Text("Retrouver mon compte",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,),
            ),
          ),
          Container(
              alignment: Alignment.bottomRight,
              child: TextButton(onPressed: (){
                widget.onNoAccount();
              }, child: const Text("Je n'ai pas de compte")))

        ],
      ),
    );

  }
}


