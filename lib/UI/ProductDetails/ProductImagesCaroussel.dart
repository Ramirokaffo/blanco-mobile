
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_to_text/DATA/DataClass/ProductImage.dart';

import '../../DisplayImage/DisplayImage.dart';
import '../../DisplayImage/MiniDisplayImage.dart';


class ArticleImagesCarousel extends StatefulWidget {
  final List<ProductImage> images;
  const ArticleImagesCarousel({Key? key, required this.images}) : super(key: key);

  @override
  State<ArticleImagesCarousel> createState() => _ArticleImagesCarouselState();
}

class _ArticleImagesCarouselState extends State<ArticleImagesCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        if (_currentPage == widget.images.length - 1) {
          _currentPage = 0;
          _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        } else {
            _pageController.animateToPage(++_currentPage, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
          return InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return DisplaysImage(image: widget.images[index].url!, title: "", islocal: false);
              }, ));
            },
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white
              ),
              child: MiniDisplayImage(image: widget.images[index].url!, isLocal: false, isLineDisplay: true, fit: BoxFit.contain,)
            ),
          );
        },
        onPageChanged: (value) {
            setState(() {
              _currentPage = int.parse(value.toString());
            });
        },),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20)
            ),            
            child: Text("${_currentPage + 1}/${widget.images.length}"),
          ),
        )
      ],
    );
  }
}
