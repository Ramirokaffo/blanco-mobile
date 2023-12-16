
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'LocalBdManager/LocalBdManager.dart';
import 'StateManager/AddArticlePageState.dart';
import 'StateManager/InventoryPageState.dart';
import 'StateManager/SaleProductPageState.dart';
import 'StateManager/SendDataProgressBarState.dart';
import 'UI/Home/HomePage.dart';
import 'UI/Login/Component/AuthentificationPage.dart';
import 'UI/Login/LoginPage.dart';
import 'UI/WelcommePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await  LocalBdManager.initializeBD();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AddArticlePageState(true)),
        BlocProvider(create: (context) => SendDataProgressBarState(0)),
        BlocProvider(create: (context) => SaleProductPageState(true)),
        BlocProvider(create: (context) => InventoryPageState(true)),
      ],
      child: MaterialApp(
        title: 'DEL BLANCO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        // home: AuthentificationPage(title: 'toti',),
        // home: const HomePage(),
        home: const WelcomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? _image;
  late String extractText = "";
  final picker = ImagePicker();
  Future _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera, );
    if (pickedFile != null) {
      // setState(() {
        _image = XFile(pickedFile.path);
      // });
      _readTextFromImage();

    }
  }

  Future<void> _readTextFromImage() async {
    final inputImage = InputImage.fromFilePath(_image!.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
    await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;
    extractText = text;
    setState(() {

    });
    // print(recognizedText.blocks);
    recognizedText.blocks.forEach((element) {
      print(element.text);
      print("\n.\n.\n.\n.\n.\n.");
    });
    // InputImage.fromFilePath(path)
    textRecognizer.close();
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: Text('Extracted Text'),
    //       content: Text(text),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.pop(context);
    //           },
    //           child: Text('Close'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Visibility(
            //   visible: _image != null,
            //     child: Image.file(File(_image!.path))),
           Visibility(
             visible: extractText.isNotEmpty,
               child: Text(extractText))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _getImageFromGallery();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
