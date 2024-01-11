import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CodeEntryPage extends StatefulWidget {
  final VoidCallback onCodeEntered;

  CodeEntryPage({required this.onCodeEntered});

  @override
  _CodeEntryPageState createState() => _CodeEntryPageState();
}

class _CodeEntryPageState extends State<CodeEntryPage> {
  final TextEditingController _codeController = TextEditingController();
  bool isCodeValidated = false; // Flag to track whether the code has been validated
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if code has been validated before
    checkValidationStatus();
  }

  Future<void> _submitCode(String code) async {
    if (isLoading) {
      // Avoid multiple submissions while still loading
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (isCodeValidated) {
      // Code has already been validated, skip the validation process
      print('Code has already been validatedd');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse('https://cloudkiosk.onrender.com/api/offlineMode/offline-code'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code}),
    );

    if (response.statusCode == 200) {
      // Code successfully used, set validation status to true
      setValidationStatus(true);

      // Call the callback to notify that the code has been entered successfully
      widget.onCodeEntered();
    } else if (response.statusCode == 404) {
      // Code not found, handle accordingly
      _showErrorDialog('Invalid code');
    } else if (response.statusCode == 400) {
      // Code has already been used, handle accordingly
      _showErrorDialog('Code has already been used');
    } else {
      // Handle other status codes or errors
      _showErrorDialog('Error: ${response.statusCode}');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Method to show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Method to check if the code has been validated before
  void checkValidationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool validated = prefs.getBool('isCodeValidated') ?? false;
    setState(() {
      isCodeValidated = validated;
    });
  }

  // Method to set the validation status
  void setValidationStatus(bool validated) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isCodeValidated', validated);
    setState(() {
      isCodeValidated = validated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          
          
          children: [
            FadeInDown( duration: Duration(milliseconds: 1900),child:  Image.asset('assets/background.png',fit: BoxFit.cover)
        
           ),
          SizedBox(height: 40,),
            Container(
	                          padding: EdgeInsets.all(8.0),
	                          decoration: BoxDecoration(
	                            border: Border(bottom: BorderSide(color:  Color.fromRGBO(143, 148, 251, 1)))
	                          ),
	                          child: TextField(
                       controller: _codeController,
	                            decoration: InputDecoration(
	                              border: InputBorder.none,
	                              hintText: "Enter your code",
	                              hintStyle: TextStyle(color: Colors.grey[700])
	                            ),
	                          ),
	                        ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     // Validate the entered code
            //     _submitCode(_codeController.text);
            //   },
            //   child: Text('Submit Code'),
            // ),
            FadeInUp(duration: Duration(milliseconds: 1900), child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromRGBO(143, 148, 251, 1),
                                    Color.fromRGBO(143, 148, 251, .6),
                                  ]
                                )
                              ),
                              child: Container(
                          width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _submitCode(_codeController.text);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.blue, // Set the button color
                                                  ),
                                                  child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                        
                            )
                      ),
            SizedBox(height: 20),
            if (isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}