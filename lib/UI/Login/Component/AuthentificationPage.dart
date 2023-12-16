import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/MyUser.dart';
import 'package:image_to_text/LocalBdManager/LocalBdManager.dart';
import 'package:image_to_text/UI/MiniWidget/showSimpleDialog.dart';

import '../LoginPage.dart';

class AuthentificationPage extends StatefulWidget {
  final String title;
  final String? password;
  final String? login;
  final Future<bool> Function(String value)? onCompleted;
  const AuthentificationPage({Key? key, required this.title, this.password, this.onCompleted, this.login}) : super(key: key);

  @override
  State<AuthentificationPage> createState() => _AuthentificationPageState();
}

class _AuthentificationPageState extends State<AuthentificationPage> {

  late TextEditingController currentController;
  int currentIndex = 0;
  late List<TextEditingController> listController;
  late String _login;

  Widget oneValue(int index, TextEditingController controller) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.1)
      ),
      child: TextFormField(
        // maxLength: 1,
        controller: controller,
        obscureText: true,
        onTap: (){
          currentIndex = index;
        },
        onChanged: (value)  {
          print(value);
          FocusScope.of(context).nextFocus();
          currentController = listController[++index];
          currentIndex++;
          print(index);

        },
        autofocus: index == 0,
        keyboardType: TextInputType.none,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
        decoration: const InputDecoration(
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        ),
      ),
    );
  }
  void onFillCompleted() async {
  if (widget.onCompleted != null) {
  if (!(await widget.onCompleted!(listController.map((e) => e.text).toList().join("")))) {
  clearAllEntry();
  }
  }
  return;
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

  void fillForm(String value) async {
    if (currentIndex >= listController.length) {
      onFillCompleted();
    } else if (currentIndex == listController.length - 1) {
      listController[currentIndex++].text = value;
      onFillCompleted();
    } else {
      setState(() {
        listController[currentIndex++].text = value;
      });
      FocusScope.of(context).nextFocus();
    }

  }

  void clearOneEntry() {
    setState(() {
      if (List.generate(listController.length, (index) => index + 1).contains(currentIndex)) {
        print([1, listController.length].contains(currentIndex));
        if (listController[currentIndex-1].text.isNotEmpty) {
          listController[currentIndex--].text = "";
        } else {
          listController[currentIndex-- - 1].text = "";
        }
        FocusScope.of(context).previousFocus();
      }
    });
    print("ici");

  }


  void clearAllEntry() {
    setState(() {
      listController.forEach((element) {element.text = "";});
      currentIndex = 0;
    });
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
    listController = List.generate(5, (index) => TextEditingController());
    currentController = listController[0];
  }
  Widget oneButton(String text, Function onTap, { IconData? icon }) {
    return InkWell(
      onTap: (){
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: icon == null? Colors.white: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).colorScheme.primary)
        ),
        child: icon == null? Text(text,
          style: const TextStyle(color: Colors.black,
              fontWeight: FontWeight.bold, fontSize: 25),): Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
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
                  // const SizedBox(height: 20,),
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
                  const SizedBox(height: 10,),
                  Form(child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: listController.map((e) => oneValue(index++, e)).toList(),)),
                  const SizedBox(height: 30,),
                  Container(
                    height: 380,
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            oneButton("1", () => fillForm("1")),
                            oneButton("2", () => fillForm("2")),
                            oneButton("3", () => fillForm("3")),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            oneButton("4", () => fillForm("4")),
                            oneButton("5", () => fillForm("5")),
                            oneButton("6", () => fillForm("6")),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            oneButton("7", () => fillForm("7")),
                            oneButton("8", () => fillForm("8")),
                            oneButton("9", () => fillForm("9")),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            oneButton("", () => Navigator.pop(context), icon: Icons.arrow_back_sharp),
                            oneButton("0", () => fillForm("8")),
                            oneButton("", () => clearOneEntry(), icon: Icons.clear),
                          ],
                        ),
                      ],
                    ),
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
