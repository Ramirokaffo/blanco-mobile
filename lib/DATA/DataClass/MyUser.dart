import 'package:dio/dio.dart';

import '../../LocalBdManager/LocalBdManager.dart';
import '../HttpRequest/ApiHelper.dart';
import '../HttpRequest/RouteFile.dart';
import '../HttpRequest/dioConstructor.dart';


class MyUser {

  late int? id;
  late String? firstName;
  late String? lastName;
  late String? role;
  late String? login;
  late String? password;
  late String? email;
  late String? phoneNumber;
  late String? createAt;
  late bool? isValid;
  late bool? isActive;
  static MyUser currentUser = MyUser(isValid: false);
  // Token DRF renvoyé par /api/auth/login/ (en-tête "Authorization: Token ...")
  static String? token;

  MyUser({
    this.id,
    this.firstName,
    this.lastName,
    this.role,
    this.login,
    this.phoneNumber,
    this.createAt,
    this.isValid,
    this.isActive,
    this.email,
    this.password,
});

  MyUser.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    firstName = map["firstname"];
    lastName = map["lastname"];
    email = map["email"];
    login = map["username"];
    createAt = map["create_at"];
    isActive = toBool(map["is_active"]);
    role = map["role"];
    phoneNumber = map["phone_number"];
    isValid = true;
  }

  Map<String, dynamic> toSendMapDto() {
    Map<String, dynamic> data = {
      "username": login,
      "firstname": firstName,
      "lastname": lastName,
      "phone_number": phoneNumber,
      "password": password,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }

  String encodeToLocalSave() {
    return [id, firstName, lastName, phoneNumber, email, role, createAt, login, (isActive?? false)? 1: 0].join("!#&");
  }



  static  Future<MyUser?> decodeFromLocalSave() async {
    String encodingLocalUser = await LocalBdManager.localBdSelectSetting("user");
    if (encodingLocalUser != "none") {
      List<String> listEncodingLocalUser = encodingLocalUser.split("!#&");
      String? field(int index) {
        if (index >= listEncodingLocalUser.length) return null;
        String value = listEncodingLocalUser[index];
        return value.isEmpty || value == "null"? null: value;
      }
      MyUser myUser = MyUser();
      myUser.id = int.tryParse(listEncodingLocalUser[0]);
      myUser.firstName = field(1);
      myUser.lastName = field(2);
      myUser.phoneNumber = field(3);
      myUser.email = field(4);
      myUser.role = field(5);
      myUser.createAt = field(6);
      myUser.login = field(7);
      myUser.isActive = field(8) != "0";
      myUser.isValid = true;
      return myUser;
    } else {
      return null;
    }
  }

  static Future loadToken() async {
    String savedToken = await LocalBdManager.localBdSelectSetting("token");
    token = savedToken != "none"? savedToken: null;
  }

  static Future _saveSession(MyUser myUser, String? newToken) async {
    await LocalBdManager.localBdChangeSetting("user", myUser.encodeToLocalSave());
    await LocalBdManager.localBdChangeSetting("login", myUser.login?? "none");
    currentUser = myUser;
    currentUser.isValid = true;
    if (newToken != null) {
      token = newToken;
      await LocalBdManager.localBdChangeSetting("token", newToken);
    }
  }

  static Future logOut() async {
    token = null;
    await LocalBdManager.localBdChangeSetting("token", "none");
  }


  static Future<MyUser?> getCurrentUser({CancelToken? cancelToken}) async {
    if (currentUser.isValid!) {
      return currentUser;
    }
      MyUser? myUser = await decodeFromLocalSave();
      if (myUser != null) {
        await loadToken();
        currentUser = myUser;
        currentUser.isValid = true;
        return currentUser;
      }
    return null;
  }


  static Future<MyUser?> reloadUser({CancelToken? cancelToken}) async {
    MyUser? myUser = await decodeFromLocalSave();
    if (myUser == null || myUser.id == null) return null;
    var dio = dioConstructor(
        await LocalBdManager.localBdSelectSetting("serverUri"));
    var response = await dio.get(userByIdRoute(myUser.id!), cancelToken: cancelToken);
    if (response.statusCode == 200) {
      await _saveSession(MyUser.fromMap(response.data), null);
      return currentUser;
    }
    throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
  }

  static Future testServerConnection({String? serverUri, CancelToken? cancelToken}) async {
    String newServerUri = serverUri?? await LocalBdManager.localBdSelectSetting("serverUri");
    var dio = dioConstructor(newServerUri, needAuthorisation: false);
    var response = await dio.get(testConnectionRoute, cancelToken: cancelToken);
    if (response.statusCode == 200 && response.data is Map) {
      if (response.data["status"] == 1) {
        await LocalBdManager.localBdChangeSetting("serverUri", newServerUri);
      }
        return response.data;
    }
    return {"status": 0};
  }

  /// Connexion avec le login enregistré localement.
  /// Renvoie {"status": 1, ...} en cas de succès, sinon {"status": 0, "message": ...}.
  static Future logUserIn(String password, {CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), needAuthorisation: false);
    var response = await dio.post(loginRoute, data: {
      "username": await LocalBdManager.localBdSelectSetting("login"),
      "password": password,
    }, cancelToken: cancelToken);
    if (response.statusCode == 200 && response.data["status"] == 1) {
      await _saveSession(MyUser.fromMap(response.data["user"]), response.data["token"]);
      return response.data;
    }
    if (response.statusCode == 429) {
      return {"status": 0, "message": extractErrorMessage(response.data, fallback: "Trop de tentatives, réessayez plus tard")};
    }
    return {"status": 0, "message": extractErrorMessage(response.data, fallback: "Login ou mot de passe incorrect")};
  }

  /// Le serveur n'expose plus la recherche de compte sans authentification :
  /// on mémorise le login, la vérification se fait à la connexion.
  static Future setLocalLogin(String login) async {
    await LocalBdManager.localBdChangeSetting("login", login.trim());
    currentUser.login = login.trim();
  }

  /// Inscription depuis l'application : le compte est créé inactif côté
  /// serveur et doit être activé par un administrateur.
  Future<Map<String, dynamic>> createAccount({String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), needAuthorisation: false);
    var response = await dio.post(createUserRoute, data: toSendMapDto());
    if ([201, 200].contains(response.statusCode) && response.data["status"] == 1) {
      MyUser myUser = MyUser.fromMap(response.data["user"]);
      await LocalBdManager.localBdChangeSetting("user", myUser.encodeToLocalSave());
      await LocalBdManager.localBdChangeSetting("login", myUser.login?? "none");
      return response.data;
    }
    throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
  }

  Future<MyUser> updateUser({String? serverUri, String? currentPassword}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"));
    Map<String, dynamic> data = toSendMapDto();
    if (currentPassword != null) data["current_password"] = currentPassword;
    var response = await dio.patch(updateUserRoute(id!), data: data);
    if (response.statusCode == 200 && response.data["status"] == 1) {
      // Un changement de mot de passe révoque l'ancien token : le serveur en renvoie un nouveau
      await _saveSession(MyUser.fromMap(response.data["user"]), response.data["token"]);
      return currentUser;
    }
    throw ApiException(extractErrorMessage(response.data), statusCode: response.statusCode);
  }

}
