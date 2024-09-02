import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fast_tag/api/response/replacevehicleresponse.dart';
import 'package:fast_tag/pages/assign_otp.dart';
import 'package:fast_tag/pages/replace_otp.dart';
import 'package:fast_tag/pages/setvehicledetails.dart';
import 'package:fast_tag/utility/progressdialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/network/create_json.dart';
import '../api/network/network.dart';
import '../api/network/uri.dart';
import '../api/response/getallbarcoderesponse.dart';
import '../api/response/getstatecoderesponse.dart';
import '../utility/colorfile.dart';
import '../utility/snackbardesign.dart';

List<String> resonlist = [];
final _resoncontroller = TextEditingController();
String? selectedvalue, idselectedValue;
final _customernamecontroller = TextEditingController();
final _vehiclenumbercontroller = TextEditingController();
String? vehiclebarcodeselectedvalue;
final TextEditingController _barcodenumbercontroller = TextEditingController();
final _descriptionController = TextEditingController();
final _chasisnumbercontroller = TextEditingController();
final enginecontroller = TextEditingController();

bool ischasisselected = false;
List<String> statecodelist = [];
String? stateselectedValue;
final TextEditingController textEditingControllerstate =
    TextEditingController();

class ReplaceFastagPage extends StatefulWidget {
  State createState() => ReplaceFastagPageState();
}

class ReplaceFastagPageState extends State<ReplaceFastagPage> {
  TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  @override
  void initState() {
    super.initState();
    setvalue();

    // Set the default selected value to the first item in resonlist
    if (resonlist.isNotEmpty) {
      selectedvalue = resonlist[0];
      idselectedValue = getIdForReason(selectedvalue!); // Set corresponding ID
    }

    Networkcallforgetstatecode();
    Networkcallgetallbarcode();
  }

// Helper function to map the selected value to idselectedValue
  String getIdForReason(String reason) {
    switch (reason) {
      case "Tag Damaged":
        return "1";
      case "Lost Tag":
        return "2";
      case "Tag Not Working":
        return "3";
      case "Others":
        return "99";
      default:
        return "";
    }
  }

  setvalue() {
    resonlist.clear();
    resonlist.add('Tag Damaged');
    resonlist.add('Lost Tag');
    resonlist.add('Tag Not Working');
    resonlist.add('Others');
    setState(() {});
  }

  Future<void> Networkcallforgetstatecode() async {
    try {
      ProgressDialog.showProgressDialog(context, "title");
      statecodelist.clear();
      List<Object?>? list = await NetworkCall()
          .getMethod(URLS().get_state_code, URLS().get_state_code_url, context);
      if (list != null) {
        Navigator.pop(context);
        List<Getstatecoderesponse> response = List.from(list);
        String status = response[0].status!;
        switch (status) {
          case "true":
            if (response[0].data!.isNotEmpty) {
              for (var item in response[0].data!) {
                statecodelist.add(item.stateOfRegistration!);
              }
            }

            // Set default value if list is not empty
            if (statecodelist.isNotEmpty) {
              setState(() {
                stateselectedValue = statecodelist[0];
              });
            }
            break;

          case "false":
            SnackBarDesign(
              response[0].message!,
              context,
              colorfile().errormessagebcColor,
              colorfile().errormessagetxColor,
            );
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

  List<GetallbarcodeDatum> barcodelist = [];
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
            barcodelist = response[0].data!;
            for (int i = 0; i < barcodelist.length; i++) {
              _suggestions.add(barcodelist[i].barcode!);
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    resonlist.clear();
    idselectedValue = null;
    selectedvalue = null;
    _customernamecontroller.clear();
    _vehiclenumbercontroller.clear();
    _barcodenumbercontroller.clear();
    vehiclebarcodeselectedvalue = null;
    barcodelist.clear();
    _descriptionController.clear();
    _suggestions.clear();
    _controller.clear();
    enginecontroller.clear();
    statecodelist.clear();
    stateselectedValue = null;
    textEditingControllerstate.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa), // Set background color to #F5F5F5
      appBar: AppBar(
        // backgroundColor: Color(0xFFF5F5F5), // Set background color to #F5F5F5

        title: Text('Replace FasTag',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2024),
              fontSize: 18,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Text(
                'Enter Details',
                style: GoogleFonts.inter(
                  fontSize: 18, // 25px size
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
              SizedBox(height: 20), // Adding space before the first text field
              customername(),
              SizedBox(height: 20),
              //  statedropdown(),
              // SizedBox(height: 20),
              vehiclenumber(),

              SizedBox(height: 20),
              //barcode(),
              newbarcode(), SizedBox(height: 20),
              SizedBox(
                height: 3,
              ),
              reasonselectwidget(),
              idselectedValue == "99" ? SizedBox(height: 20) : Container(),
              idselectedValue == "99" ? resondesc() : Container(),
              SizedBox(height: 20), // Adding space before the first text field
              // Container(
              //   decoration: BoxDecoration(
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.grey.withOpacity(0.5),
              //         spreadRadius: 1,
              //         blurRadius: 10,
              //         offset: Offset(0, 5), // Offset in x and y directions
              //       ),
              //     ],
              //   ),
              //   child: TextField(
              //     controller: enginecontroller,
              //     inputFormatters: [
              //       FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
              //     ],
              //     onChanged: (value) {
              //       validateengine = true;
              //       setState(() {});
              //     },
              //     // keyboardType: TextInputType.number,
              //     textCapitalization: TextCapitalization.characters,
              //     decoration: InputDecoration(
              //       hintText: 'Enter Last 5 Digits of Engine Number*',
              //       labelText: 'Enter Last 5 Digits of Engine Number*',
              //       errorText: validateengine ? null : errorforenginenumber,
              //       errorStyle: TextStyle(color: Colors.red, fontSize: 10),
              //       border: OutlineInputBorder(),
              //       focusedBorder: OutlineInputBorder(
              //         borderSide: BorderSide(color: Colors.blue),
              //       ),
              //       enabledBorder: OutlineInputBorder(
              //         borderSide: BorderSide(
              //             color: const Color.fromARGB(255, 252, 250, 250)!),
              //       ),
              //       fillColor: Theme.of(context).scaffoldBackgroundColor,
              //       filled: true,
              //       contentPadding:
              //           EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              //     ),
              //   ),
              // ),

              ischasisselected
                  ? Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset:
                                Offset(0, 5), // Offset in x and y directions
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _chasisnumbercontroller,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Z0-9]')),
                        ],
                        keyboardType: TextInputType.visiblePassword,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 5,
                        decoration: InputDecoration(
                          hintText: 'Enter last 5 digits of chasis number',
                          errorText: validatechasisnumber
                              ? null
                              : errorforchasisnumber,
                          errorStyle:
                              TextStyle(color: Colors.red, fontSize: 10),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    const Color.fromARGB(255, 252, 250, 250)!),
                          ),
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 30), // Adding space before the button
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    validatefields();
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5.0), // Button corner radius 5px
                      ),
                    ),
                    padding:
                        MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF08469D),
                          Color(0xFF0056D0),
                          Color(0xFF0C92DD),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Container(
                      width:
                          double.infinity, // Make button width match its parent
                      alignment: Alignment.center,
                      child: Text(
                        'Submit',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget statedropdown() {
    return statecodelist.isNotEmpty
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
                      'Select State Code*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: statecodelist
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
                    value: stateselectedValue,
                    onChanged: (value) {
                      setState(() {
                        stateselectedValue = value;
                        validatestatecode = true;
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
                      searchController: textEditingControllerstate,
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
                          controller: textEditingControllerstate,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for state code',
                            labelText: 'Search for state code',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllerstate.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatestatecode
                  ? Container()
                  : Text(
                      errormessageforstate,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
  }

  Widget customername() {
    return Container(
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
        controller: _customernamecontroller,
        onChanged: (value) {
          validatecustomername = true;
          setState(() {});
        },
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
        decoration: InputDecoration(
          hintText: 'Enter Mobile Number*',
          labelText: 'Enter Mobile Number*',
          errorText: validatecustomername ? null : errorforcutomername,
          errorStyle: TextStyle(color: Colors.red, fontSize: 10),
          border: OutlineInputBorder(), // Remove underline
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.blue), // Change border color on focus
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: const Color.fromARGB(
                    255, 252, 250, 250)!), // Change border color
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
        controller: _vehiclenumbercontroller,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
        ],
        onChanged: (value) {
          validatevehicle = true;
          setState(() {});
        },
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          labelText: 'Enter Vehicle Number*',
          hintText: 'Enter Vehicle Number*',
          errorText: validatevehicle ? null : errorforvehiclenumber,
          errorStyle: TextStyle(color: Colors.red, fontSize: 10),
          border: OutlineInputBorder(), // Remove underline
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Colors.blue), // Change border color on focus
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: const Color.fromARGB(
                    255, 252, 250, 250)!), // Change border color
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
          validatebarcode = true;
          errorforbarcode = "";
        } else {
          _controller.clear();
        }
      });
    } else {
      // setState(() {
      //   _controller.clear();
      // });
      validatebarcode = false;
      errorforbarcode = "Please enter last 4 digits of barcode";
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
                hintText: 'Enter last 4 digits of barcode*',
                labelText: 'Enter last 4 digits of barcode*',
                errorText: validatebarcode ? null : errorforbarcode,
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
                hintText: 'Enter last 4 digits of barcode*',
                errorText: validatebarcode ? null : errorforbarcode,
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

  Widget barcode() {
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
                      'Select barcode number*',
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
                        validatebarcode = true;
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
                      searchController: _barcodenumbercontroller,
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
                          controller: _barcodenumbercontroller,
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
                        _barcodenumbercontroller.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatebarcode
                  ? Container()
                  : Text(
                      errorforbarcode,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
  }

  Widget reasonselectwidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 55,
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                'Select Reason*',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).hintColor,
                ),
              ),
              items: resonlist
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
              value: selectedvalue,
              onChanged: (value) {
                setState(() {
                  selectedvalue = value;
                  idselectedValue = getIdForReason(selectedvalue!);
                  validatereson = true;
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
                padding: EdgeInsets.all(7),
              ),
              dropdownSearchData: DropdownSearchData(
                searchController: _resoncontroller,
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
                    controller: _resoncontroller,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      hintText: 'Search for reason',
                      labelText: 'Search for reason',
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
                  _resoncontroller.clear();
                }
              },
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        validatereson
            ? Container()
            : Text(
                errorforreson,
                style: TextStyle(color: Colors.red, fontSize: 10),
              )
      ],
    );
  }

// Helper function to get idselectedValue based on selected reason
// String getIdForReason(String reason) {
//   switch (reason) {
//     case "Tag Damaged":
//       return "1";
//     case "Lost Tag":
//       return "2";
//     case "Tag Not Working":
//       return "3";
//     case "Others":
//       return "99";
//     default:
//       return "";
//   }
// }

  Widget resondesc() {
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
      child: TextFormField(
        controller: _descriptionController,
        onChanged: (value) {},
        decoration: InputDecoration(
          hintText: 'Description',
          errorText:
              validatereasondesc ? null : 'Please enter a reason description',
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
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
        minLines: 5,
        maxLines: 7,
      ),
    );
  }

  bool validatecustomername = true,
      validatevehicle = true,
      validatebarcode = true,
      validatereson = true,
      validatereasondesc = true,
      validatechasisnumber = true,
      validatestatecode = true,
      validateengine = true;
  String errorforcutomername = "Please enter mobile number",
      errormessageforstate = "Please select state code",
      errorforvehiclenumber = "Please enter vehicle number",
      errorforbarcode = "Please enter barcode number ",
      errorforreson = "Please select reason for fastag replace",
      errorforchasisnumber = "Please enter chasis number",
      errorforenginenumber = "Please enter last 5 digits of chasis number";
  validatefields() {
    validatecustomername = true;
    validatevehicle = true;
    validatebarcode = true;
    validatereson = true;
    validatereasondesc = true;
    validatestatecode = true;
    if (_customernamecontroller.text.isEmpty &&
            stateselectedValue == null &&
            _vehiclenumbercontroller.text.isEmpty &&
            _controller.text.isEmpty &&
            idselectedValue == null &&
            enginecontroller.text.isEmpty ||
        (ischasisselected && _chasisnumbercontroller.text.isEmpty)) {
      validatecustomername = false;
      validatestatecode = false;
      validatevehicle = false;
      validatebarcode = false;
      validatereson = false;
      validatechasisnumber = false;
      validateengine = false;
      setState(() {});
    } else if (stateselectedValue == null &&
            _vehiclenumbercontroller.text.isEmpty &&
            _controller.text.isEmpty &&
            idselectedValue == null &&
            enginecontroller.text.isEmpty ||
        (ischasisselected && _chasisnumbercontroller.text.isEmpty)) {
      validatestatecode = false;
      validatevehicle = false;
      validatebarcode = false;
      validatereson = false;
      validatechasisnumber = false;
      validateengine = false;
      setState(() {});
    } else if (_vehiclenumbercontroller.text.isEmpty &&
            _controller.text.isEmpty &&
            idselectedValue == null &&
            enginecontroller.text.isEmpty ||
        (ischasisselected && _chasisnumbercontroller.text.isEmpty)) {
      validatevehicle = false;
      validatebarcode = false;
      validatereson = false;
      validatechasisnumber = false;
      validateengine = false;
      setState(() {});
      // } else if (isValidVehicleNumberPlate(_vehiclenumbercontroller.text) ==
      //             "false" &&
      //         _controller.text.isEmpty &&
      //         idselectedValue == null &&
      //         enginecontroller.text.isEmpty ||
      //     (ischasisselected && _chasisnumbercontroller.text.isEmpty)) {
      //   validatevehicle = false;
      //   validatebarcode = false;
      //   validatereson = false;
      //   validatechasisnumber = false;
      //   validateengine = false;
      //   errorforvehiclenumber = "Please enter valid vehicle number";
      //   setState(() {});
      //   return 'abc';
    } else if (_controller.text.isEmpty &&
        idselectedValue == null &&
        // enginecontroller.text.isEmpty ||

        (ischasisselected && _chasisnumbercontroller.text.isEmpty)) {
      validatebarcode = false;
      validatereson = false;
      setState(() {});
    } else if (idselectedValue == "99" &&
        _descriptionController.text.isEmpty &&
        // enginecontroller.text.isEmpty ||

        (ischasisselected && _chasisnumbercontroller.text.isEmpty)) {
      validatereasondesc = false;
      setState(() {});
    } else if (idselectedValue == null) {
      validatereson = false;
      setState(() {});
    } else if (
        // enginecontroller.text.isEmpty ||

        (ischasisselected && _chasisnumbercontroller.text.isEmpty)) {
      validatechasisnumber = false;
      errorforchasisnumber = "Please enter chasis number";
      setState(() {});
    } else if (_customernamecontroller.text.isEmpty) {
      validatecustomername = false;
      setState(() {});
    }
    //  else if (stateselectedValue == null) {
    //   validatestatecode = false;
    //   setState(() {});
    // }
    else if (_vehiclenumbercontroller.text.isEmpty) {
      validatevehicle = false;
      setState(() {});
    } else if (_controller.text.isEmpty) {
      validatebarcode = false;
      setState(() {});
    } else if (idselectedValue == null) {
      validatereson = false;
      setState(() {});
    } else if (idselectedValue == "99" && _descriptionController.text.isEmpty) {
      validatereasondesc = false;
      setState(() {});
      // }
      //  else if (enginecontroller.text.isEmpty) {
      //   validateengine = false;
      //   errorforenginenumber = "Please enter last 5 digits of engine number";
      //   setState(() {});
    } else {
      Networkcallforreplacetaggenerateotp();
    }
  }

  String isValidVehicleNumberPlate(String NUMBERPLATE) {
    if (hasMatch(NUMBERPLATE, r'^[A-Z]{2}[0-9]{2}[A-HJ-NP-Z]{1,2}[0-9]{4}$') ==
        true) {
      return "true";
    } else if (hasMatch(NUMBERPLATE, r'[0-9]{2}BH[0-9]{4}[A-HJ-NP-Z]{1,2}$') ==
        true) {
      return "true";
    } else {
      return "false";
    }
  }

  static bool hasMatch(String? value, String pattern) {
    return (value == null) ? false : RegExp(pattern).hasMatch(value);
  }

  bool _isValidFormat(String input) {
    final RegExp regex = RegExp(r'^\d{6}-\d{3}-\d{7}$');
    return regex.hasMatch(input);
  }

  Future<void> Networkcallforreplacetaggenerateotp() async {
    try {
      ProgressDialog.showProgressDialog(context, " title");
      String assignfaasttag = createjson()
          .createjsonforgenerateotpforreplacevehicle(
              _customernamecontroller.text,
              _vehiclenumbercontroller.text,
              _controller.text,
              idselectedValue!,
              _descriptionController.text.isEmpty
                  ? ""
                  : _descriptionController.text,
              ischasisselected ? "1" : "0",
              _chasisnumbercontroller.text,
              // enginecontroller!.text!,
              // stateselectedValue!,
              context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().rep_generate_otp_by_vehicle,
          URLS().rep_generate_otp_by_vehicle_url,
          assignfaasttag,
          context);

      if (list != null) {
        Navigator.pop(context);
        List<Replacevehicleresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            List<ReplacevehicleDatum> data = response[0].data!;
            SnackBarDesign(
                "OTP send successfully!!",
                context,
                colorfile().sucessmessagebcColor,
                colorfile().sucessmessagetxColor);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReplaceOtpPage(
                      data[0].sessionId!,
                      data[0].requestId!,
                      _vehiclenumbercontroller.text,
                      _customernamecontroller.text,
                      _barcodenumbercontroller.text,
                      idselectedValue!,
                      _descriptionController.text.isEmpty
                          ? ""
                          : _descriptionController.text,
                      ischasisselected ? "1" : "0",
                      _chasisnumbercontroller.text,
                      enginecontroller!.text!,
                      stateselectedValue!)),
            );
            break;
          case "false":
            SnackBarDesign(
                "Unable to send OTP , Please try again",
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
}
