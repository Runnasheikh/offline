import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_manager/file_manager.dart';


class HomePage extends StatefulWidget {
  final FileManagerController controller = FileManagerController();

  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> storageNames = [];
  
  @override
  void initState() {
    super.initState();

    selectStorage(context);
  }

  @override
  Widget build(BuildContext context) {
    print(storageNames);
    return ControlBackButton(
      controller: widget.controller,
      child: Scaffold(
        body: ListView.builder(
          itemCount: storageNames.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(storageNames[index]),
             
            );
          },
        ),
      ),
    );
  }

  Future<void> selectStorage(BuildContext context) async {
    final List<Directory> storageList = await FileManager.getStorageList();
    for (final Directory directory in storageList) {
      final basename = FileManager.basename(directory);
      if (basename != '0') {
        print(basename);
      }
    }
    setState(() {
      storageNames = storageList
          .map((directory) => FileManager.basename(directory))
          .where((basename) => basename != '0') // Exclude '0' from the list
          .toList();
    });
  }
}
