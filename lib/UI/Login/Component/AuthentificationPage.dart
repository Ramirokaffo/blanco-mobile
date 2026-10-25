import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/MyUser.dart';
import 'package:image_to_text/LocalBdManager/LocalBdManager.dart';

import '../LoginPage.dart';

/// Saisie du mot de passe. Le serveur Django applique ses règles de mot de
/// passe (8 caractères minimum, pas uniquement des chiffres) : l'ancien code
/// PIN à 5 chiffres est remplacé par un mot de passe classique.
class AuthentificationPage extends StatefulWidget {
  final String title;
  final String? password;
  final String? login;
  final Future<bool> Function(String value)? onCompleted;
  /// Contrôle local de robustesse (création de compte)
  final bool checkStrength;
  const AuthentificationPage({Key? key, required this.title, this.password, this.onCompleted, this.login, this.checkStrength = false}) : super(key: key);

  @override
  State<AuthentificationPage> createState() => _AuthentificationPageState();
}

class _AuthentificationPageState extends State<AuthentificationPage> {

  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _login;
  bool _obscureText = true;
  bool _isSending = false;

  void onFillCompleted() async {
    if (!_formKey.currentState!.validate() || _isSending) return;
    if (widget.onCompleted != null) {
      setState(() {_isSending = true;});
      bool success = await widget.onCompleted!(_passwordController.text);
      if (!mounted) return;
      setState(() {_isSending = false;});
      if (!success) {
        clearAllEntry();
      }
    }
  }

void _onLoginTap() {
    TextEditingController controller = TextEditingController(text: _login);
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text("Changer de login"),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
          ),
        ),
        actions: [
          TextButton(onPressed: (){Navigator.pop(context);}, child: Text("Annuler")),
          TextButton(onPressed: () async {
            MyUser.currentUser.login = controller.text;
            _login = controller.text;
            LocalBdManager.localBdChangeSetting("login", controller.text);
            Navigator.of(context).pop();
            setState(() {});
          }, child: const Text("Ok"))
        ],

      );
    },);
}

  void clearAllEntry() {
    setState(() {
      _passwordController.text = "";
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Ce champs est obligatoire !";
    }
    if (widget.checkStrength) {
      if (value.length < 8) {
        return "Au moins 8 caractères";
      }
      if (RegExp(r'^\d+$').hasMatch(value)) {
        return "Le mot de passe ne peut pas contenir uniquement des chiffres";
      }
    }
    return null;
  }

void getLocalLogin() async {
    LocalBdManager.localBdSelectSetting("login").then((value) {
      if (value != "none") {
        setState(() {
          _login = value;
        });
      }
    });
}


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _login = widget.login?? "";
    if (widget.login == null) {
      getLocalLogin();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
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
            child: Container(
              height: 500,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(60))
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  Container(
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold,), textAlign: TextAlign.left,),
                          InkWell(
                            onTap: _onLoginTap,
                              child: Text(_login, style: const TextStyle(fontWeight: FontWeight.bold,), textAlign: TextAlign.left,)),
                        ],
                      )),
                  const SizedBox(height: 20,),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      autofocus: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      validator: _validatePassword,
                      onFieldSubmitted: (value) => onFillCompleted(),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                        hintText: "Mot de passe",
                        helperText: widget.checkStrength? "Au moins 8 caractères, pas uniquement des chiffres": null,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText? Icons.visibility: Icons.visibility_off),
                          onPressed: () => setState(() {_obscureText = !_obscureText;}),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30,),
                  Row(
                    children: [
                      IconButton(
                        style: ButtonStyle(side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.primary))),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_sharp),
                      ),
                      const SizedBox(width: 20,),
                      Expanded(
                        child: InkWell(
                          onTap: onFillCompleted,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: _isSending? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))):
                            const Text("Valider",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: (){
                        Navigator.popUntil(context, (route) => false);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage(initialPage: 1,),));
                      }, child: const Text("Nouveau compte")),
                    ],
                  )

                ],
              ),
            ),
          )
        ],
      ),
    );

    // return ;
  }
}
