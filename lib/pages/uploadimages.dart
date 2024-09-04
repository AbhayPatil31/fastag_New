import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fast_tag/api/response/uploadimagesresponse.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import '../api/network/create_json.dart';
import '../api/network/network.dart';
import '../api/network/uri.dart';
import '../utility/colorfile.dart';
import '../utility/progressdialog.dart';
import '../utility/snackbardesign.dart';
import 'assign_vehicle_details.dart';

bool imageRCFRONT = false,
    imageRCBACK = false,
    imageVEHICLEFRONT = false,
    imageVEHICLESIDE = false,
    imageTAGAFFIX = false;
String rcfrontimage = "",
    rcbackimage = "",
    vehiclefrontimage = "",
    vehiclesideimage = "",
    tagfiximage = "";
String rcfrontimageattachmentPath = "",
    rcbackimageattachmentPath = "",
    vehiclefronttachmentPath = "",
    vehiclesidetachmentPath = "",
    tagfixachmentPath = "";
String frontImageErrorMessage = "",
    backImageErrorMessage = "",
    vehiclefrontErrorMessage = "",
    vehiclesideErrorMessage = "",
    tagfixErrorMessage = "";
String? rcfrontImagePath,
    rcbackImagePath,
    vehiclefrontImagePath,
    vehiclesideImagePath,
    tagfixImagePath;

class UploadImages extends StatefulWidget {
  String sessionId, vehiclenumber, name, chasisnumber, serialnumber;
  UploadImages(this.sessionId, this.vehiclenumber, this.name, this.chasisnumber,
      this.serialnumber);
  State createState() => UploadImagesState();
}

class UploadImagesState extends State<UploadImages> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    clearallfields();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    clearallfields();
  }

  clearallfields() {
    imageRCFRONT = false;
    imageRCBACK = false;
    imageVEHICLEFRONT = false;
    imageVEHICLESIDE = false;
    imageTAGAFFIX = false;
    rcfrontimage = "";
    rcbackimage = "";
    vehiclefrontimage = "";
    vehiclesideimage = "";
    tagfiximage = "";
    rcfrontimageattachmentPath = "";
    rcbackimageattachmentPath = "";
    vehiclefronttachmentPath = "";
    vehiclesidetachmentPath = "";
    tagfixachmentPath = "";
    frontImageErrorMessage = "";
    backImageErrorMessage = "";
    vehiclefrontErrorMessage = "";
    vehiclesideErrorMessage = "";
    tagfixErrorMessage = "";
    rcfrontfilename = "";
    rcbackfilename = "";
    vehiclefrontfilename = "";
    vehiclesidefilename = "";
    tagfixfilename = "";
  }

  bool _rcback = false;
  bool _vehiclefront = false;
  bool _vehicleside = false;
  bool _tagfix = false;
  bool _nextButton = false;
  Future<void> Networkcallforuploadimage(String ImageType, String img) async {
    try {
      ProgressDialog.showProgressDialog(context, " title");
      String assignfaasttag = createjson()
          .createjsonforuploadimages(widget.sessionId, ImageType, img, context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().uploadDocument,
          URLS().uploadDocument_url,
          assignfaasttag,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Uploadimagesresponse> response = List.from(list!);
        if (response[0].data!.isNotEmpty) {
          String status = response[0].data![0].response!.status!;
          switch (status) {
            case "success":
              if (ImageType == "RCFRONT") {
                imageRCFRONT = true;
                _rcback = true;
              } else if (ImageType == "RCBACK") {
                imageRCBACK = true;
                _vehiclefront = true;
              } else if (ImageType == "VEHICLEFRONT") {
                imageVEHICLEFRONT = true;
                _vehicleside = true;
              } else if (ImageType == "VEHICLESIDE") {
                imageVEHICLESIDE = true;
                _tagfix = true;
              } else if (ImageType == "TAGAFFIX") {
                imageTAGAFFIX = true;
                _nextButton = true;
              }
              setState(() {});

              break;
            case "failed":
              SnackBarDesign(
                  response[0].data![0].response!.msg!,
                  context,
                  colorfile().errormessagebcColor,
                  colorfile().errormessagetxColor);
              break;
          }
        } else {
          Navigator.pop(context);
          SnackBarDesign(response[0].message!, context,
              colorfile().errormessagebcColor, colorfile().errormessagetxColor);
        }
      } else {
        Navigator.pop(context);
        SomethingWentWrongSnackBarDesign(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Documents',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2024),
              fontSize: 18,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Container(
                    child: Text(
                      'Please upload images, size less than 100KB',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            uploadrcfrontfile(),
            SizedBox(
              height: 5,
            ),
            _rcback ? uploadrcbackfile() : Container(),
            SizedBox(
              height: 5,
            ),
            _vehiclefront ? uploadfrontimage() : Container(),
            SizedBox(
              height: 5,
            ),
            _vehicleside ? uploadsideimage() : Container(),
            SizedBox(
              height: 5,
            ),
            _tagfix ? uploadtagfiximage() : Container(),
            SizedBox(
              height: 5,
            ),
            SizedBox(height: 30),
            _nextButton ? buttonwidget() : Container(),
          ],
        ),
      ),
    );
  }

  String _rcfrontloader = "0";
  String _rcbackloader = "0";

  String _vehiclefrontloader = "0";

  String _vehiclesideloader = "0";
  String _taxfixloader = "0";

  Widget uploadrcfrontfile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Upload Vehicle RC Front Image',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 83, 83, 83),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              _rcfrontloader = "1";
              validatercfrontimage = true;
              setState(() {});
              profile(context, "RCFRONT");
              imageRCFRONT
                  ? null
                  : _rcfrontloader == "1"
                      ? null
                      : Networkcallforuploadimage("RCFRONT", rcfrontimage);
            },
            child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: rcfrontimage == ""
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            height: 40,
                            image: AssetImage('images/car.png'),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tap to capture image',
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                          _rcfrontloader == "1"
                              ? CircularProgressIndicator(
                                  color: Colors.blue,
                                )
                              : Container(),
                        ],
                      )
                    : _rcfrontloader == "1"
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(rcfrontImagePath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                // compressloader
                //     ? ClipRRect(
                //         borderRadius: BorderRadius.circular(16),
                //         child: Image.file(
                //           File(rcfrontImagePath!),
                //           fit: BoxFit.cover,
                //           width: double.infinity,
                //         ),
                //       )
                //     : CircularProgressIndicator(),
                ),
          ),
          SizedBox(
            height: 5,
          ),
          validatercfrontimage
              ? Container()
              : Text(
                  errorforrcfrontimage,
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
          SizedBox(height: 10),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     imageRCFRONT
          //         ? null
          //         : _rcfrontloader == "1"
          //             ? null
          //             : Networkcallforuploadimage("RCFRONT", rcfrontimage);
          //   },
          //   icon: Icon(
          //     Icons.upload_rounded,
          //     color: Colors.blue,
          //   ),
          //   label: imageRCFRONT
          //       ? Text(
          //           'Uploaded RC Front Image',
          //           style: TextStyle(fontSize: 10, color: Colors.blue),
          //         )
          //       : Text(
          //           'Click To Upload RC Front Image',
          //           style: TextStyle(fontSize: 10, color: Colors.blue),
          //         ),
          //   style: ElevatedButton.styleFrom(
          //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //     textStyle: TextStyle(fontSize: 16),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget uploadrcbackfile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  'Upload Vehicle RC Back Image',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 83, 83, 83),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              _rcbackloader = "1";
              validatercbackimage = true;
              setState(() {});
              profile(context, "RCBACK");
            },
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: rcbackimage == ""
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          height: 40,
                          image: AssetImage('images/car.png'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tap to capture image',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        _rcbackloader == "1"
                            ? CircularProgressIndicator(
                                color: Colors.blue,
                              )
                            : Container()
                      ],
                    )
                  : _rcbackloader == "1"
                      ? Center(
                          child: CircularProgressIndicator(
                          color: Colors.blue,
                        ))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(rcbackImagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          validatercbackimage
              ? Container()
              : Text(
                  errorforrcbackimage,
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
          SizedBox(height: 10),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     imageRCBACK
          //         ? null
          //         : _rcbackloader == "1"
          //             ? null
          //             : Networkcallforuploadimage("RCBACK", rcbackimage);
          //   },
          //   icon: Icon(Icons.upload_rounded, color: Colors.blue),
          //   label: imageRCBACK
          //       ? Text(
          //           'Uploaded RC Back Image',
          //           style: TextStyle(fontSize: 10, color: Colors.blue),
          //         )
          //       : Text(
          //           'Click To Upload RC Back Image',
          //           style: TextStyle(fontSize: 10, color: Colors.blue),
          //         ),
          //   style: ElevatedButton.styleFrom(
          //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //     textStyle: TextStyle(fontSize: 16),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget uploadfrontimage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  'Upload Vehicle Front Image',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 83, 83, 83),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              _vehiclefrontloader = "1";
              validatercfrontimage = true;
              setState(() {});
              profile(context, "VEHICLEFRONT");
            },
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(
                  color: Colors.blue,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: vehiclefrontimage == ""
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          height: 40,
                          image: AssetImage('images/car.png'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tap to capture image',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        _vehiclefrontloader == "1"
                            ? CircularProgressIndicator(
                                color: Colors.blue,
                              )
                            : Container()
                      ],
                    )
                  : _vehiclefrontloader == "1"
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(vehiclefrontImagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          validatevehiclefrontimage
              ? Container()
              : Text(
                  errorforfrontvehicleimage,
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
          SizedBox(height: 10),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     imageVEHICLEFRONT
          //         ? null
          //         : _vehiclefrontloader == "1"
          //             ? null
          //             : Networkcallforuploadimage(
          //                 "VEHICLEFRONT", vehiclefrontimage);
          //   },
          //   icon: Icon(Icons.upload_rounded, color: Colors.blue),
          //   label: imageVEHICLEFRONT
          //       ? Text(
          //           'Uploaded Vehicle Front Image',
          //           style: TextStyle(fontSize: 10, color: Colors.blue),
          //         )
          //       : Text(
          //           'Click To Upload Vehicle Front Image',
          //           style: TextStyle(fontSize: 10, color: Colors.blue),
          //         ),
          //   style: ElevatedButton.styleFrom(
          //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //     textStyle: TextStyle(fontSize: 16),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget uploadsideimage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  'Upload Vehicle Side Image',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 83, 83, 83),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              _vehiclesideloader = "1";
              validatevehiclesideimage = true;
              setState(() {});
              profile(context, "VEHICLESIDE");
            },
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(
                  color: Colors.blue,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: vehiclesideimage == ""
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          height: 40,
                          image: AssetImage('images/car.png'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tap to capture image',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        _vehiclesideloader == "1"
                            ? CircularProgressIndicator(
                                color: Colors.blue,
                              )
                            : Container()
                      ],
                    )
                  : _vehiclesideloader == "1"
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(vehiclesideImagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          validatevehiclesideimage
              ? Container()
              : Text(
                  errorforsidevehicleimage,
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
          SizedBox(height: 10),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     imageVEHICLESIDE
          //         ? null
          //         : _vehiclesideloader == "1"
          //             ? null
          //             : Networkcallforuploadimage(
          //                 "VEHICLESIDE", vehiclesideimage);
          //   },
          //   icon: Icon(Icons.upload_rounded, color: Colors.blue),
          //   label: imageVEHICLESIDE
          //       ? Text(
          //           'Uploaded Vehicle Side Image',
          //           style: TextStyle(fontSize: 10, color: Colors.blue),
          //         )
          //       : Text(
          //           'Click To Upload Vehicle Side Image',
          //           style: TextStyle(fontSize: 10, color: Colors.blue),
          //         ),
          //   style: ElevatedButton.styleFrom(
          //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //     textStyle: TextStyle(fontSize: 16),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget uploadtagfiximage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Text(
                  'Upload Tag Fix Image',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color.fromARGB(255, 83, 83, 83),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              _taxfixloader = "1";
              validatetagfiximage = true;
              setState(() {});
              profile(context, "TAGAFFIX");
            },
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(
                  color: Colors.blue,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: tagfiximage == ""
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          height: 40,
                          image: AssetImage('images/car.png'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tap to capture image',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        _taxfixloader == "1"
                            ? CircularProgressIndicator(
                                color: Colors.blue,
                              )
                            : Container(),
                      ],
                    )
                  : _taxfixloader == "1"
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(tagfixImagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          validatetagfiximage
              ? Container()
              : Text(
                  errorfortagfiximage,
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
          SizedBox(height: 10),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     imageTAGAFFIX
          //         ? null
          //         : _taxfixloader == "1"
          //             ? null
          //             : Networkcallforuploadimage("TAGAFFIX", tagfiximage);
          //   },
          //   icon: Icon(Icons.upload_rounded, color: Colors.blue),
          //   label: imageTAGAFFIX
          //       ? Text(
          //           'Uploaded Tag Fix Image',
          //           style: TextStyle(fontSize: 10, color: Colors.blue),
          //         )
          //       : Text(
          //           'Click To Upload Tag Fix Image',
          //           style: TextStyle(fontSize: 10, color: Colors.blue),
          //         ),
          //   style: ElevatedButton.styleFrom(
          //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //     textStyle: TextStyle(fontSize: 16),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  String errorforrcfrontimage = "Please upload vehicle rc front image",
      errorforrcbackimage = "Please upload vehicle rc back image",
      errorforfrontvehicleimage = "Please upload vehicle front image",
      errorforsidevehicleimage = "Please upload vehicle side image",
      errorfortagfiximage = "Please upload tag fix image";
  bool validatercfrontimage = true,
      validatercbackimage = true,
      validatevehiclefrontimage = true,
      validatevehiclesideimage = true,
      validatetagfiximage = true;

  Widget buttonwidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        height: 50,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF08469D),
              Color(0xFF0056D0),
              Color(0xFF0C92DD),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ElevatedButton(
          onPressed: () {
            validate();
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors
                  .transparent, // Set background to transparent to show gradient
            ),
            shadowColor: MaterialStateProperty.all<Color>(
              Colors.transparent, // No shadow color
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          child: Container(
            height: 60,
            width: double.infinity, // Make button width match its parent
            child: Center(
              child: Text(
                'Next',
                style: TextStyle(
                  color: Colors
                      .white, // Set text color to white for better contrast
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<File> compressImageUsingImagePackage(File file,
      {int maxSizeKB = 200}) async {
    final int maxSizeBytes = maxSizeKB * 1024; // Convert KB to bytes

    // Read the image file
    final Uint8List imageBytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image.');
    }

    int quality = 100;
    File compressedFile;
    while (true) {
      // Encode the image with the current quality
      final Uint8List result = img.encodeJpg(image, quality: quality);

      if (result == null) {
        throw Exception('Failed to encode image.');
      }

      // Define a temporary file path
      compressedFile = File(
          '${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(result);

      // Check the size of the compressed file
      final fileSize = await compressedFile.length();
      if (fileSize <= maxSizeBytes) {
        break; // Stop if the file size is under or equal to the target size
      }

      // Reduce the quality for further compression
      quality -= 10;
      if (quality <= 0) {
        break; // Stop if quality is zero or less
      }
    }

    return compressedFile;
  }

  Future<void> profile(BuildContext context, String imagetype) async {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 396,
            padding: EdgeInsets.only(left: 0, top: 38, right: 0, bottom: 38),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Text(
                    'Choose Source',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF008357),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Text(
                    'Select a source for the image upload',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 30, top: 28, right: 30, bottom: 2),
                  child: Row(
                    children: [
                      // Expanded(
                      //   child: GestureDetector(
                      //     onTap: () async {
                      //       Navigator.of(context).pop();
                      //       final XFile? image = await ImagePicker().pickImage(
                      //           source: ImageSource.camera, imageQuality: 50);
                      //       if (image != null) {
                      //         if (imagetype == "RCFRONT") {
                      //           rcfrontImagePath = image.path;
                      //         } else if (imagetype == "RCBACK") {
                      //           rcbackImagePath = image.path;
                      //         } else if (imagetype == "VEHICLEFRONT") {
                      //           vehiclefrontImagePath = image.path;
                      //         } else if (imagetype == "VEHICLESIDE") {
                      //           vehiclesideImagePath = image.path;
                      //         } else if (imagetype == "TAGAFFIX") {
                      //           tagfixImagePath = image.path;
                      //         }
                      //         setState(() {});
                      //         String fileName = image.name;
                      //         await uploadFile(
                      //             File(image.path), fileName, imagetype);
                      //       }
                      //     },
                      //     child: Container(
                      //       padding: EdgeInsets.only(top: 10, bottom: 10),
                      //       decoration: BoxDecoration(
                      //           border: Border.all(
                      //             width: 0.5,
                      //             color: Color(0xFF008357),
                      //           ),
                      //           borderRadius: BorderRadius.circular(5)),
                      //       child: Center(
                      //         child: Text(
                      //           "Camera",
                      //           style: TextStyle(
                      //               fontSize: 14,
                      //               color: Color(0xFF008357),
                      //               fontWeight: FontWeight.w500),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.of(context).pop();
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                      'jpg',
                                      'jpeg',
                                      'png',
                                      // 'pdf'
                                    ],
                                    compressionQuality: 50);
                            if (result != null) {
                              setState(() {
                                if (imagetype == "RCFRONT") {
                                  rcfrontImagePath = result.files.single.path!;
                                  _rcfrontloader = "2";
                                } else if (imagetype == "RCBACK") {
                                  rcbackImagePath = result.files.single.path!;
                                } else if (imagetype == "VEHICLEFRONT") {
                                  vehiclefrontImagePath =
                                      result.files.single.path!;
                                } else if (imagetype == "VEHICLESIDE") {
                                  vehiclesideImagePath =
                                      result.files.single.path!;
                                } else if (imagetype == "TAGAFFIX") {
                                  tagfixImagePath = result.files.single.path!;
                                }
                              });
                              final ext =
                                  result.files.first.name.split('.').last;
                              String fileName = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString() +
                                  '.' +
                                  ext;
                              await uploadFile(File(result.files.single.path!),
                                  fileName, imagetype);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: Color(0xFF008357)),
                                color: Color(0xFF008357),
                                borderRadius: BorderRadius.circular(5)),
                            child: Center(
                              child: Text(
                                "File Picker",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String rcfrontfilename = "",
      rcbackfilename = "",
      vehiclefrontfilename = "",
      vehiclesidefilename = "",
      tagfixfilename = "";
  bool compressloader = false;
  Future<void> uploadFile(File file, String filename, String filetype) async {
    print("File base name: " + filename);
    showfilename = filename;
    try {
      compressloader = true;

      // Compress the image to ensure it is <= 200KB
      File compressedFile =
          await compressImageUsingImagePackage(file, maxSizeKB: 200);

      final bytes = await compressedFile.readAsBytes();
      String base64String = base64Encode(bytes);

      // Resetting the loader to ensure the function can be called again
      String loaderVar = "0";

      switch (filetype) {
        case "RCFRONT":
          rcfrontimage = base64String;
          rcfrontimageattachmentPath = filename;
          loaderVar = _rcfrontloader = "2";
          final ext = filename.split('.').last;
          rcfrontfilename = "RCFRONT_" +
              DateTime.now().microsecondsSinceEpoch.toString() +
              '.' +
              ext;
          await Networkcallforuploadimage("RCFRONT", rcfrontimage);
          _rcfrontloader = "0"; // Reset loader
          setState(() {});
          break;
        case "RCBACK":
          rcbackimage = base64String;
          rcbackimageattachmentPath = filename;
          loaderVar = _rcbackloader = "2";
          final ext = filename.split('.').last;
          rcbackfilename = "RCBACK_" +
              DateTime.now().microsecondsSinceEpoch.toString() +
              '.' +
              ext;
          await Networkcallforuploadimage("RCBACK", rcbackimage);
          _rcbackloader = "0"; // Reset loader
          setState(() {});
          break;
        case "VEHICLEFRONT":
          vehiclefrontimage = base64String;
          vehiclefronttachmentPath = filename;
          loaderVar = _vehiclefrontloader = "2";
          final ext = filename.split('.').last;
          vehiclefrontfilename = "VEHICLEFRONT_" +
              DateTime.now().microsecondsSinceEpoch.toString() +
              '.' +
              ext;
          await Networkcallforuploadimage("VEHICLEFRONT", vehiclefrontimage);
          _vehiclefrontloader = "0"; // Reset loader
          setState(() {});
          break;
        case "VEHICLESIDE":
          vehiclesideimage = base64String;
          vehiclesidetachmentPath = filename;
          loaderVar = _vehiclesideloader = "2";
          final ext = filename.split('.').last;
          vehiclesidefilename = "VEHICLESIDE_" +
              DateTime.now().microsecondsSinceEpoch.toString() +
              '.' +
              ext;
          await Networkcallforuploadimage("VEHICLESIDE", vehiclesideimage);
          _vehiclesideloader = "0"; // Reset loader
          setState(() {});
          break;
        case "TAGAFFIX":
          tagfiximage = base64String;
          tagfixachmentPath = filename;
          loaderVar = _taxfixloader = "2";
          final ext = filename.split('.').last;
          tagfixfilename = "TAGAFFIX_" +
              DateTime.now().microsecondsSinceEpoch.toString() +
              '.' +
              ext;
          await Networkcallforuploadimage("TAGAFFIX", tagfiximage);
          _taxfixloader = "0"; // Reset loader
          setState(() {});
          break;
      }
    } catch (e) {
      print("Error uploading file: " + e.toString());
      // Reset the loader in case of error
      resetLoadersBasedOnFileType(filetype);
      setState(() {});
    }
  }

  static uploadfile(File file, String filename, BuildContext context) async {
    print("File base name" + filename);
    final bytes = await File(file.path).readAsBytes();
    try {
      dio.FormData formData = dio.FormData.fromMap({
        'filename': await dio.MultipartFile.fromBytes(bytes, filename: filename)
      });
      final response1 = dio.Dio().post(
        URLS().file_send_in_dir,
        data: formData,
        onSendProgress: (count, total) {
          print('count:$count,$total');
          if (count == total) {}
        },
      );
      print("file upload response" + response1.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  validate() {
    validatercfrontimage = true;
    validatercbackimage = true;
    validatevehiclefrontimage = true;
    validatevehiclesideimage = true;
    validatetagfiximage = true;
    if (rcfrontimage == "" &&
        rcbackimage == "" &&
        vehiclefrontimage == "" &&
        vehiclesideimage == "" &&
        tagfiximage == "") {
      validatercfrontimage = false;
      validatercbackimage = false;
      validatevehiclefrontimage = false;
      validatevehiclesideimage = false;
      validatetagfiximage = false;
      setState(() {});
    } else if (rcbackimage == "" &&
        vehiclefrontimage == "" &&
        vehiclesideimage == "" &&
        tagfiximage == "") {
      validatercbackimage = false;
      validatevehiclefrontimage = false;
      validatevehiclesideimage = false;
      validatetagfiximage = false;
      setState(() {});
    } else if (vehiclefrontimage == "" &&
        vehiclesideimage == "" &&
        tagfiximage == "") {
      validatevehiclefrontimage = false;
      validatevehiclesideimage = false;
      validatetagfiximage = false;
      setState(() {});
    } else if (vehiclesideimage == "" && tagfiximage == "") {
      validatevehiclesideimage = false;
      validatetagfiximage = false;
      setState(() {});
    } else if (tagfiximage == "") {
      validatetagfiximage = false;
      setState(() {});
    } else if (imageRCFRONT == false &&
        imageRCBACK == false &&
        imageVEHICLEFRONT == false &&
        imageVEHICLESIDE == false &&
        imageTAGAFFIX == false) {
      SnackBarDesign("Upload all files", context,
          colorfile().errormessagebcColor, colorfile().errormessagetxColor);
    } else if (imageRCFRONT == true &&
        imageRCBACK == true &&
        imageVEHICLEFRONT == true &&
        imageVEHICLESIDE == true &&
        imageTAGAFFIX == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AssignVehicleDetails(
                widget.sessionId,
                widget.vehiclenumber,
                widget.name,
                widget.chasisnumber,
                widget.serialnumber)),
      );
    }
  }

  void resetLoadersBasedOnFileType(String filetype) {
    switch (filetype) {
      case "RCFRONT":
        _rcfrontloader = "0";
        break;
      case "RCBACK":
        _rcbackloader = "0";
        break;
      case "VEHICLEFRONT":
        _vehiclefrontloader = "0";
        break;
      case "VEHICLESIDE":
        _vehiclesideloader = "0";
        break;
      case "TAGAFFIX":
        _taxfixloader = "0";
        break;
    }
  }
}
