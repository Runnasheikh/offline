// import 'dart:async';
// import 'dart:math';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:slideshow_kiosk/slideshow_screen.dart';
// import 'package:usb_serial/usb_serial.dart';

// void main() {
//   runApp(MyApp());
// }

// List<String> mediaList = [];
// int splitCount = 1;
// double angle = 0;

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: FutureBuilder<bool>(
//         future: hasSavedImagePaths(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.data == true) {
//               return FutureBuilder<List<String>>(
//                 future: getSavedImagePaths(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     return SlideshowScreen(
//                       mediaList: snapshot.data!,
//                       mute: false,
//                       splitCount: splitCount,
//                       rotationAngle: angle,
//                       // orientation: 'Normal',

//                       duration: 5,
//                     );
//                   } else {
//                     return Scaffold(
//                       body: Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   }
//                 },
//               );
//             } else {
//               return SelectionScreen();
//             }
//           } else {
//             return Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }
//         },
//       ),
//       // home: SelectionScreen(),
//     );
//   }

//   Future<bool> hasSavedImagePaths() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? savedPaths = prefs.getStringList('imagePaths');
//     splitCount = prefs.getInt('splitCount') as int;
//     angle;
//     return savedPaths != null && savedPaths.isNotEmpty;
//   }

//   Future<List<String>> getSavedImagePaths() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? savedPaths = prefs.getStringList('imagePaths');
//     return savedPaths ?? [];
//   }
// }

// class SelectionScreen extends StatefulWidget {
//   @override
//   State<SelectionScreen> createState() => _SelectionScreenState();
// }

// class _SelectionScreenState extends State<SelectionScreen> {
//   bool isMuted = false;
//   late ScrollController _scrollController;

//   String orientation = "Normal";
//   TextEditingController _countController = TextEditingController();
//   TextEditingController _durationController = TextEditingController();
//   int duration = 5;
//   bool isUsbConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     loadSavedImagePaths();
//     _initUsbDetection();
//     _scrollController = ScrollController();
//   }

//   void _initUsbDetection() async {
//     List<UsbDevice> devices = await UsbSerial.listDevices();
//     setState(() {
//       isUsbConnected = devices.isNotEmpty;
//     });

//     UsbSerial.usbEventStream?.listen((UsbEvent event) {
//       setState(() {
//         isUsbConnected = event.event == UsbEvent.ACTION_USB_ATTACHED;
//       });
//     });
//   }

//   void clearImages() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.remove(
//         'imagePaths'); // Remove the 'imagePaths' key from shared preferences

//     setState(() {
//       mediaList.clear();
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _scrollController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return RotatedBox(
//       quarterTurns: (angle / (pi / 2)).round(),
//       child: Scaffold(
        
//         body: Center(
//           child: SingleChildScrollView(
//             controller: _scrollController,
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     isUsbConnected ? Icons.usb : Icons.usb_off,
//                     size: 100,
//                     color: isUsbConnected ? Colors.green : Colors.black,
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     isUsbConnected ? 'USB Connected' : 'USB not connect',
//                     style: TextStyle(fontSize: 20),
//                   ),
//                   const SizedBox(height: 32),
//                   GestureDetector(
//                     onTap: () async {
//                       FilePickerResult? result =
//                           await FilePicker.platform.pickFiles(
//                         type: FileType.custom,
//                         allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
//                         allowMultiple: true,
//                       );

//                       if (result != null && result.paths != null) {
//                         // mediaList.clear();
//                         mediaList.addAll(result.paths!
//                             .where((path) => path != null)
//                             .cast<String>());
//                         saveImagePathsToPrefs(mediaList);
//                         print('Selected Files: $mediaList');
//                       } else {
//                         print('No files selected');
//                       }
//                     },
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         padding: const EdgeInsets.all(18),
//                         color: Colors.green,
//                         alignment: Alignment.center,
//                         width: double.infinity,
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
//                   const SizedBox(height: 10),
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
//                   const SizedBox(height: 20),
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
//                   const SizedBox(height: 15),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       GestureDetector(
//                         onTap: () => showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: Text("Select Split"),
//                             actions: [
//                               TextButton(
//                                 onPressed: () {
//                                   splitCount = 1;
//                                   saveSplitToPrefs(splitCount);
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text(
//                                   "1",
//                                   style: Theme.of(context).textTheme.headline6,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   splitCount = 2;
//                                   saveSplitToPrefs(splitCount);
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text(
//                                   "2",
//                                   style: Theme.of(context).textTheme.headline6,
//                                 ),
//                               ),
//                               TextButton(
//                                 onPressed: () {
//                                   splitCount = 3;
//                                   saveSplitToPrefs(splitCount);
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text(
//                                   "3",
//                                   style: Theme.of(context).textTheme.headline6,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Container(
//                             padding: const EdgeInsets.all(18),
//                             color: Colors.blue,
//                             child: Text(
//                               "Select Split",
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .headline6!
//                                   .copyWith(color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: const Text('Select Orientation'),
//                               content: SingleChildScrollView(
//                                 child: Column(
//                                   children: [
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           angle = 0.0;
//                                         });
//                                         SystemChrome.setPreferredOrientations([
//                                           DeviceOrientation.portraitUp,
//                                           DeviceOrientation.portraitDown,
//                                         ]);
//                                         Navigator.pop(context);
//                                       },
//                                       child: Text('Portrait'),
//                                     ),
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           angle = -pi / 2;
//                                         });
//                                         SystemChrome.setPreferredOrientations([
//                                           DeviceOrientation.landscapeLeft,
//                                           DeviceOrientation.landscapeRight,
//                                         ]);
//                                         Navigator.pop(context);
//                                       },
//                                       child: const Text('Landscape'),
//                                     ),
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           angle = pi / 2;
//                                         });
//                                         SystemChrome.setPreferredOrientations([
//                                           DeviceOrientation.landscapeRight,
//                                           DeviceOrientation.landscapeRight,
//                                         ]);
//                                         Navigator.pop(context);
//                                       },
//                                       child:const  Text('left'),
//                                     ),
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           angle = pi;
//                                         });
//                                         SystemChrome.setPreferredOrientations([
//                                           DeviceOrientation.portraitDown,
//                                           DeviceOrientation.portraitUp,
//                                         ]);
//                                         Navigator.pop(context);
//                                       },
//                                       child: Text('upside down'),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Container(
//                             padding: const EdgeInsets.all(18),
//                             color: Colors.blue,
//                             child: Text(
//                               "Orientation",
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .headline6!
//                                   .copyWith(color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
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
//                             rotationAngle: angle,
//                             // orientation: orientation,
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
//                   ElevatedButton(
//                       onPressed: () {
//                         clearImages();
//                       },
//                       child: const Text("Clear Images"))
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // void setOrientation(DeviceOrientation orientation) {
//   //   SystemChrome.setPreferredOrientations([orientation]);
//   //   Navigator.pop(context);
//   //   setState(() {
//   //     if (orientation == DeviceOrientation.landscapeLeft ||
//   //         orientation == DeviceOrientation.landscapeRight) {
//   //       this.orientation = "Landscape";
//   //     } else {
//   //       this.orientation = "Portrait";
//   //     }
//   //   });
//   // }
// }

// void saveImagePathsToPrefs(List<String> paths) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setStringList('imagePaths', paths);
// }

// void saveSplitToPrefs(int count) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setInt('splitCount', count);
// }

// void savePrefToDouble(double angle) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setDouble('angle', angle);
// }

// void loadSavedImagePaths() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String>? savedPaths = prefs.getStringList('imagePaths');
//   if (savedPaths != null && savedPaths.isNotEmpty) {
//     mediaList = savedPaths;
//   }
// }
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:slideshow_kiosk/main.dart';
// import 'package:video_player/video_player.dart';
// import 'dart:async';
// import 'dart:io';

// class SlideshowScreen extends StatefulWidget {
//   List mediaList;
//   final bool mute;
//   final int splitCount;
//   // final String orientation;
//   final double rotationAngle;
//   final int duration;

//   SlideshowScreen({
//     required this.mediaList,
//     required this.mute,
//     required this.splitCount,
//     // required this.orientation,
//     required this.rotationAngle,
//     required this.duration,
//   });

//   @override
//   _SlideshowScreenState createState() => _SlideshowScreenState();
// }

// class _SlideshowScreenState extends State<SlideshowScreen> {
//   late List<PageController> _pageControllers;
//   List<VideoPlayerController> _videoControllers = [];

//   int _currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageControllers =
//         List.generate(widget.splitCount, (index) => PageController());
//     loadSavedImagePaths();
//     _startSlideshow();
//   }

//   void loadSavedImagePaths() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String>? savedPaths = prefs.getStringList('imagePaths');
//     if (savedPaths != null && savedPaths.isNotEmpty) {
//       widget.mediaList = savedPaths;
//     }
//   }

//   void _startSlideshow() async {
//     Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
//       if (_currentPage < widget.mediaList.length - 1) {
//         _currentPage++;
//       } else {
//         _currentPage = 0;
//       }

//       String mediaPath = widget.mediaList[_currentPage];
//       if (mediaPath.endsWith('.mp4')) {
//         int duration = await _getVideoDuration(mediaPath);
//         timer.cancel();
//         Timer(Duration(seconds: duration), () {
//           _startSlideshow();
//         });
//       } else {
//         timer.cancel();
//         Timer(Duration(seconds: widget.duration), () {
//           _startSlideshow();
//         });
//       }

//       for (var i = 0; i < widget.splitCount; i++) {
//         _pageControllers[i].animateToPage(
//           _currentPage % widget.mediaList.length,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   void _advanceSlideshow() async {
//     if (_currentPage < widget.mediaList.length - 1) {
//       _currentPage++;
//     } else {
//       _currentPage = 0;
//     }

//     String mediaPath = widget.mediaList[_currentPage];
//     int duration = mediaPath.endsWith('.mp4')
//         ? await _getVideoDuration(mediaPath)
//         : 5; // Default duration for images

//     for (var i = 0; i < widget.splitCount; i++) {
//       _pageControllers[i].animateToPage(
//         _currentPage % widget.mediaList.length,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }

//     if (mediaPath.endsWith('.mp4')) {
//       // If the media is a video, wait for it to finish playing
//       VideoPlayerController videoController =
//           await _initializeVideoController(mediaPath);

//       await _waitForVideoCompletion(videoController);
//       videoController.dispose();
//       _videoControllers.remove(videoController);
//     }

//     // Use the actual duration for both images and videos
//     await Future.delayed(Duration(seconds: duration));
//   }

//   Future<void> _waitForVideoCompletion(VideoPlayerController controller) async {
//     Completer<void> completer = Completer<void>();
//     controller.addListener(() {
//       if (controller.value.position >= controller.value.duration) {
//         completer.complete();
//       }
//     });

//     return completer.future;
//   }

//   Future<int> _getVideoDuration(String videoPath) async {
//     final videoController = VideoPlayerController.file(File(videoPath));
//     await videoController.initialize();
//     int duration = videoController.value.duration.inSeconds;
//     videoController.dispose();
//     return duration;
//   }

//   Future<VideoPlayerController> _initializeVideoController(
//       String videoPath) async {
//     final controller = VideoPlayerController.file(File(videoPath));
//     await controller.initialize();
//     controller.setVolume(widget.mute ? 0 : 100);
//     controller.setLooping(true);
//     controller.play();
//     _videoControllers.add(controller);
//     return controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Explicitly convert widget.mediaList to List<String>
//     final List<List<String>> splitMediaList = List.generate(
//       widget.splitCount,
//       (index) {
//         List<String> sublist = List<String>.from(
//           (widget.mediaList as List<dynamic>).sublist(
//             index * widget.mediaList.length ~/ widget.splitCount,
//             (index + 1) * widget.mediaList.length ~/ widget.splitCount,
//           ),
//         );
//         return sublist;
//       },
//     );

//     // Check the current device orientation
//     // final Orientation currentOrientation = MediaQuery.of(context).orientation;

//     // If in landscape orientation, arrange splits in a row
//     return RotatedBox(
//       quarterTurns: (widget.rotationAngle / (pi / 2)).round(),
//       child: GestureDetector(
//         onLongPress: () => Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SelectionScreen(),
//           ),
//         ),
//         child:Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: _buildCarousels(splitMediaList),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildCarousels(List<List<String>> splitMediaList) {
//     return List.generate(
//       widget.splitCount,
//       (index) => _buildCarousel(splitMediaList[index], index),
//     );
//   }

//   Widget _buildCarousel(List<String> mediaList, int index) {
//     return Expanded(
//       child: PageView.builder(
//         controller: _pageControllers[index],
//         itemCount: mediaList.length,
//         itemBuilder: (context, index) {
//           String mediaPath = mediaList[index];
//           if (mediaPath.endsWith('.mp4')) {
//             return FutureBuilder<VideoPlayerController>(
//               future: _initializeVideoController(mediaPath),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done &&
//                     snapshot.hasData) {
//                   return Center(
//                     child: AspectRatio(
//                       aspectRatio: snapshot.data!.value.aspectRatio,
//                       child: VideoPlayer(
//                         snapshot.data!,
//                       ),
//                     ),
//                   );
//                 } else {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }
//               },
//             );
//           } else {
//             return Image.file(
//               File(mediaPath),
//               // fit: BoxFit.fill,
//             );
//           }
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     for (var controller in _videoControllers) {
//       controller.dispose();
//     }
//     _pageControllers.forEach((controller) => controller.dispose());
//     super.dispose();
//   }
// }
