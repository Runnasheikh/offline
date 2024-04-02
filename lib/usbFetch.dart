import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerWidget extends StatefulWidget {
  @override
  _PermissionHandlerWidgetState createState() =>
      _PermissionHandlerWidgetState();
}

class _PermissionHandlerWidgetState extends State<PermissionHandlerWidget> {
  List<String> _imagePaths = []; // List to store image paths

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<void> requestPermission() async {
    // Request storage permission
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, fetch images
      print("granted");
      fetchImages();
    } else {
      // Permission denied
      showDialog(
        context: context, // Use context provided by StatefulWidget
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Permission Denied'),
            content: Text('Please grant storage permission to access images.'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  Future<void> fetchImages() async {
    List<Directory>? externalStorageDirectories =
        await getExternalStorageDirectories();
    if (externalStorageDirectories!.isNotEmpty) {
      // Directory mediaDirectory = Directory("/storage/8015-2A82/Media");
      Directory mediaDirectory = Directory("/storage/CABB-15A8/Media");
      if (await mediaDirectory.exists()) {
        List<FileSystemEntity> files = mediaDirectory.listSync();
        List<String> imagePaths = files
            .where((entity) =>
                entity is File &&
                    (entity.path.toLowerCase().endsWith(".png") ||
                        entity.path.toLowerCase().endsWith(".jpg") ||
                        entity.path.toLowerCase().endsWith(".jpeg") ||
                         entity.path.toLowerCase().endsWith(".mp4")) ||
                entity.path.toLowerCase().endsWith("image.png"))
            .map((file) => file.path)
            .toList();
        setState(() {
          _imagePaths = imagePaths;
          print("Your image files: $imagePaths");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                requestPermission();
              },
              child: Text('Request Permission'),
            ),
            SizedBox(height: 20),
            _imagePaths.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _imagePaths.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Image.file(File(_imagePaths[index])),
                        );
                      },
                    ),
                  )
                : Text('No images to display'),
          ],
        ),
      ),
    );
  }
}
