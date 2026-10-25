import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/MyUser.dart';
import 'package:image_to_text/DATA/HttpRequest/ApiHelper.dart';
import 'package:image_to_text/UI/Login/Component/AuthentificationPage.dart';

import '../../MiniWidget/UniversalSnackBar.dart';

class CreateFormPage extends StatefulWidget {
  const CreateFormPage({Key? key, required this.onAccountAlreadyExist}) : super(key: key);
  final Function onAccountAlreadyExist;

  @override
  State<CreateFormPage> createState() => _CreateFormPageState();
}

class _CreateFormPageState extends State<CreateFormPage> {

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController loginController = TextEditingController();

  Widget oneFormWidget(TextEditingController controller, String title, String hinText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
        const SizedBox(height: 10,),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
          ),
          child: TextFormField(
            maxLength: 10,
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              hintText: hinText,
            ),
          ),
        ),
      ],
    );
  }

  /// Saisie + confirmation du mot de passe, puis création du compte.
  /// Le serveur crée le compte inactif : un administrateur doit l'activer
  /// avant la première connexion.
  void createUserPassword(MyUser myUser) async {
    String? password = await Navigator.of(context).push<String>(MaterialPageRoute(
      builder: (context) => AuthentificationPage(title: "Créer un mot de passe",
        login: myUser.login, checkStrength: true,
        onCompleted: (value) async {
          Navigator.pop(context, value);
          return true;
        },),));
    if (password == null || !mounted) return;
    String? confirmedPassword = await Navigator.of(context).push<String>(MaterialPageRoute(
        builder: (context) => AuthentificationPage(title: "Confirmer le mot de passe",
          login: myUser.login,
          onCompleted: (newPass) async {
          if (newPass == password) {
            Navigator.pop(context, password);
            return true;
          } else {
            showUniversalSnackBar(context: context, message: "Les deux mots de passe ne correspondent pas");
            return false;
          }
        },),));
    if (confirmedPassword == null || !mounted) return;
    myUser.password = confirmedPassword;
    await myUser.createAccount().then((result) {
      if (!mounted) return;
      showUniversalSnackBar(context: context, message: result["message"]?? "Compte créé avec succès", backgroundColor: Colors.green);
      widget.onAccountAlreadyExist();
    }).onError((error, stackTrace) {
      showUniversalSnackBar(context: context, message: errorMessageOf(error));
    });
  }

  void onCreateUserTap() async {
    if (loginController.text.trim().isEmpty) {
      showUniversalSnackBar(context: context, message: "Le login est obligatoire");
      return;
    }
    MyUser myUser = MyUser(firstName: firstNameController.text,
        lastName: lastNameController.text, login: loginController.text.trim());
    createUserPassword(myUser);
  }


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
          oneFormWidget(firstNameController, "Nom", "Entrez votre nom ici"),
          const SizedBox(height: 10,),
          oneFormWidget(lastNameController, "Prénom", "Entrez votre prénom ici"),
          const SizedBox(height: 10,),
          oneFormWidget(loginController, "Login", "Entrez votre login ici"),
          const SizedBox(height: 20,),
          Container(
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10)
            ),
            child: InkWell(
              onTap: (){
                onCreateUserTap();
              },
              child: const Text("Créer mon compte",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,),
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
              child: TextButton(onPressed: (){
                widget.onAccountAlreadyExist();
              }, child: Text("J'ai déjà un compte")))
        ],
      ),
    );

  }
}
