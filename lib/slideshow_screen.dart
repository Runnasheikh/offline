import 'dart:async';
import 'dart:io';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_carousel_media_slider/carousel_media.dart';
import 'package:flutter_carousel_media_slider/flutter_carousel_media_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slideshow_kiosk/main.dart';
import 'package:video_player/video_player.dart';

class SlideshowScreen extends StatefulWidget {
  final List<String> mediaList;
  final bool mute;
  final int splitCount;
  double rotationAngle;
  final int duration;

  SlideshowScreen({
    Key? key,
    required this.mediaList,
    required this.mute,
    required this.splitCount,
    required this.rotationAngle,
    required this.duration,
  }) : super(key: key);

  static Future<void> saveRotationAngle(double rotationAngle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('rotationAngle', rotationAngle);
  }

  static Future<double?> loadRotationAngle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('rotationAngle');
  }

  @override
  _SlideshowScreenState createState() => _SlideshowScreenState();
}

class _SlideshowScreenState extends State<SlideshowScreen> {
  late List<PageController> _pageControllers;
  final Map<String, VideoPlayerController> _videoControllers = {};
  int _currentPage = 0;
  Timer? _slideshowTimer;

  @override
  void initState() {
    super.initState();
    _pageControllers =
        List.generate(widget.splitCount, (index) => PageController());

    SlideshowScreen.loadRotationAngle().then((savedAngle) {
      setState(() {
        widget.rotationAngle = savedAngle ?? 0.0;
      });
    });
    _startSlideshow();
  }

  @override
  void dispose() {
    _stopSlideshow();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void loadSavedImagePaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedPaths = prefs.getStringList('imagePaths');
    if (savedPaths != null && savedPaths.isNotEmpty) {
      setState(() {
        widget.mediaList.addAll(savedPaths);
      });
    }
  }

  void _startSlideshow() {
    _stopSlideshow(); // Ensure previous slideshow is stopped before starting a new one

    _slideshowTimer =
        Timer.periodic(Duration(seconds: widget.duration), (Timer timer) async {
      setState(() {
        _currentPage = (_currentPage + 1) % widget.mediaList.length;
      });

      for (var i = 0; i < widget.splitCount; i++) {
        _pageControllers[i].animateToPage(
          _currentPage % widget.mediaList.length,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopSlideshow() {
    if (_slideshowTimer != null) {
      _slideshowTimer!.cancel();
      _slideshowTimer = null;
    }
  }
void _disposeVideoControllers() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
  }
  @override
  Widget build(BuildContext context) {
    final List<List<String>> splitMediaList = List.generate(
      widget.splitCount,
      (index) {
        int start = index * widget.mediaList.length ~/ widget.splitCount;
        int end = min(
            (index + 1) * widget.mediaList.length ~/ widget.splitCount,
            widget.mediaList.length);
        return widget.mediaList.sublist(start, end);
      },
    );

    return RotatedBox(
      quarterTurns: (widget.rotationAngle / (pi / 2)).round(),
      child: GestureDetector(
        onLongPress: () {
          _stopSlideshow(); // Stop the slideshow timer
          _disposeVideoControllers(); // Dispose video player controllers
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SelectionScreen(),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildCarousels(splitMediaList),
        ),
      ),
    );
  }

  List<Widget> _buildCarousels(List<List<String>> splitMediaList) {
    return List.generate(
      widget.splitCount,
      (index) {
        if (index < splitMediaList.length) {
          return _buildCarousel(splitMediaList[index], index);
        } else {
          return Container(); // or any other fallback widget
        }
      },
    );
  }

  Widget _buildCarousel(List<String> mediaList, int index) {
    if (mediaList.isEmpty) {
      return Container(); // or any other fallback widget
    }

    List<CarouselMedia> carouselMediaList = mediaList.map((mediaUrl) {
      return CarouselMedia(
        mediaName: 'Media $index',
        mediaUrl: mediaUrl,
        mediaType: mediaUrl.endsWith('.mp4')
            ? CarouselMediaType.video
            : CarouselMediaType.image,
        carouselImageSource: CarouselImageSource.file,
      );
    }).toList();

    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: FlutterCarouselMediaSlider(
          carouselMediaList: carouselMediaList,
          onPageChanged: (index) {
            debugPrint('Page Changed: $index');
          },
        ),
     ),
);
}
}