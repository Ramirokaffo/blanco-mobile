

import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/MyUser.dart';
import 'package:image_to_text/UI/Home/Component/OneMenuItem.dart';
import 'package:image_to_text/UI/InventoryPage/InventoryPage.dart';
import 'package:image_to_text/UI/MiniWidget/showSimpleDialog.dart';
import 'package:image_to_text/UI/WelcommePage.dart';

import '../../../MiniFunction/GlobalTestConnectivity.dart';

class MyDrawerMenu extends StatefulWidget {
  const MyDrawerMenu({Key? key}) : super(key: key);

  @override
  State<MyDrawerMenu> createState() => _MyDrawerMenuState();
}

class _MyDrawerMenuState extends State<MyDrawerMenu> {

  void goToInventory(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InventoryPage(),));
  }

  void onLogOutTap() {
    showSimpleDialog(title: "Attention !", isimgvisible: true, actionText: "Oui", context: context, message: "Vous êtes sûr de vouloir vous déconnecter de l'application ?", onActionTap: (){
      Navigator.popUntil(context, (route) => false);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WelcomePage(),));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary
            ),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                    ),
                      child: const Icon(Icons.person, size: 100,)),
                  const SizedBox(height: 10,),
                  Text('${MyUser.currentUser.firstName?? ""} ${MyUser.currentUser.lastName?? ""} ${MyUser.currentUser.login == null && MyUser.currentUser.lastName == null? MyUser.currentUser.login: ""}'),

                ],
              )),
          Visibility(
            visible: MyUser.currentUser.role != "guest",
              child: OneMenuItem(titleText: "Inventaire", leadingIcon: Icons.inventory_2_outlined, onTap: goToInventory)),
          Visibility(
            visible: MyUser.currentUser.role == "guest",
            child: OneMenuItem(titleText: "Test de connectivité", leadingIcon: Icons.document_scanner_outlined, onTap: (){
              globalConnectivityTest(context);},),
          ),
          OneMenuItem(titleText: "Déconnexion", leadingIcon: Icons.logout, onTap: onLogOutTap,)
        ],
      ),
    );
  }
}
