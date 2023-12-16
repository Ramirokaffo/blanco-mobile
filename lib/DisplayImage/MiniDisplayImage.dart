
import 'package:flutter/material.dart';


import 'dart:io';

import 'package:extended_image/extended_image.dart';


class MiniDisplayImage extends StatefulWidget {
  final String image;
  final bool? isLocal;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final bool? isLineDisplay;

  const MiniDisplayImage(
      {Key? key,
        required this.image,
        bool this.isLocal = false, this.height, this.fit, this.width, this.isLineDisplay})
      : super(key: key);

  @override
  _DisplaysImage createState() => _DisplaysImage();
}

class _DisplaysImage extends State<MiniDisplayImage>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => true);
  }


  Widget? loadStateChanged(ExtendedImageState state) {
    switch (state.extendedImageLoadState) {
      case LoadState.loading:
        final ImageChunkEvent? loadingProgress = state.loadingProgress;
        final double? progress = loadingProgress?.expectedTotalBytes != null
            ? loadingProgress!.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!
            : null;
        return Align(
          alignment: Alignment.bottomCenter,
          child: CircularProgressIndicator(
            value: progress,
          ),
        );
      case LoadState.completed:
        _animationController.forward();
        return null;
      case LoadState.failed:
        return GestureDetector(
          child: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary))
            ),
              child: const Icon(Icons.refresh)),
          onTap: () {
            state.reLoadImage();
            print(widget.image);
          },
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  Widget imageFromNetwork() {
    return ClipRRect(
      child: ExtendedImage.network(
        widget.image,
        width: widget.width?? double.infinity,
        height: widget.height,
        fit: widget.fit?? BoxFit.fitWidth,
        borderRadius: BorderRadius.circular(10),
        alignment: Alignment.center,
        cache: true,
        timeRetry: const Duration(milliseconds: 10),
        timeLimit: const Duration(milliseconds: 10),
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: (state) {
          return GestureConfig(
            minScale: 1,
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
        loadStateChanged: loadStateChanged,
      ),
    );
  }

  Widget imageFromLocalFile() {
    return ExtendedImage.file(
      File(widget.image),
      width: widget.width?? 100,
      height: widget.height?? 100,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
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
        );
      },

      loadStateChanged: loadStateChanged,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10)
      ),
      alignment: widget.isLineDisplay?? false? Alignment.center: Alignment.topCenter,
      child: widget.isLocal == true
          ? imageFromLocalFile()
          : imageFromNetwork(),
    );
  }
}
