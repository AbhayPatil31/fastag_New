import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fast_tag/api/network/create_json.dart';
import 'package:fast_tag/api/network/network.dart';
import 'package:fast_tag/api/network/uri.dart';

import 'package:fast_tag/pages/tickets_list.dart';
import 'package:fast_tag/utility/colorfile.dart';
import 'package:fast_tag/utility/snackbardesign.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/response/Helpresponse.dart';

class RaiseTicketsPage extends StatefulWidget {
  @override
  _RaiseTicketsPageState createState() => _RaiseTicketsPageState();
}

class _RaiseTicketsPageState extends State<RaiseTicketsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  TextEditingController _controller = TextEditingController();

  String? attachement;

  String? attachmentPath;

  @override
  void initState() {
    super.initState();
    NetworkcallforHelplist();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    finallocationlist.clear();
  }

  String? selectedHelpTypeId;
  List<HelpData> finallocationlist = [];
  //List<HelpData> helplistData = [];

  Future<void> NetworkcallforHelplist() async {
    try {
      NetworkCall networkCall = NetworkCall();
      List<Object?>? list = await networkCall.getMethod(
          URLS().help_type_master_api, URLS().help_type_master_apiUrl, context);
      if (list != null) {
        List<Helpresponse> helplistResponse = List.from(list!);

        String? status = helplistResponse[0].status;
        switch (status) {
          case "true":
            finallocationlist = helplistResponse[0].data!;
            // finallocationlist.addAll(helplistData);
            setState(() {});
            break;
          case "false":
            finallocationlist = [];
            setState(() {});
            break;
        }
      } else {
        Navigator.pop(context);
        log('No data found');
      }
    } catch (e) {
      Navigator.pop(context);
      log(e.toString());
    }
  }

  Future<void> uploadFile(File file, String filename, String filetype) async {
    log("File base name: $filename");
    try {
      final bytes = await file.readAsBytes();
      String base64String = base64Encode(bytes);
      attachement =
          base64String; // Store the base64 string in the global variable

      switch (filetype) {
        case "_submitfile":
          // Additional processing if needed
          break;
      }
    } catch (e) {
      log("Error uploading file: $e");
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Allow picking only one file at a time
      type: FileType.image, // Allow picking image files only
    );

    if (result != null) {
      String fileName = result.files.first.name;
      String filePath = result.files.first.path!;

      setState(() {
        uploadFile(File(filePath), fileName, "_submitfile");
        attachmentPath = fileName;
        _controller.text =
            fileName; // Set the selected filename to the TextField
      });
    } else {
      // User canceled the file picking process
    }
  }

  Future<void> addTickit(
      String agent_id, String description, String help_type_id) async {
    try {
      String raiseString = createjson().ticketraiseresponseFromJson(
          agent_id, description, help_type_id, attachement!);
      log("createjson : $raiseString");
      NetworkCall networkCall = NetworkCall();

      var ticketraiseresponse = await networkCall.postMethod(
        URLS().raise_ticket_api,
        URLS().raise_ticket_apiUrl,
        raiseString,
        context,
      );

      if (ticketraiseresponse != null) {
        List<dynamic>? responseData = List.from(ticketraiseresponse!);
        String status = responseData[0].status!;

        switch (status) {
          case "true":
            SnackBarDesign(
                "Ticket raised successfully!!",
                context,
                colorfile().sucessmessagebcColor,
                colorfile().sucessmessagetxColor);

            // Clear Input
            _descriptionController.clear();
            Navigator.pop(context);
            break;

          case "false":
            SnackBarDesign(
                "Unable to raise ticket, Please try again!",
                context,
                colorfile().errormessagebcColor,
                colorfile().errormessagetxColor);

            break;
        }
      } else {
        print('Invalid response or null value');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Raise Ticket',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D2024),
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, We are here to help',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D2024),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 219, 213, 213),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField2<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(255, 247, 244, 244),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          // contentPadding: EdgeInsets.symmetric(
                          //     vertical: 10,
                          //     horizontal: 20), // Adjust vertical padding
                          hintText: 'Select Your Help Type',
                          hintStyle: TextStyle(
                            color: Color(0xFF1D2024),
                            fontSize: 14,
                          ),
                        ),
                        items: finallocationlist.map((HelpData helpData) {
                          return DropdownMenuItem<String>(
                            value: helpData.id,
                            child: Text(helpData.helpType ?? '',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF353B43),
                                  fontSize: 14,
                                )),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedHelpTypeId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a help type';
                          }
                          return null;
                        },
                        value: selectedHelpTypeId,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 219, 213, 213)
                                .withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          hintText: 'Description',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 252, 250, 250),
                            ),
                          ),
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                        ),
                        minLines: 10,
                        maxLines: 15,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _pickFile(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Container(
                    height: 48,
                    width: 350,
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   color: Color.fromARGB(255, 136, 135, 135),
                      //   width: 1.2,
                      // ),
                      // boxShadow: [BoxShadow(offset: Offset(0,4),),],
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: TextField(
                      controller:
                          _controller, // Connect the controller to the TextField
                      enabled: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 5, right: 0, bottom: 10),
                          // child: Icon(
                          //   Icons.file_download_outlined,
                          //   size: 30,
                          //   color: Color(0xFF008357),
                          // ),
                          child: Image.asset(
                            "images/upload-icon.png",
                            height: 19,
                            width: 19,
                          ),
                        ),
                        hintText: 'Attachment',
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Container(
                  width: 350,
                  height: 60,
                  margin: EdgeInsets.only(top: 20, left: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF08469D),
                        Color(0xFF0056D0),
                        Color(0xFF0C92DD),
                      ],
                      stops: [0.0, 0.3425, 0.9974],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x00000008),
                        offset: Offset(10, -2),
                        blurRadius: 75,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String id = prefs.getString('user_id') ?? '';
                      String description = _descriptionController.text;

                      // Validate form and add reply only if validation passes
                      if (_formKey.currentState!.validate()) {
                        if (selectedHelpTypeId != null) {
                          addTickit(id, description, selectedHelpTypeId!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select a help type'),
                              duration: Duration(seconds: 5),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Colors.transparent), // Transparent background
                      elevation: MaterialStateProperty.all(
                          0), // Remove default elevation
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RaiseTicketsPage(),
  ));
}
