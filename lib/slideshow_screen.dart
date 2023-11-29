import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slideshow_kiosk/main.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';

class SlideshowScreen extends StatefulWidget {
  List mediaList;
  final bool mute;
  final int splitCount;
  // final String orientation;
  final double rotationAngle;
  final int duration;

  SlideshowScreen({
    required this.mediaList,
    required this.mute,
    required this.splitCount,
    // required this.orientation,
    required this.rotationAngle,
    required this.duration,
  });

  @override
  _SlideshowScreenState createState() => _SlideshowScreenState();
}

class _SlideshowScreenState extends State<SlideshowScreen> {
  late List<PageController> _pageControllers;
  List<VideoPlayerController> _videoControllers = [];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageControllers =
        List.generate(widget.splitCount, (index) => PageController());
    // loadSavedImagePaths();
    _startSlideshow();
  }

  void loadSavedImagePaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedPaths = prefs.getStringList('imagePaths');
    if (savedPaths != null && savedPaths.isNotEmpty) {
      widget.mediaList = savedPaths;
    }
  }

  void _startSlideshow() async {
    Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      if (_currentPage < widget.mediaList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      String mediaPath = widget.mediaList[_currentPage];
      if (mediaPath.endsWith('.mp4')) {
        int duration = await _getVideoDuration(mediaPath);
        timer.cancel();
        Timer(Duration(seconds: duration), () {
          _startSlideshow();
        });
      } else {
        timer.cancel();
        Timer(Duration(seconds: widget.duration), () {
          _startSlideshow();
        });
      }

      for (var i = 0; i < widget.splitCount; i++) {
        _pageControllers[i].animateToPage(
          _currentPage % widget.mediaList.length,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _advanceSlideshow() async {
    if (_currentPage < widget.mediaList.length - 1) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }

    String mediaPath = widget.mediaList[_currentPage];
    int duration = mediaPath.endsWith('.mp4')
        ? await _getVideoDuration(mediaPath)
        : 5; // Default duration for images

    for (var i = 0; i < widget.splitCount; i++) {
      _pageControllers[i].animateToPage(
        _currentPage % widget.mediaList.length,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    if (mediaPath.endsWith('.mp4')) {
      // If the media is a video, wait for it to finish playing
      VideoPlayerController videoController =
          await _initializeVideoController(mediaPath);

      await _waitForVideoCompletion(videoController);
      videoController.dispose();
      _videoControllers.remove(videoController);
    }

    // Use the actual duration for both images and videos
    await Future.delayed(Duration(seconds: duration));
  }

  Future<void> _waitForVideoCompletion(VideoPlayerController controller) async {
    Completer<void> completer = Completer<void>();
    controller.addListener(() {
      if (controller.value.position >= controller.value.duration) {
        completer.complete();
      }
    });

    return completer.future;
  }

  Future<int> _getVideoDuration(String videoPath) async {
    final videoController = VideoPlayerController.file(File(videoPath));
    await videoController.initialize();
    int duration = videoController.value.duration.inSeconds;
    videoController.dispose();
    return duration;
  }

  Future<VideoPlayerController> _initializeVideoController(
      String videoPath) async {
    final controller = VideoPlayerController.file(File(videoPath));
    await controller.initialize();
    controller.setVolume(widget.mute ? 0 : 100);
    controller.setLooping(true);
    controller.play();
    _videoControllers.add(controller);
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    // Explicitly convert widget.mediaList to List<String>
    final List<List<String>> splitMediaList = List.generate(
      widget.splitCount,
      (index) {
        List<String> sublist = List<String>.from(
          (widget.mediaList as List<dynamic>).sublist(
            index * widget.mediaList.length ~/ widget.splitCount,
            (index + 1) * widget.mediaList.length ~/ widget.splitCount,
          ),
        );
        return sublist;
      },
    );

    // Check the current device orientation
    final Orientation currentOrientation = MediaQuery.of(context).orientation;

    // If in landscape orientation, arrange splits in a row
    return RotatedBox(
      quarterTurns: (widget.rotationAngle / (pi / 2)).round(),
      child: GestureDetector(
        onLongPress: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SelectionScreen(),
          ),
        ),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildCarousels(splitMediaList),
        ),
      ),
    );
  }

  List<Widget> _buildCarousels(List<List<String>> splitMediaList) {
    return List.generate(
      widget.splitCount,
      (index) => _buildCarousel(splitMediaList[index], index),
    );
  }

  Widget _buildCarousel(List<String> mediaList, int index) {
    return Expanded(
      child: PageView.builder(
        controller: _pageControllers[index],
        itemCount: mediaList.length,
        itemBuilder: (context, index) {
          String mediaPath = mediaList[index];
          if (mediaPath.endsWith('.mp4')) {
            return FutureBuilder<VideoPlayerController>(
              future: _initializeVideoController(mediaPath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Center(
                    child: AspectRatio(
                      aspectRatio: snapshot.data!.value.aspectRatio,
                      child: VideoPlayer(
                        snapshot.data!,
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          } else {
            return Image.file(
              File(mediaPath),
              // fit: BoxFit.fill,
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _pageControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
