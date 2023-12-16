import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/MyUser.dart';
import 'package:image_to_text/LocalBdManager/LocalBdManager.dart';
import 'package:image_to_text/UI/Home/HomePage.dart';
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

  void createUserPassword(MyUser? myUser) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AuthentificationPage(title: "Créer un code PIN",
        onCompleted: (value) async {
          // bool result = true;
          Navigator.pop(context, value);
          return true;
        },),)).then((password) async {
          if (password != null) {
            await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AuthentificationPage(title: "Confirmer le code PIN", onCompleted: (newPass) async {
          if (newPass == password) {
            Navigator.pop(context, password);
            return true;
          } else {
            showUniversalSnackBar(context: context, message: "Les deux codes PIN ne correspondent pas");
            return false;
          }
        },),)).then((myPassword) async {
        if (myPassword != null) {
          MyUser newUser = MyUser(id: myUser!.id!, password: password);
          await newUser.createOrUpdateUser(route: "/update_user").then((value) {
            LocalBdManager.localBdChangeSetting("password", "1");
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage(),));
          }).onError((error, stackTrace) {
            showUniversalSnackBar(context: context, message: "Une erreur s'est produite");
          });
        } else {
          createUserPassword(myUser);
        }
      });
          } else {
            createUserPassword(myUser);
          }
    });
  }

  void onCreateUserTap() async {
    MyUser myUser = MyUser(firstName: firstNameController.text,
        lastName: lastNameController.text, login: loginController.text);
    await myUser.createOrUpdateUser().then((myUser) async {
      createUserPassword(myUser);
    }).onError((error, stackTrace) {
      showUniversalSnackBar(context: context, message: "Une erreur s'est produite");

    });
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
