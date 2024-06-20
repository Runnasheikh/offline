// import 'dart:async';
// import 'dart:io';

// import 'package:auto_orientation/auto_orientation.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:slideshow_kiosk/slideshow_screen.dart';

// void main() {
//   runApp(MyApp());
// }

// List<String> mediaList = [];

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//     ));
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SelectionScreen(),
//     );
//   }
// }

// class SelectionScreen extends StatefulWidget {
//   @override
//   State<SelectionScreen> createState() => _SelectionScreenState();
// }

// class _SelectionScreenState extends State<SelectionScreen> {
//   bool isMuted = false;
//   int splitCount = 1;
//   String orientation = "Normal";
//   TextEditingController _countController = TextEditingController();
//   TextEditingController _durationController = TextEditingController();
//   int duration = 5;

//   @override
//   void initState() {
//     super.initState();
//     // Load the saved image paths from shared preferences
//     loadSavedImagePaths();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   GestureDetector(
//                     onTap: () async {
//                       FilePickerResult? result =
//                           await FilePicker.platform.pickFiles(
//                         type: FileType.custom,
//                         allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
//                         allowMultiple: true,
//                       );

//                       if (result != null && result.paths != null) {
//                         // Clear the existing mediaList
//                         mediaList.clear();

//                         // Use null-aware operator (!) to convert nullable strings to non-nullable
//                         mediaList.addAll(result.paths!
//                             .where((path) => path != null)
//                             .cast<String>());

//                         // Save the selected image paths to shared preferences
//                         saveImagePathsToPrefs(mediaList);

//                         print('Selected Files: $mediaList');
//                       } else {
//                         // No files were selected
//                         print('No files selected');
//                       }
//                     },
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         padding: const EdgeInsets.all(18),
//                         color: Colors.green,
//                         child: Text(
//                           "Select Files",
//                           style: Theme.of(context)
//                               .textTheme
//                               .headline6!
//                               .copyWith(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   TextFormField(
//                     controller: _durationController,
//                     decoration: const InputDecoration(
//                       labelText: 'Duration in Seconds',
//                       labelStyle: TextStyle(
//                         color: Color(0xFF6200EE),
//                       ),
//                       suffixIcon: Icon(
//                         Icons.lock_clock,
//                       ),
//                       enabledBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(color: Color(0xFF6200EE)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       width: screenWidth / 1.8,
//                       padding: const EdgeInsets.all(8),
//                       color: Colors.black54,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Mute Video",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .headline6!
//                                 .copyWith(color: Colors.white),
//                           ),
//                           Switch(
//                             value: isMuted,
//                             onChanged: (value) {
//                               setState(() {
//                                 isMuted = value;
//                               });
//                             },
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 15,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // ...
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       try {
//                         duration = int.parse(_durationController.text);
//                       } catch (e) {
//                         print(e);
//                       }
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SlideshowScreen(
//                             mediaList: mediaList,
//                             mute: isMuted,
//                             splitCount: splitCount,
//                             orientation: orientation,
//                             duration: duration,
//                           ),
//                         ),
//                       );
//                     },
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         padding: const EdgeInsets.all(18),
//                         color: const Color.fromARGB(255, 177, 33, 243),
//                         child: Text(
//                           "Start SlideShow",
//                           style: Theme.of(context)
//                               .textTheme
//                               .headline6!
//                               .copyWith(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Save the selected image paths to shared preferences
//   void saveImagePathsToPrefs(List<String> paths) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setStringList('imagePaths', paths);
//   }

//   // Load the saved image paths from shared preferences
//   void loadSavedImagePaths() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? savedPaths = prefs.getStringList('imagePaths');
//     if (savedPaths != null && savedPaths.isNotEmpty) {
//       mediaList = savedPaths;
//     }
//   }
// }




// // import 'dart:async';
// // import 'dart:io';

// // import 'package:auto_orientation/auto_orientation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:slideshow_kiosk/main.dart';
// // import 'package:video_player/video_player.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class SlideshowScreen extends StatefulWidget {
// //   List mediaList;
// //   final bool mute;
// //   final int splitCount;
// //   final String orientation;
// //   final int duration;

// //   SlideshowScreen({
// //     required this.mediaList,
// //     required this.mute,
// //     required this.splitCount,
// //     required this.orientation,
// //     required this.duration,
// //   });

// //   @override
// //   _SlideshowScreenState createState() => _SlideshowScreenState();
// // }

// // class _SlideshowScreenState extends State<SlideshowScreen> {
// //   late List<PageController> _pageControllers;
// //   List<VideoPlayerController> _videoControllers = [];
// //   int _currentPage = 0;
// //   void loadSavedImagePaths() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     List<String>? savedPaths = prefs.getStringList('imagePaths');
// //     if (savedPaths != null && savedPaths.isNotEmpty) {
// //       widget.mediaList = savedPaths;
// //     }
// //   }
// //   @override
// //   void initState() {
// //     super.initState();
// //     _pageControllers =
// //         List.generate(widget.splitCount, (index) => PageController());
// //     // Load the saved image paths from shared preferences
// //     loadSavedImagePaths();
// //     // Start the slideshow
// //     _startSlideshow();
// //   }

// //   void _startSlideshow() async {
// //     Timer.periodic(Duration(seconds: 1), (Timer timer) async {
// //       if (_currentPage < widget.mediaList.length - 1) {
// //         _currentPage++;
// //       } else {
// //         _currentPage = 0;
// //       }

// //       String mediaPath = widget.mediaList[_currentPage];
// //       if (mediaPath.endsWith('.mp4')) {
// //         int duration = await _getVideoDuration(mediaPath);
// //         timer.cancel();
// //         Timer(Duration(seconds: duration), () {
// //           _startSlideshow();
// //         });
// //       } else {
// //         timer.cancel();
// //         Timer(Duration(seconds: widget.duration), () {
// //           _startSlideshow();
// //         });
// //       }

// //       for (var i = 0; i < widget.splitCount; i++) {
// //         _pageControllers[i].animateToPage(
// //           _currentPage % widget.mediaList.length,
// //           duration: Duration(milliseconds: 500),
// //           curve: Curves.easeInOut,
// //         );
// //       }
// //     });
// //   }

// //   void _advanceSlideshow() async {
// //     if (_currentPage < widget.mediaList.length - 1) {
// //       _currentPage++;
// //     } else {
// //       _currentPage = 0;
// //     }

// //     String mediaPath = widget.mediaList[_currentPage];
// //     int duration = mediaPath.endsWith('.mp4')
// //         ? await _getVideoDuration(mediaPath)
// //         : 5; // Default duration for images

// //     for (var i = 0; i < widget.splitCount; i++) {
// //       _pageControllers[i].animateToPage(
// //         _currentPage % widget.mediaList.length,
// //         duration: Duration(milliseconds: 500),
// //         curve: Curves.easeInOut,
// //       );
// //     }

// //     if (mediaPath.endsWith('.mp4')) {
// //       // If the media is a video, wait for it to finish playing
// //       VideoPlayerController videoController =
// //           await _initializeVideoController(mediaPath);

// //       await _waitForVideoCompletion(videoController);
// //       videoController.dispose();
// //       _videoControllers.remove(videoController);
// //     }

// //     // Use the actual duration for both images and videos
// //     await Future.delayed(Duration(seconds: duration));
// //   }

// //   Future<void> _waitForVideoCompletion(VideoPlayerController controller) async {
// //     Completer<void> completer = Completer<void>();
// //     controller.addListener(() {
// //       if (controller.value.position >= controller.value.duration) {
// //         completer.complete();
// //       }
// //     });

// //     return completer.future;
// //   }

// //   Future<int> _getVideoDuration(String videoPath) async {
// //     final videoController = VideoPlayerController.file(File(videoPath));
// //     await videoController.initialize();
// //     int duration = videoController.value.duration.inSeconds;
// //     videoController.dispose();
// //     return duration;
// //   }

// //   Future<VideoPlayerController> _initializeVideoController(
// //       String videoPath) async {
// //     final controller = VideoPlayerController.file(File(videoPath));
// //     await controller.initialize();
// //     controller.setVolume(widget.mute ? 0 : 100);
// //     controller.play();
// //     _videoControllers.add(controller);
// //     return controller;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Explicitly convert widget.mediaList to List<String>
// //     final List<List<String>> splitMediaList = List.generate(
// //       widget.splitCount,
// //       (index) {
// //         List<String> sublist = List<String>.from(
// //           (widget.mediaList as List<dynamic>).sublist(
// //             index * widget.mediaList.length ~/ widget.splitCount,
// //             (index + 1) * widget.mediaList.length ~/ widget.splitCount,
// //           ),
// //         );
// //         return sublist;
// //       },
// //     );
// //     return MaterialApp(
// //       home: WillPopScope(
// //         onWillPop: () async {
// //           for (var controller in _videoControllers) {
// //             await controller.dispose();
// //           }
// //           _videoControllers.clear();
// //           return true;
// //         },
// //         child: Scaffold(
// //           body: GestureDetector(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: _buildCarousels(splitMediaList),
// //             ),
// //             onLongPress: () => Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (context) => MyApp(),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   List<Widget> _buildCarousels(List<List<String>> splitMediaList) {
// //     return List.generate(
// //       widget.splitCount,
// //       (index) => _buildCarousel(splitMediaList[index], index),
// //     );
// //   }

// //   Widget _buildCarousel(List<String> mediaList, int index) {
// //     return Expanded(
// //       child: PageView.builder(
// //         controller: _pageControllers[index],
// //         itemCount: mediaList.length,
// //         itemBuilder: (context, index) {
// //           String mediaPath = mediaList[index];
// //           if (mediaPath.endsWith('.mp4')) {
// //             return FutureBuilder<VideoPlayerController>(
// //               future: _initializeVideoController(mediaPath),
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.done &&
// //                     snapshot.hasData) {
// //                   return Center(
// //                     child: AspectRatio(
// //                       aspectRatio: snapshot.data!.value.aspectRatio,
// //                       child: VideoPlayer(
// //                         snapshot.data!,
// //                       ),
// //                     ),
// //                   );
// //                 } else {
// //                   return Center(
// //                     child: CircularProgressIndicator(),
// //                   );
// //                 }
// //               },
// //             );
// //           } else {
// //             return Image.file(
// //               File(mediaPath),
// //               fit: BoxFit.fill,
// //             );
// //           }
// //         },
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     for (var controller in _videoControllers) {
// //       controller.dispose();
// //     }
// //     _pageControllers.forEach((controller) => controller.dispose());
// //     super.dispose();
// //   }
// // }
//   // Widget build(BuildContext context) {
//   //   double screenWidth = MediaQuery.of(context).size.width;
//   //   mediaList.clear();
//   //   return MaterialApp(
//   //     debugShowCheckedModeBanner: false,
//   //     home: Scaffold(
//   //       body: Center(
//   //         child: SingleChildScrollView(
//   //           child: Padding(
//   //             padding: const EdgeInsets.all(20.0),
//   //             child: Column(
//   //               mainAxisAlignment: MainAxisAlignment.center,
//   //               children: [
//   //                 GestureDetector(
//   //                   onTap: () async {
//   //                     FilePickerResult? result =
//   //                         await FilePicker.platform.pickFiles(
//   //                       type: FileType.custom,
//   //                       allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
//   //                       allowMultiple: true,
//   //                     );

//   //                     if (result != null && result.paths != null) {
//   //                       // Clear the existing mediaList
//   //                       mediaList.clear();

//   //                       // Use null-aware operator (!) to convert nullable strings to non-nullable
//   //                       mediaList.addAll(result.paths!
//   //                           .where((path) => path != null)
//   //                           .cast<String>());

//   //                       print('Selected Files: $mediaList');
//   //                     } else {
//   //                       // No files were selected
//   //                       print('No files selected');
//   //                     }
//   //                   },
//   //                   child: ClipRRect(
//   //                     borderRadius: BorderRadius.circular(12),
//   //                     child: Container(
//   //                       padding: const EdgeInsets.all(18),
//   //                       color: Colors.green,
//   //                       child: Text(
//   //                         "Select Files",
//   //                         style: Theme.of(context)
//   //                             .textTheme
//   //                             .headline6!
//   //                             .copyWith(color: Colors.white),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //                 const SizedBox(
//   //                   height: 10,
//   //                 ),
//   //                 TextFormField(
//   //                   controller: _durationController,
//   //                   decoration: const InputDecoration(
//   //                     labelText: 'Duration in Seconds',
//   //                     labelStyle: TextStyle(
//   //                       color: Color(0xFF6200EE),
//   //                     ),
//   //                     suffixIcon: Icon(
//   //                       Icons.lock_clock,
//   //                     ),
//   //                     enabledBorder: UnderlineInputBorder(
//   //                       borderSide: BorderSide(color: Color(0xFF6200EE)),
//   //                     ),
//   //                   ),
//   //                 ),
//   //                 const SizedBox(
//   //                   height: 20,
//   //                 ),
//   //                 ClipRRect(
//   //                   borderRadius: BorderRadius.circular(12),
//   //                   child: Container(
//   //                     width: screenWidth / 1.8,
//   //                     padding: const EdgeInsets.all(8),
//   //                     color: Colors.black54,
//   //                     child: Row(
//   //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                       children: [
//   //                         Text(
//   //                           "Mute Video",
//   //                           style: Theme.of(context)
//   //                               .textTheme
//   //                               .headline6!
//   //                               .copyWith(color: Colors.white),
//   //                         ),
//   //                         Switch(
//   //                           value: isMuted,
//   //                           onChanged: (value) {
//   //                             setState(() {
//   //                               isMuted = value;
//   //                             });
//   //                           },
//   //                         )
//   //                       ],
//   //                     ),
//   //                   ),
//   //                 ),
//   //                 const SizedBox(
//   //                   height: 15,
//   //                 ),
//   //                 Row(
//   //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                   children: [
//   //                     GestureDetector(
//   //                       onTap: () => showDialog(
//   //                         context: context,
//   //                         builder: (context) => AlertDialog(
//   //                           title: Text("Select Split"),
//   //                           actions: [
//   //                             TextButton(
//   //                               onPressed: () {
//   //                                 splitCount = 1;
//   //                                 Navigator.pop(context);
//   //                               },
//   //                               child: Text(
//   //                                 "1",
//   //                                 style: Theme.of(context).textTheme.headline6,
//   //                               ),
//   //                             ),
//   //                             TextButton(
//   //                               onPressed: () {
//   //                                 splitCount = 2;
//   //                                 Navigator.pop(context);
//   //                               },
//   //                               child: Text(
//   //                                 "2",
//   //                                 style: Theme.of(context).textTheme.headline6,
//   //                               ),
//   //                             ),
//   //                             TextButton(
//   //                               onPressed: () {
//   //                                 splitCount = 3;
//   //                                 Navigator.pop(context);
//   //                               },
//   //                               child: Text(
//   //                                 "3",
//   //                                 style: Theme.of(context).textTheme.headline6,
//   //                               ),
//   //                             ),
//   //                           ],
//   //                         ),
//   //                       ),
//   //                       child: ClipRRect(
//   //                         borderRadius: BorderRadius.circular(12),
//   //                         child: Container(
//   //                           padding: const EdgeInsets.all(18),
//   //                           color: Colors.blue,
//   //                           child: Text(
//   //                             "Select Split",
//   //                             style: Theme.of(context)
//   //                                 .textTheme
//   //                                 .headline6!
//   //                                 .copyWith(color: Colors.white),
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ),
//   //                     GestureDetector(
//   //                       onTap: () => showDialog(
//   //                           context: context,
//   //                           builder: (context) => AlertDialog(
//   //                                 title: const Text('Select Orientation'),
//   //                                 content: SingleChildScrollView(
//   //                                   child: Column(
//   //                                     children: [
//   //                                       Text("data"),
//   //                                       Text("data"),
//   //                                     ],
//   //                                   ),
//   //                                 ),
//   //                               )),
//   //                       child: ClipRRect(
//   //                         borderRadius: BorderRadius.circular(12),
//   //                         child: Container(
//   //                           padding: const EdgeInsets.all(18),
//   //                           color: Colors.blue,
//   //                           child: Text(
//   //                             "Orientation",
//   //                             style: Theme.of(context)
//   //                                 .textTheme
//   //                                 .headline6!
//   //                                 .copyWith(color: Colors.white),
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //                 const SizedBox(
//   //                   height: 10,
//   //                 ),
//   //                 GestureDetector(
//   //                   onTap: () {
//   //                     try {
//   //                       duration = int.parse(_durationController.text);
//   //                     } catch (e) {
//   //                       print(e);
//   //                     }
//   //                     Navigator.push(
//   //                         context,
//   //                         MaterialPageRoute(
//   //                           builder: (context) => SlideshowScreen(
//   //                             mediaList: mediaList,
//   //                             mute: isMuted,
//   //                             splitCount: splitCount,
//   //                             orientation: orientation,
//   //                             duration: duration,
//   //                           ),
//   //                         ));
//   //                   },
//   //                   child: ClipRRect(
//   //                     borderRadius: BorderRadius.circular(12),
//   //                     child: Container(
//   //                       padding: const EdgeInsets.all(18),
//   //                       color: const Color.fromARGB(255, 177, 33, 243),
//   //                       child: Text(
//   //                         "Start SlideShow",
//   //                         style: Theme.of(context)
//   //                             .textTheme
//   //                             .headline6!
//   //                             .copyWith(color: Colors.white),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }



//   //  @override
//   // Widget build(BuildContext context) {
//   //   double screenWidth = MediaQuery.of(context).size.width;
//   //   return MaterialApp(
//   //     debugShowCheckedModeBanner: false,
//   //     home: Scaffold(
//   //       body: Center(
//   //         child: SingleChildScrollView(
//   //           child: Padding(
//   //             padding: const EdgeInsets.all(20.0),
//   //             child: Column(
//   //               mainAxisAlignment: MainAxisAlignment.center,
//   //               children: [
//   //                 GestureDetector(
//   //                   onTap: () async {
//   //                     FilePickerResult? result =
//   //                         await FilePicker.platform.pickFiles(
//   //                       type: FileType.custom,
//   //                       allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
//   //                       allowMultiple: true,
//   //                     );

//   //                     if (result != null && result.paths != null) {
//   //                       // Clear the existing mediaList
//   //                       mediaList.clear();

//   //                       // Use null-aware operator (!) to convert nullable strings to non-nullable
//   //                       mediaList.addAll(result.paths!
//   //                           .where((path) => path != null)
//   //                           .cast<String>());

//   //                       // Save the selected image paths to shared preferences
//   //                       saveImagePathsToPrefs(mediaList);

//   //                       print('Selected Files: $mediaList');
//   //                     } else {
//   //                       // No files were selected
//   //                       print('No files selected');
//   //                     }
//   //                   },
//   //                   child: ClipRRect(
//   //                     borderRadius: BorderRadius.circular(12),
//   //                     child: Container(
//   //                       padding: const EdgeInsets.all(18),
//   //                       color: Colors.green,
//   //                       child: Text(
//   //                         "Select Files",
//   //                         style: Theme.of(context)
//   //                             .textTheme
//   //                             .headline6!
//   //                             .copyWith(color: Colors.white),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //                 const SizedBox(
//   //                   height: 10,
//   //                 ),
//   //                 TextFormField(
//   //                   controller: _durationController,
//   //                   decoration: const InputDecoration(
//   //                     labelText: 'Duration in Seconds',
//   //                     labelStyle: TextStyle(
//   //                       color: Color(0xFF6200EE),
//   //                     ),
//   //                     suffixIcon: Icon(
//   //                       Icons.lock_clock,
//   //                     ),
//   //                     enabledBorder: UnderlineInputBorder(
//   //                       borderSide: BorderSide(color: Color(0xFF6200EE)),
//   //                     ),
//   //                   ),
//   //                 ),
//   //                 const SizedBox(
//   //                   height: 20,
//   //                 ),
//   //                 ClipRRect(
//   //                   borderRadius: BorderRadius.circular(12),
//   //                   child: Container(
//   //                     width: screenWidth / 1.8,
//   //                     padding: const EdgeInsets.all(8),
//   //                     color: Colors.black54,
//   //                     child: Row(
//   //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                       children: [
//   //                         Text(
//   //                           "Mute Video",
//   //                           style: Theme.of(context)
//   //                               .textTheme
//   //                               .headline6!
//   //                               .copyWith(color: Colors.white),
//   //                         ),
//   //                         Switch(
//   //                           value: isMuted,
//   //                           onChanged: (value) {
//   //                             setState(() {
//   //                               isMuted = value;
//   //                             });
//   //                           },
//   //                         )
//   //                       ],
//   //                     ),
//   //                   ),
//   //                 ),
//   //                 const SizedBox(
//   //                   height: 15,
//   //                 ),
//   //                 Row(
//   //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                   children: [
//   //                     // ...
//   //                   ],
//   //                 ),
//   //                 const SizedBox(
//   //                   height: 10,
//   //                 ),
//   //                 GestureDetector(
//   //                   onTap: () {
//   //                     try {
//   //                       duration = int.parse(_durationController.text);
//   //                     } catch (e) {
//   //                       print(e);
//   //                     }
//   //                     Navigator.push(
//   //                       context,
//   //                       MaterialPageRoute(
//   //                         builder: (context) => SlideshowScreen(
//   //                           mediaList: mediaList,
//   //                           mute: isMuted,
//   //                           splitCount: splitCount,
//   //                           orientation: orientation,
//   //                           duration: duration,
//   //                         ),
//   //                       ),
//   //                     );
//   //                   },
//   //                   child: ClipRRect(
//   //                     borderRadius: BorderRadius.circular(12),
//   //                     child: Container(
//   //                       padding: const EdgeInsets.all(18),
//   //                       color: const Color.fromARGB(255, 177, 33, 243),
//   //                       child: Text(
//   //                         "Start SlideShow",
//   //                         style: Theme.of(context)
//   //                             .textTheme
//   //                             .headline6!
//   //                             .copyWith(color: Colors.white),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }]
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
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
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    loadSavedImagePaths();
    SlideshowScreen.loadRotationAngle().then((savedAngle) {
      setState(() {
        widget.rotationAngle = savedAngle ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: (widget.rotationAngle / (pi / 2)).round(),
      child: GestureDetector(
        onLongPress: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SelectionScreen(),
          ),
        ),
        child: _buildMediaWidget(widget.mediaList.first),
      ),
    );
  }

  Widget _buildMediaWidget(String mediaPath) {
    if (mediaPath.endsWith('.mp4')) {
      return FutureBuilder<VideoPlayerController>(
        future: _initializeVideoController(mediaPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Center(
              child: AspectRatio(
                aspectRatio: snapshot.data!.value.aspectRatio,
                child: VideoPlayer(snapshot.data!),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      return Image.file(File(mediaPath));
    }
  }

 Future<VideoPlayerController> _initializeVideoController(String videoPath) async {
  if (!_videoControllers.containsKey(videoPath)) {
    final controller = VideoPlayerController.file(File(videoPath));
    await controller.initialize();
    controller.setVolume(widget.mute ? 0 : 1);
    controller.setLooping(true);
    controller.addListener(() {
      if (controller.value.position >= controller.value.duration) {
        // Ensure the video loops back to the beginning
        controller.seekTo(Duration.zero);
      }
    });
    // Start playing the video immediately
    await controller.play();
    _videoControllers[videoPath] = controller;
  }
  return _videoControllers[videoPath]!;
}

}
