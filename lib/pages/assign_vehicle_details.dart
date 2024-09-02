import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart' as dio;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fast_tag/api/call/addvehicledetailscall.dart';
import 'package:fast_tag/api/response/addvehicledetailsresponse.dart';
import 'package:fast_tag/api/response/getallbarcoderesponse.dart';
import 'package:fast_tag/pages/assign_barcode.dart';
import 'package:fast_tag/pages/request_fastag.dart';
import 'package:fast_tag/utility/progressdialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fast_tag/pages/homeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as dev;
import '../api/network/create_json.dart';
import '../api/network/network.dart';
import '../api/network/uri.dart';
import '../api/response/requestcategoryresponse.dart';
import '../utility/colorfile.dart';
import '../utility/snackbardesign.dart';

final _namecontroller = TextEditingController();
final _vehiclenumbercontroller = TextEditingController();
final _vehiclechassisnumbercontroller = TextEditingController();
String? showfilename;
//final _vehicleserialnumbercontroller = TextEditingController();
final TextEditingController _vehicleserialnumbercontroller =
    TextEditingController();

class AssignVehicleDetails extends StatefulWidget {
  String sessionId, vehiclenumber, customername, chasisnumber, serialnumber;

  AssignVehicleDetails(this.sessionId, this.vehiclenumber, this.customername,
      this.chasisnumber, this.serialnumber);
  State createState() => AssignVehicleDetailsState();
}

class AssignVehicleDetailsState extends State<AssignVehicleDetails> {
  TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.infinity, // Cover full width
            height: 350, // Set a fixed height as needed

            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/succes.png', // Replace with the actual path to your image asset
                    width: 200, // Set image width as needed
                    height: 200, // Set image height as needed
                  ),
                  SizedBox(height: 20), // Space between image and text
                  Text(
                    'Activation Successful',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 5),

                  Text(
                    'Your account is ready to use. You will\n be redirected to the Home page in\n a few seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

//rejection popup
  void _showRejectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.infinity, // Cover full width
            height: 400, // Set a fixed height as needed

            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/sad.png', // Replace with the actual path to your image asset
                    width: 200, // Set image width as needed
                    height: 200, // Set image height as needed
                  ),
                  // SizedBox(height: 5), // Space between image and text
                  Text(
                    'Activation Rejected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 5),

                  Text(
                    'Your account is ready to use. You will\n be redirected to the Home page in\n a few seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Delay redirecting to the home screen for 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyDashboard()),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _namecontroller.text = widget.customername;
    _vehiclenumbercontroller.text = widget.vehiclenumber;
    _vehiclechassisnumbercontroller.text = widget.chasisnumber ?? '';
    _vehicleserialnumbercontroller.text = widget.serialnumber ?? '';
    Networkcallforwallettransactionhistory();
    Networkcallgetallbarcode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _vehiclenumbercontroller.clear();
    _vehiclechassisnumbercontroller.clear();
    _vehicleserialnumbercontroller.clear();
    _suggestions.clear();
    _controller.clear();
  }

  List<RequestcategoryDatum> requestcategory = [];
  List<GetallbarcodeDatum> barcodelist = [];

  Future<void> Networkcallforwallettransactionhistory() async {
    try {
      ProgressDialog.showProgressDialog(context, "title");
      String jsonstring = createjson().createjsonforgetallbarcode(context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().fastag_category_request_api,
          URLS().fastag_category_request_api_url,
          jsonstring,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Requestcategoryresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            if (response[0].data!.isEmpty) {
              print("Vehicle category not available");
              // SnackBarDesign(
              //     "Vehicle category not available",
              //     context,
              //     colorfile().errormessagebcColor,
              //     colorfile().errormessagetxColor);
            } else {
              requestcategory = response[0].data!;
            }
            setState(() {});
            break;
          case "false":
            setState(() {});
            SnackBarDesign(
                response[0].message!,
                context,
                colorfile().errormessagebcColor,
                colorfile().errormessagetxColor);
            break;
        }
      } else {
        Navigator.pop(context);
        SomethingWentWrongSnackBarDesign(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> Networkcallgetallbarcode() async {
    try {
      ProgressDialog.showProgressDialog(context, "title");
      String jsonstring = createjson().createjsonforgetallbarcode(context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().get_my_available_barcode,
          URLS().get_my_available_barcode_url,
          jsonstring,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Getallbarcoderesponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            if (response[0].data!.isEmpty) {
              SnackBarDesign(
                  "Barcode not available",
                  context,
                  colorfile().errormessagebcColor,
                  colorfile().errormessagetxColor);
            } else {
              barcodelist = response[0].data!;

              for (int i = 0; i < barcodelist.length; i++) {
                _suggestions.add(barcodelist[i].barcode!);
              }
            }
            setState(() {});
            break;
          case "false":
            setState(() {});
            SnackBarDesign(
                response[0].message!,
                context,
                colorfile().errormessagebcColor,
                colorfile().errormessagetxColor);
            break;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Details',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2024),
              fontSize: 18,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color.fromARGB(
                  255, 176, 206, 245), // Background color for the row
              padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vehicle Details',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Image(
                    height: 65,
                    image: AssetImage(
                        'images/automobile.png'), // Replace 'images/automobile.png' with your image path
                  )
                ],
              ),
            ),

            SizedBox(height: 30), // Adding space before the input fields

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Your Vehicle Details',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 16, // Adjust the font size as needed
                    ),
                  ),
                  SizedBox(height: 15),
                  // categorydropdown(),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  customername(),
                  vehiclenumber(),
                  SizedBox(
                    height: 5,
                  ),
                  vehiclechassis(),
                  SizedBox(
                    height: 5,
                  ),
                  //vehiclebarcode(),
                  newbarcode(),
                  SizedBox(
                    height: 5,
                  ),

                  SizedBox(height: 10),
                ],
              ),
            ),
            SizedBox(height: 30), // Adding space before the button

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
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
                    //_showConfirmationDialog(context);
                    validatefields();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors
                          .transparent, // Set background to transparent to show gradient
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget categorydropdown() {
    return requestcategory.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 55,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color:
                          Color.fromARGB(255, 219, 213, 213).withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'Select Vehicle Category*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: requestcategory.map<DropdownMenuItem<String>>((e) {
                      return DropdownMenuItem(
                          child: Text(
                            e.categoryName.toString(),
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          value: e.id.toString());
                    }).toList(),
                    value: vehiclecategoryselectedValue,
                    onChanged: (value) {
                      setState(() {
                        vehiclecategoryselectedValue = value;
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    dropdownStyleData: const DropdownStyleData(
                      maxHeight: 400,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                    dropdownSearchData: DropdownSearchData(
                      searchController: textEditingControllervehiclecategory,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 4,
                          right: 8,
                          left: 8,
                        ),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: textEditingControllervehiclecategory,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for vehicle category',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value.toString().contains(searchValue);
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllervehiclecategory.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatevehiclecategory
                  ? Container()
                  : Text(
                      errormessageforcategory,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
  }

  Widget customername() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 219, 213, 213).withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _namecontroller,
        readOnly: true,
        enabled: true,
        decoration: InputDecoration(
          hintText: 'Customer Name*',
          // errorText: validatevehiclecategory ? null : errormessageforcategory,
          // errorStyle: TextStyle(color: Colors.red, fontSize: 10),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: const Color.fromARGB(255, 252, 250, 250)!),
          ),
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget vehiclenumber() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 219, 213, 213).withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _vehiclenumbercontroller,
        readOnly: true,
        enabled: true,
        decoration: InputDecoration(
          hintText: 'Vehicle Number*',
          errorText: validatevehiclecategory ? null : errormessageforcategory,
          errorStyle: TextStyle(color: Colors.red, fontSize: 10),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: const Color.fromARGB(255, 252, 250, 250)!),
          ),
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget vehiclechassis() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 219, 213, 213).withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _vehiclechassisnumbercontroller,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
        ],
        textCapitalization: TextCapitalization.characters,
        onChanged: (value) {
          validatechasisnumber = true;
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Vehicle Chassis Number',
          errorText: validatechasisnumber ? null : errorforchasisnumber,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: const Color.fromARGB(255, 252, 250, 250)!),
          ),
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  void _filterSuggestions(String input) {
    if (input.length >= 4) {
      String lastFourDigits = input.substring(input.length - 4);
      String? matchingSuggestion = _suggestions.firstWhere(
        (item) => item.endsWith(lastFourDigits),
        orElse: () => "",
      );

      setState(() {
        if (matchingSuggestion.isNotEmpty) {
          _controller.text = matchingSuggestion;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: matchingSuggestion.length),
          );
          validateserialnumber = true;
          errorforserialnumber = "";
        } else {
          _controller.clear();
        }
      });
    } else {
      // setState(() {
      //   _controller.clear();
      // });
      validateserialnumber = false;
      errorforserialnumber = "Please enter last 4 digits of serial number";
      setState(() {});
    }
  }

  Widget newbarcode() {
    return _suggestions.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 219, 213, 213)
                      .withOpacity(0.5), // Shadow color
                  spreadRadius: 3, // Spread radius
                  blurRadius: 5, // Blur radius
                  offset: Offset(0, 3), // Offset in x and y directions
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              onChanged: (text) => _filterSuggestions(text),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter last 4 digits of serial number*',
                errorText: validateserialnumber ? null : errorforserialnumber,
                errorStyle: TextStyle(color: Colors.red, fontSize: 10),
                border: OutlineInputBorder(), // Remove underline
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue), // Change border color on focus
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromARGB(
                          255, 252, 250, 250)!), // Change border color
                ),
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 219, 213, 213)
                      .withOpacity(0.5), // Shadow color
                  spreadRadius: 3, // Spread radius
                  blurRadius: 5, // Blur radius
                  offset: Offset(0, 3), // Offset in x and y directions
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter last 4 digits of serial number*',
                errorText: validateserialnumber ? null : errorforserialnumber,
                errorStyle: TextStyle(color: Colors.red, fontSize: 10),
                border: OutlineInputBorder(), // Remove underline
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue), // Change border color on focus
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromARGB(
                          255, 252, 250, 250)!), // Change border color
                ),
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
          );
  }

  Widget vehiclebarcode() {
    return barcodelist.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 55,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color:
                          Color.fromARGB(255, 219, 213, 213).withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'Select barcode*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: barcodelist.map<DropdownMenuItem<String>>((e) {
                      return DropdownMenuItem(
                          child: Text(
                            e.barcode.toString(),
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          value: e.barcode.toString());
                    }).toList(),
                    value: vehiclebarcodeselectedvalue,
                    onChanged: (value) {
                      setState(() {
                        vehiclebarcodeselectedvalue = value;
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    dropdownStyleData: const DropdownStyleData(
                      maxHeight: 400,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                    dropdownSearchData: DropdownSearchData(
                      searchController: _vehicleserialnumbercontroller,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 4,
                          right: 8,
                          left: 8,
                        ),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: _vehicleserialnumbercontroller,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for barcode number',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value.toString().contains(searchValue);
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        _vehicleserialnumbercontroller.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatevehiclecategory
                  ? Container()
                  : Text(
                      errormessageforcategory,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
  }

  String? vehiclecategoryselectedValue, vehiclebarcodeselectedvalue;
  bool validatevehiclecategory = true,
      validateserialnumber = true,
      validatechasisnumber = true;
  String errormessageforcategory = "Please select category",
      errorforserialnumber = "Please enter serial number",
      errorforchasisnumber = "Please enter valid chasis number";
  final TextEditingController textEditingControllervehiclecategory =
      TextEditingController();

  validatefields() {
    validatevehiclecategory = true;
    validateserialnumber = true;

    validatechasisnumber = true;
    if (_vehiclechassisnumbercontroller.text.isEmpty &&
        _controller.text.isEmpty) {
      validatechasisnumber = false;
      validateserialnumber = false;

      setState(() {});
    } else if (_vehiclechassisnumbercontroller.text.isEmpty) {
      validatechasisnumber = false;
      errorforchasisnumber = "Please enter chasis number";
      setState(() {});
      return 'abc';
    } else if (_controller.text.isEmpty) {
      validateserialnumber = false;

      setState(() {});
    }
    //  else if (vehiclecategoryselectedValue == null) {
    //   validatevehiclecategory = false;

    //   setState(() {});
    // }
    else {
      Networkcallforaddvehicledetails();
    }
  }

//^^[A-HJ-NPR-Za-hj-npr-z\d]{8}[\dX][A-HJ-NPR-Za-hj-npr-z\d]{2}\d{6}$
  String isValidchasisnumber(String chasisnumber) {
    if (chasisnumber.isEmpty) {
      return "true";
    } else {
      if (hasMatch(chasisnumber, r'^[A-HJ-NPR-Z0-9]{17}$') == true) {
        return "true";
      } else {
        return "false";
      }
    }
  }

  static bool hasMatch(String? value, String pattern) {
    return (value == null) ? false : RegExp(pattern).hasMatch(value);
  }

  Future<void> Networkcallforaddvehicledetails() async {
    try {
      ProgressDialog.showProgressDialog(context, "title");
      String assignfaasttag = createjson().createjsonforaddvehicledetails(
          " vehiclecategoryselectedValue!",
          _vehiclenumbercontroller.text,
          _vehiclechassisnumbercontroller.text.isEmpty
              ? ''
              : _vehiclechassisnumbercontroller.text,
          _controller.text,
          widget.sessionId,
          context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().update_vehicle_details,
          URLS().update_vehicle_details_url,
          assignfaasttag,
          context);

      if (list != null) {
        Navigator.pop(context);
        List<Addvehicledetailsresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            SnackBarDesign(
                "Vehicle details added  successfully!!",
                context,
                colorfile().sucessmessagebcColor,
                colorfile().sucessmessagetxColor);
            _showSuccessDialog(context);
            break;
          case "false":
            SnackBarDesign(
                response[0].message!,
                context,
                colorfile().errormessagebcColor,
                colorfile().errormessagetxColor);

            break;
        }
      } else {
        Navigator.pop(context);
        SomethingWentWrongSnackBarDesign(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/succes.png', // Replace with your actual image path
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 20),
                Text(
                  'Congratulations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Vehicle details added  successfully!!.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Vehicle details:\n Customer Name : ${widget.customername} \n Vechicle Number : ${widget.vehiclenumber}\n Serial Number: ${_controller.text}  ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Vehicle details added  successfully!!. You will\n be redirected to the Home page in\n a few seconds.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) {
          return MyDashboard();
        },
      ), (route) => false);
    });
  }
}
