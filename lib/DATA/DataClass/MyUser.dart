

import 'package:dio/dio.dart';

import '../../LocalBdManager/LocalBdManager.dart';
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
    isActive = map["is_active"] == 1;
    role = map["role"];
    phoneNumber = map["phone_number"];
    isValid = true;
  }

  Map<String, dynamic> toSendMapDto() {
    return {
      "id": id,
      "firstname": firstName,
      "lastname": lastName,
      "username": login,
      "password": password,
      "phone_number": phoneNumber,
      "email": phoneNumber,
    };
  }

  String encodeToLocalSave() {
    return [id, firstName, lastName, phoneNumber, email, role, createAt].join("!#&");
  }



  static  Future<MyUser?> decodeFromLocalSave() async {
    String encodingLocalUser = await LocalBdManager.localBdSelectSetting("user");
    if (encodingLocalUser != "none") {
      List<String> listEncodingLocalUser = encodingLocalUser.split("!#&");
      MyUser myUser = MyUser();
      myUser.id = int.parse(listEncodingLocalUser[0]);
      myUser.firstName = listEncodingLocalUser[1];
      myUser.lastName = listEncodingLocalUser[2];
      myUser.phoneNumber = listEncodingLocalUser[3];
      myUser.email = listEncodingLocalUser[4];
      myUser.role = listEncodingLocalUser[5];
      myUser.createAt = listEncodingLocalUser[6];
      myUser.isValid = true;
      return myUser;
    } else {
      return null;
    }
  }




  static Future<MyUser?> getCurrentUser({CancelToken? cancelToken}) async {
    if (currentUser.isValid!) {
      return currentUser;
    }
      MyUser? myUser = await decodeFromLocalSave();
      if (myUser != null) {
        currentUser = myUser;
        currentUser.isValid = true;
        return currentUser;
      }
    return null;
  }


  static Future<MyUser?> reloadUser({CancelToken? cancelToken}) async {
    MyUser? myUser = await decodeFromLocalSave();
    if (myUser != null) {
      var dio = dioConstructor(
          await LocalBdManager.localBdSelectSetting("serverUri"));
      dio.get("/get_user_by_id/${myUser.id}",
              cancelToken: cancelToken)
          .then((response) {
        if (response.statusCode == 200) {
          currentUser = MyUser.fromMap(response.data);
          currentUser.isValid = true;
          return currentUser;
        }
      });
    }
    // }
    return null;
  }

  static Future testServerConnection({String? serverUri, CancelToken? cancelToken}) async {
    String newServerUri = serverUri?? await LocalBdManager.localBdSelectSetting("serverUri");
    var dio = dioConstructor(newServerUri);
    var response = await dio.get("/test_connexion", cancelToken: cancelToken);
    if (response.statusCode == 200) {
      if (response.data["status"] == 1) {
        LocalBdManager.localBdChangeSetting("serverUri", newServerUri);
      }
        return response.data;
    }
  }

  static Future logUserIn(String password, {CancelToken? cancelToken, String? serverUri}) async {
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"));
    var response = await dio.get("/login/${await LocalBdManager.localBdSelectSetting("login")}/$password", cancelToken: cancelToken);
    try {
      if (response.statusCode == 200) {
        if (response.data["status"] == 1) {
          MyUser myUser = MyUser.fromMap(response.data["user"]);
          LocalBdManager.localBdChangeSetting("user", myUser.encodeToLocalSave());
          MyUser.currentUser = myUser;
        }
        return response.data;
      }
    } catch (e) {
      throw Exception(e);
    }

  }

  static Future findUserByLogin(String login, {CancelToken? cancelToken}) async {
    var dio = dioConstructor(await LocalBdManager.localBdSelectSetting("serverUri"));
    var response = await dio.get("/get_staff_by_login/$login", cancelToken: cancelToken);
    try {
      if (response.statusCode == 200) {
        if (response.data["status"] == 1) {
          MyUser myUser = MyUser.fromMap(response.data["user"]);
          LocalBdManager.localBdChangeSetting("user", myUser.encodeToLocalSave());
          MyUser.currentUser = myUser;
          LocalBdManager.localBdChangeSetting("login", myUser.login?? "none");
        }
        return response.data;
      }
    } catch (e) {
      throw Exception(e);
    }
    return null;

  }

  static Future makeGetRequest(String serverUri, String path, {CancelToken? cancelToken}) async {
    var dio = dioConstructor(serverUri);
    var response = await dio.get(path, cancelToken: cancelToken);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      // return
    }
  }




  Future<MyUser?> createOrUpdateUser({String? route, String? serverUri}) async {
    try {
      CancelToken cancelToken = CancelToken();
    var dio = dioConstructor(serverUri?? await LocalBdManager.localBdSelectSetting("serverUri"), needAuthorisation: false);
    print(toSendMapDto());
    var response = await dio.post(route?? "/create_user", data: toSendMapDto(), cancelToken: cancelToken);
    print(response.data);
    print(response.extra);
    print(response.statusMessage);
    if ([201, 200].contains(response.statusCode)) {
        MyUser myUser = MyUser.fromMap(response.data["user"]);
        LocalBdManager.localBdChangeSetting("user", myUser.encodeToLocalSave());
        LocalBdManager.localBdChangeSetting("login", myUser.login?? "none");
        currentUser  = myUser;
        currentUser.isValid = true;
        return myUser;
    } else {
      throw Exception("Une erreur s'est produite");
    }
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

}