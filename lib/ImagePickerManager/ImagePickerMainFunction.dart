import 'package:image_picker/image_picker.dart';

Future<List<XFile>?>? pickImages(dynamic source, {bool pickOne = false}) async {
  List<XFile>? imageToPick;
  final ImagePicker picker = ImagePicker();
  if (pickOne) {
    await picker.pickImage(source: source).then((XFile? image) async {
      if (image != null) {
        imageToPick = [image];
      }
    }).onError((error, stackTrace) {});
    return imageToPick;
  }
  await picker.pickMultiImage().then((List<XFile>? images) async {
    imageToPick = images;
  }).onError((error, stackTrace) {});
  return imageToPick;
}


Future<XFile?>? pickOneVideo(dynamic source) async {
  XFile? imageToPick;
  final ImagePicker picker = ImagePicker();
  await picker.pickVideo(source: source).then((XFile? image) async {
    imageToPick = image;
  }).onError((error, stackTrace) {});
  return imageToPick;
}
