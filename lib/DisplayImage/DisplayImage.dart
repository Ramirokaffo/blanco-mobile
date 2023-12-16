import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DisplaysImage extends StatefulWidget {
  final String image;
  final bool? islocal;
  final String title;

  const DisplaysImage(
      {Key? key,
      required this.image,
      bool this.islocal = false,
      required this.title})
      : super(key: key);

  @override
  _DisplaysImage createState() => _DisplaysImage();
}

class _DisplaysImage extends State<DisplaysImage>
    with SingleTickerProviderStateMixin {
  bool onlyImgIsVisible = true;
  // Offset offset = Offset.zero;
  // final TransformationController transController = TransformationController();
  // late TapDownDetails doubleTaDetails;
  //
  //
  // late TransformationController controller;
  // late AnimationController animationController;
  // Animation<Matrix4>? animation;

  late TransformationController controller;
  late AnimationController animationController;
  Animation<double>? animation;
  late void Function() animationListener;
  List<double> doubleTapScales = [1.0, 3.0];

  final GlobalKey<ExtendedImageGestureState> gestureKey =
      GlobalKey<ExtendedImageGestureState>();

  @override
  void initState() {
    super.initState();
    print(widget.image);
    controller = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => true);
  }

  void onDoubleTap(ExtendedImageGestureState state) {
    ///you can use define pointerDownPosition as you can,
    ///default value is double tap pointer down postion.
    var pointerDownPosition = state.pointerDownPosition;
    double? begin = state.gestureDetails?.totalScale;
    double end;

    //remove old
    animation?.removeListener(animationListener);

    //stop pre
    animationController.stop();

    //reset to use
    animationController.reset();

    if (begin == doubleTapScales[0]) {
      end = doubleTapScales[1];
    } else {
      end = doubleTapScales[0];
    }

    animationListener = () {
      state.handleDoubleTap(
          scale: animation?.value, doubleTapPosition: pointerDownPosition);
    };
    animation =
        animationController.drive(Tween<double>(begin: begin, end: end));

    animation?.addListener(animationListener);

    animationController.forward();
  }

  Widget? loadStateChanged(ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.loading:
        final ImageChunkEvent? loadingProgress = state.loadingProgress;
        final double? progress = loadingProgress?.expectedTotalBytes != null
            ? loadingProgress!.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null;
        // _controller.reset();
        return Stack(
          children: [
            // Image.asset(
            //   "imagePlaceholder",
            //   fit: BoxFit.contain,
            // ),
            Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: progress,
              ),
            )
          ],
        );
        // }
        break;

      ///if you don't want override completed widget
      ///please return null or state.completedWidget
      //return null;
      //return state.completedWidget;
      case LoadState.completed:
        animationController.forward();
        return null;
        FadeTransition(
          // opacity: Animation.fromValueListenable(),
          opacity: animationController,
          child: ExtendedRawImage(
            image: state.extendedImageInfo?.image,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
          ),
        );
        break;
      case LoadState.failed:
        // _controller.reset();
        return GestureDetector(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                "imagePlaceholder",
                fit: BoxFit.contain,
              ),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "load image failed, click to reload",
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          onTap: () {
            state.reLoadImage();
          },
        );
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    controller.dispose();
    animationController.dispose();
  }

  Widget imageFromNetwork() {
    return Hero(
        tag: int.tryParse(widget.image
                .split("image_picker")
                .toList()[0]
                .split("/")
                .toList()
                .last) ??
            widget.image
                .split("image_picker")
                .toList()[0]
                .split("/")
                .toList()
                .last,
        child: ExtendedImage.network(
          widget.image,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.contain,
          cache: true,
          timeRetry: const Duration(milliseconds: 10),
          timeLimit: const Duration(milliseconds: 10),
          mode: ExtendedImageMode.gesture,
          extendedImageGestureKey: gestureKey,
          initGestureConfigHandler: (state) {
            return GestureConfig(
              minScale: 0.9,
              animationMinScale: 0.7,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: false,
              initialAlignment: InitialAlignment.center,
              reverseMousePointerScrollDirection: true,
              gestureDetailsIsChanged: (GestureDetails? details) {},
            );
          },
          onDoubleTap: onDoubleTap,
          loadStateChanged: loadStateChanged,
        ));
  }

  Widget imageFromLocalFile() {
    return Hero(
        tag: int.tryParse(widget.image
                .split("image_picker")
                .toList()[0]
                .split("/")
                .toList()
                .last) ??
            widget.image
                .split("image_picker")
                .toList()[0]
                .split("/")
                .toList()
                .last,
        child: ExtendedImage.file(
          File(widget.image),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          extendedImageGestureKey: gestureKey,
          initGestureConfigHandler: (state) {
            return GestureConfig(
              minScale: 0.9,
              animationMinScale: 0.7,
              maxScale: 3.0,
              animationMaxScale: 3.5,
              speed: 1.0,
              inertialSpeed: 100.0,
              initialScale: 1.0,
              inPageView: false,
              initialAlignment: InitialAlignment.center,
              reverseMousePointerScrollDirection: true,
              gestureDetailsIsChanged: (GestureDetails? details) {
                print(details?.totalScale);
              },
            );
          },
          onDoubleTap: onDoubleTap,
          loadStateChanged: loadStateChanged,
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (!onlyImgIsVisible) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
          // overlays: SystemUiOverlay.values
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Theme.of(context).colorScheme.primary,
      home: Scaffold(
          backgroundColor: Colors.white,
          body: InkWell(
              onTap: () {
                setState(() {
                  onlyImgIsVisible = !onlyImgIsVisible;
                });
              },
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: widget.islocal == true
                        ? imageFromLocalFile()
                        : imageFromNetwork(),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Wrap(
                      children: [
                        AnimatedContainer(
                          height: onlyImgIsVisible ? 0 : 80,
                          color: Theme.of(context).colorScheme.primary,
                          duration: const Duration(milliseconds: 500),
                          child: onlyImgIsVisible
                              ? null
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                        )),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: FittedBox(
                                        child: Text(widget.title,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20)),
                                      ),
                                    ),
                                    Visibility(
                                      visible: !(widget.islocal ?? false),
                                      child: IconButton(
                                          onPressed: () async {
                                            // if (widget.islocal == false) {
                                            //   await imageDownloadViaLink(
                                            //       widget.image)
                                            //       .then((value) {
                                            //     print("Non non: $value");
                                            //     showSimpleSnackbar(
                                            //         rootScaffoldMessengerKey:
                                            //         rootScaffoldMessengerKey,
                                            //         message:
                                            //         "L'image a été telechargée avec succès ",
                                            //         context: context);
                                            //   }).onError((error, stackTrace) {
                                            //     print("Il ya erreur: $error");
                                            //     showUniversalSnackBar(
                                            //         context: context,
                                            //         message:
                                            //         "Une erreur est suvenue lors du téléchargement de l'image");
                                            //     showSimpleSnackbar(
                                            //         rootScaffoldMessengerKey:
                                            //         rootScaffoldMessengerKey,
                                            //         message:
                                            //         "Une erreur est suvenue lors du téléchargement de l'image",
                                            //         context: context);
                                            //   });
                                            // } else {}
                                          },
                                          icon: const Icon(
                                            Icons.download,
                                            color: Colors.white,
                                          )),
                                    )
                                  ],
                                ),
                        ),
                      ],
                    ),
                  )
                ],
              ))),
    );
  }
  // Widget build(BuildContext context) {
  //   // final imageProvider = Image.network("https://picsum.photos/id/1001/5616/3744").image;
  //
  //
  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     home: Scaffold(
  //       backgroundColor: Colors.white,
  //       appBar: !onlyImgIsVisible? null: AppBar(
  //         title: Text(
  //           widget.title,
  //           style: const TextStyle(color: Colors.white),
  //         ),
  //         centerTitle: true,
  //         backgroundColor: themeColor,
  //         leading: IconButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             icon: const Icon(
  //               Icons.arrow_back_ios,
  //               color: Colors.white,
  //             )),
  //         actions: [
  //           Visibility(
  //             visible: !(widget.islocal?? false),
  //             child: IconButton(
  //                 onPressed: () async {
  //                   // if (widget.islocal == false) {
  //                   //       await imageDownloadViaLink(widget.image).then((value) {
  //                   //         print("Non non: $value");
  //                   //         showSimpleSnackbar(
  //                   //             rootScaffoldMessengerKey: rootScaffoldMessengerKey,
  //                   //             message: "L'image a été telechargée avec succès ",
  //                   //             context: context);
  //                   //       }).onError((error, stackTrace) {
  //                   //         print("Il ya erreur: $error");
  //                   //         showUniversalSnackBar(context: context, message: "Une erreur est suvenue lors du téléchargement de l'image");
  //                   //         showSimpleSnackbar(
  //                   //             rootScaffoldMessengerKey: rootScaffoldMessengerKey,
  //                   //             message:
  //                   //             "Une erreur est suvenue lors du téléchargement de l'image",
  //                   //             context: context);
  //                   //       });
  //                   //
  //                   // } else {}
  //                 },
  //                 icon: const Icon(
  //                   Icons.download,
  //                   color: Colors.white,
  //                 )),
  //           )
  //         ],
  //       ),
  //       body: GestureDetector(
  //       onTap: () {
  //         setState(() {
  //           onlyImgIsVisible = !onlyImgIsVisible;
  //         });
  //       },
  //       onDoubleTap: handleDoubleTap,
  //       onDoubleTapDown: ((details) {
  //         print("double tap down");
  //         handleDoubleTapDown(details);
  //       }),
  //       // onVerticalDragDown: (details) {
  //       //   // handleDoubleTapDown(details);
  //       //
  //       // },
  //       onPanUpdate: (details) {
  //         setState(() {
  //           offset = Offset(offset.dx + details.delta.dx,
  //               offset.dy + details.delta.dy);
  //         });
  //         print(details);
  //       },
  //       child: InteractiveViewer(
  //         // onInteractionEnd: ((details) {
  //         //   // print("object");
  //         //   resetAnimation();
  //         // }),
  //         clipBehavior: Clip.none,
  //         transformationController: controller,
  //         // maxScale: 4,
  //         // minScale: 1,
  //         // panEnabled: false,
  //         child: widget.islocal == true
  //             ? Image.file(
  //           File(widget.image),
  //                 width: double.infinity,
  //                 height: double.infinity,
  //           fit: BoxFit.contain,
  //
  //         )
  //             : Hero(
  //               tag: int.tryParse(widget.image.split("image_picker").toList()[0].split("/").toList().last)?? widget.image.split("image_picker").toList()[0].split("/").toList().last,
  //               child: FadeInImage.assetNetwork(
  //                 fit: BoxFit.contain,
  //                 width: double.infinity,
  //                 height: double.infinity,
  //                   placeholder: imagePlaceholder, image: widget.image,
  //                 imageErrorBuilder: (context, object, stackTrace) {
  //                   return Container(
  //                     width: MediaQuery.of(context).size.width,
  //                     height: 200,
  //                     color: Colors.white,
  //                     child: Column(
  //                       children: const [
  //                         SizedBox(
  //                           height: 100,
  //                         ),
  //                         Center(
  //                             child: Text(
  //                               "Erreur lors du chargement de l'image...",
  //                               style: TextStyle(color: Colors.red),
  //                             )),
  //                       ],
  //                     ),
  //                   );
  //                 },),
  //             ),
  //       ),
  //       ),
  //     ),
  //   );
  // }
}
