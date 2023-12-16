
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocalSocketService {
  static late WebSocketChannel channel;
  static bool isConnected = false;

 static Future connectToWebSocketServer(BuildContext context, String uri) async {
    try {
      channel = WebSocketChannel.connect(Uri.parse('ws://$uri'),);
      print('Connexion websocket établie $uri');

      channel.stream.listen((data) {
        print('Données reçues : $data');
        // Traitement des données reçues
      }, onDone: () {
        print('Connexion websocket fermée');
        isConnected = false;
      }).onError((object, stackTrace){
        print("object: $object");
        print("stackTrace: $stackTrace");
      });
      // Envoi de données
      channel.sink.add('Bonjour');
      isConnected = true;
      return true;
    } catch (e) {
      print("Erreur ici: $e");
      isConnected = false;
      return false;
    }
    }
}