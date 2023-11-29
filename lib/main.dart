import 'dart:async';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slideshow_kiosk/slideshow_screen.dart';
import 'package:usb_serial/usb_serial.dart';

void main() {
  runApp(MyApp());
}

List<String> mediaList = [];
int splitCount = 1;
double angle = 0;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: hasSavedImagePaths(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return FutureBuilder<List<String>>(
                future: getSavedImagePaths(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SlideshowScreen(
                      mediaList: snapshot.data!,
                      mute: false,
                      splitCount: splitCount,
                      rotationAngle: angle,
                      // orientation: 'Normal',

                      duration: 5,
                    );
                  } else {
                    return Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              );
            } else {
              return SelectionScreen();
            }
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      // home: SelectionScreen(),
    );
  }

  Future<bool> hasSavedImagePaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedPaths = prefs.getStringList('imagePaths');
    splitCount = prefs.getInt('splitCount') as int;
    angle;
    return savedPaths != null && savedPaths.isNotEmpty;
  }

  Future<List<String>> getSavedImagePaths() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedPaths = prefs.getStringList('imagePaths');
    return savedPaths ?? [];
  }
}

class SelectionScreen extends StatefulWidget {
  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  bool isMuted = false;
  late ScrollController _scrollController;

  String orientation = "Normal";
  TextEditingController _countController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  int duration = 5;
  bool isUsbConnected = false;

  @override
  void initState() {
    super.initState();
    loadSavedImagePaths();
    _initUsbDetection();
    _scrollController = ScrollController();
  }

  void _initUsbDetection() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    setState(() {
      isUsbConnected = devices.isNotEmpty;
    });

    UsbSerial.usbEventStream?.listen((UsbEvent event) {
      setState(() {
        isUsbConnected = event.event == UsbEvent.ACTION_USB_ATTACHED;
      });
    });
  }

  void clearImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(
        'imagePaths'); // Remove the 'imagePaths' key from shared preferences

    setState(() {
      mediaList.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return RotatedBox(
      quarterTurns: (angle / (pi / 2)).round(),
      child: Scaffold(
        
        body: Center(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUsbConnected ? Icons.usb : Icons.usb_off,
                    size: 100,
                    color: isUsbConnected ? Colors.green : Colors.black,
                  ),
                  SizedBox(height: 20),
                  Text(
                    isUsbConnected ? 'USB Connected' : 'USB not connect',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 32),
                  GestureDetector(
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
                        allowMultiple: true,
                      );

                      if (result != null && result.paths != null) {
                        // mediaList.clear();
                        mediaList.addAll(result.paths!
                            .where((path) => path != null)
                            .cast<String>());
                        saveImagePathsToPrefs(mediaList);
                        print('Selected Files: $mediaList');
                      } else {
                        print('No files selected');
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        color: Colors.green,
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: Text(
                          "Select Files",
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration in Seconds',
                      labelStyle: TextStyle(
                        color: Color(0xFF6200EE),
                      ),
                      suffixIcon: Icon(
                        Icons.lock_clock,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6200EE)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: screenWidth / 1.8,
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mute Video",
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.white),
                          ),
                          Switch(
                            value: isMuted,
                            onChanged: (value) {
                              setState(() {
                                isMuted = value;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Select Split"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  splitCount = 1;
                                  saveSplitToPrefs(splitCount);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "1",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  splitCount = 2;
                                  saveSplitToPrefs(splitCount);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "2",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  splitCount = 3;
                                  saveSplitToPrefs(splitCount);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "3",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            color: Colors.blue,
                            child: Text(
                              "Select Split",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Orientation'),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          angle = 0.0;
                                        });
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.portraitUp,
                                          DeviceOrientation.portraitDown,
                                        ]);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Portrait'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          angle = -pi / 2;
                                        });
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.landscapeLeft,
                                          DeviceOrientation.landscapeRight,
                                        ]);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Landscape'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          angle = pi / 2;
                                        });
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.landscapeRight,
                                          DeviceOrientation.landscapeRight,
                                        ]);
                                        Navigator.pop(context);
                                      },
                                      child: Text('left'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          angle = pi;
                                        });
                                        SystemChrome.setPreferredOrientations([
                                          DeviceOrientation.portraitDown,
                                          DeviceOrientation.portraitUp,
                                        ]);
                                        Navigator.pop(context);
                                      },
                                      child: Text('upside down'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            color: Colors.blue,
                            child: Text(
                              "Orientation",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      try {
                        duration = int.parse(_durationController.text);
                      } catch (e) {
                        print(e);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SlideshowScreen(
                            mediaList: mediaList,
                            mute: isMuted,
                            splitCount: splitCount,
                            rotationAngle: angle,
                            // orientation: orientation,
                            duration: duration,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        color: const Color.fromARGB(255, 177, 33, 243),
                        child: Text(
                          "Start SlideShow",
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        clearImages();
                      },
                      child: Text("Clear Images"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setOrientation(DeviceOrientation orientation) {
    SystemChrome.setPreferredOrientations([orientation]);
    Navigator.pop(context);
    setState(() {
      if (orientation == DeviceOrientation.landscapeLeft ||
          orientation == DeviceOrientation.landscapeRight) {
        this.orientation = "Landscape";
      } else {
        this.orientation = "Portrait";
      }
    });
  }
}

void saveImagePathsToPrefs(List<String> paths) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('imagePaths', paths);
}

void saveSplitToPrefs(int count) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('splitCount', count);
}

void savePrefToDouble(double angle) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble('angle', angle);
}

void loadSavedImagePaths() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? savedPaths = prefs.getStringList('imagePaths');
  if (savedPaths != null && savedPaths.isNotEmpty) {
    mediaList = savedPaths;
  }
}
