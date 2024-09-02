import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fast_tag/api/network/create_json.dart';
import 'package:fast_tag/api/network/network.dart';
import 'package:fast_tag/api/network/uri.dart';
import 'package:fast_tag/api/response/assignfasttagresponse.dart';
import 'package:fast_tag/api/response/customervehicledetailsresponse.dart';
import 'package:fast_tag/api/response/getstatecoderesponse.dart';
import 'package:fast_tag/api/response/getvehicleclassresponse.dart';
import 'package:fast_tag/api/response/getvehicledesriptor.dart';
import 'package:fast_tag/api/response/setvehicledetailsmanuallyresponse.dart';
import 'package:fast_tag/api/response/vehiclemodelresponse.dart';
import 'package:fast_tag/pages/assign_otp.dart';
import 'package:fast_tag/utility/colorfile.dart';
import 'package:fast_tag/utility/progressdialog.dart';
import 'package:fast_tag/utility/snackbardesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/response/getmapperclassresponse.dart';
import '../api/response/vehiclemakerresponse.dart';
import 'assign_customer_details.dart';

List<String> vehiclemaker = [];

String? vehiclemakerselectedValue;
final TextEditingController textEditingControllervehiclemaker =
    TextEditingController();

List<String> statecodelist = [];
String? stateselectedValue;
final TextEditingController textEditingControllerstate =
    TextEditingController();

List<String> vehicledescriptor = [];
String? vehicledescriptorselectedValue;
final TextEditingController textEditingControllervehicledescriptor =
    TextEditingController();

List<String> nationalpermitlist = [];
String? nationalpermitselectedValue;
String? usenationalpermitselectedValue;
final TextEditingController textEditingControllernationalpermit =
    TextEditingController();

List<String> vehiclemodellist = [];
String? vehiclemodelselectedValue;
final TextEditingController textEditingControllervehiclemodel =
    TextEditingController();
final List<String> type = [];
String? typeselectedValue;
final TextEditingController textEditingControllertype = TextEditingController();
final List<String> vehicletype = [];
String? vehicletypeselectedValue;
final TextEditingController textEditingControllervehicletype =
    TextEditingController();

List<String> npciVehicleClassID = [];
List<String> npciVehicleClassIDName = [];
String? npciVehicleClassIDselectedValue, npciVehicleClassIDselectedValueName;
final TextEditingController textEditingControllernpciVehicleClassID =
    TextEditingController();

// List<String> tagVehicleClassID = [];
String? tagVehicleClassIDselectedValue, tagVehicleClassIDselectedValueName;
final TextEditingController textEditingControllertagVehicleClassID =
    TextEditingController();
bool _isChecked = false;
String permitexirydate = "";
bool showdatepicker = false;
final _dobcontroller = TextEditingController();

class SetVehicleDetails extends StatefulWidget {
  String sessionId,
      vehicle_number,
      Statecode,
      vehicledescriptor,
      isnationalpermit,
      expirydate;
  SetVehicleDetails(this.sessionId, this.vehicle_number, this.Statecode,
      this.vehicledescriptor, this.isnationalpermit, this.expirydate);
  State createState() => SetvehicledetailsState();
}

final vehiclecolorcontroller = TextEditingController();

class SetvehicledetailsState extends State<SetVehicleDetails> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // setState(() {});

    setvalue();
    if (_isChecked == true) {
      textEditingControllertype.text = "LPV";
      setState(() {});
    } else {
      textEditingControllertype.text = "LMV";
      setState(() {});
    }
    Networkcallforgetstatecode();
    Networkcallforgetvehicledescriptor();
    Networkcallforvehiclemakerlist();
    Networkcallforgetvehicleclass();
  }

  Future<void> Networkcallforgetcustomervehicledetails() async {
    try {
      ProgressDialog.showProgressDialog(context, " title");
      String createjsonforcustomer =
          createjson().createjsonforgetvehicledetails(widget.vehicle_number);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().get_complete_customer_details_by_vehicle,
          URLS().get_complete_customer_details_by_vehicle_url,
          createjsonforcustomer,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Customervehicledetailsrespone> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            List<CustomervehicledetailsDatum> data = response[0].data!;
            if (data.isNotEmpty) {
              setfinalvalue(
                  data[0].isNationalPermit.toString(),
                  data[0].vehicleDescriptor.toString(),
                  data[0].stateOfRegistration.toString(),
                  data[0].vehicleManuf.toString(),
                  data[0].vehicleType.toString(),
                  data[0].model.toString(),
                  data[0].tagVehicleClassId.toString(),
                  data[0].isCommercial == "true" ? true : false,
                  data[0].vehicleColour.toString(),
                  data[0].type.toString(),
                  data[0].npciVehicleClassId.toString());
            }
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

  setvalue() {
    type.clear();
    vehicletype.clear();
    npciVehicleClassID.clear();
    npciVehicleClassIDName.clear();
    tagVehicleClassID.clear();
    nationalpermitlist.clear();
    type.add("LMV");
    type.add("LPV");
    type.add("LGV(only for tata ace pickup/mini light commercial vehicle)");
    vehicletype.add("Motor Car");
    vehicletype.add("Motor Cab");
    vehicletype.add("Maxi Cab");
    vehicletype.add(
        "Goods Carrier(only for Tata Ace Pickup/Mini Light commercial vehicle for VC 20)");
    nationalpermitlist.add("Yes");
    nationalpermitlist.add("No");

    setState(() {});
  }

  setfinalvalue(
      String isnationalpermit,
      String vehicledescriptor,
      String Statecode,
      String vehiclemanuf,
      String motortype,
      String vehiclemodel,
      String tagVehicleClassId,
      bool iscomeercial,
      String vehicleColour,
      String type,
      String npcivehicleid) {
    if (vehiclemanuf != null && vehiclemanuf != "") {
      if (vehiclemaker.contains(vehiclemanuf)) {
        vehiclemakerselectedValue = vehiclemanuf;
        Networkcallforvehiclemodel(vehiclemakerselectedValue!);
      }
    }

    if (vehiclemodel != null && vehiclemodel != "") {
      if (vehiclemodellist.contains(vehiclemodel)) {
        vehiclemodelselectedValue = vehiclemodel;
        setState(() {});
      }
    }
    if (motortype != null && motortype != "") {
      if (vehicletype.contains(motortype)) {
        vehicletypeselectedValue = motortype;
      }
    }
    if (tagVehicleClassID.isNotEmpty) {
      if (tagVehicleClassId != null && tagVehicleClassId != "") {
        int i = tagVehicleClassID.indexWhere(
          (element) {
            return element == tagVehicleClassId;
          },
        );
        tagVehicleClassIDselectedValueName =
            tagVehicleClassIDName[i].toString();
        tagVehicleClassIDselectedValue = tagVehicleClassId;
        Networkcallforgetmapperclass(tagVehicleClassIDselectedValue!);
      }
    }
    if (npciVehicleClassID.isNotEmpty) {
      if (npcivehicleid != null && npcivehicleid != "") {
        int i = npciVehicleClassID.indexWhere(
          (element) {
            return element == npcivehicleid;
          },
        );
        npciVehicleClassIDselectedValueName =
            npciVehicleClassIDName[i].toString();
        npciVehicleClassIDselectedValue = npcivehicleid;
      }
    }
    if (iscomeercial) {
      _isChecked = true;
    } else {
      _isChecked = false;
    }

    if (isnationalpermit != null && isnationalpermit != "") {
      if (isnationalpermit == "1") {
        if (nationalpermitlist.contains("Yes")) {
          nationalpermitselectedValue = isnationalpermit;
          usenationalpermitselectedValue = "Yes";
        }
      } else {
        if (nationalpermitlist.contains("No")) {
          nationalpermitselectedValue = isnationalpermit;
          usenationalpermitselectedValue = "No";
        }
      }
    }

    if (vehicledescriptor != null && vehicledescriptor != "") {
      if (vehicledescriptor.contains(vehicledescriptor.toLowerCase())) {
        vehicledescriptorselectedValue = vehicledescriptor.capitalizeFirst;
      }
    }
    if (Statecode != null && Statecode != "") {
      if (statecodelist.contains(Statecode)) {
        stateselectedValue = Statecode;
      }
    }
    if (vehicleColour != null && vehicleColour != "") {
      vehiclecolorcontroller.text = vehicleColour;
    }
    if (type != null && type != "") {
      textEditingControllertype.text = type;
    }
    setState(() {});
  }

  Future<void> Networkcallforvehiclemakerlist() async {
    try {
      ProgressDialog.showProgressDialog(context, " title");
      vehiclemaker.clear();
      vehiclemodellist.clear();
      vehiclemakerselectedValue = null;
      vehiclemodelselectedValue = null;
      setState(() {});
      String vehiclemakerlist = createjson().createjsonforvehiclemakerlist(
          widget.sessionId, widget.vehicle_number, context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().vehicleMakerList,
          URLS().vehicleMakerList_url,
          vehiclemakerlist,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Vehiclemakerresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            vehiclemaker = response[0].data![0].vehicleMakerList!;

            setState(() {});
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
    Networkcallforgetcustomervehicledetails();
  }

  Future<void> Networkcallforvehiclemodel(String vehiclemaker) async {
    try {
      vehiclemodellist.clear();
      setState(() {});
      ProgressDialog.showProgressDialog(context, " title");
      String vehiclemodel = createjson().createjsonforvehiclemodel(
          widget.sessionId, vehiclemaker, widget.vehicle_number, context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().vehicleModelList,
          URLS().vehicleModelList_url,
          vehiclemodel,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Vehiclemodelresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            vehiclemodellist = response[0].data![0].vehicleModelList!;
            setState(() {});
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

  Future<void> Networkcallforgetstatecode() async {
    try {
      ProgressDialog.showProgressDialog(context, " title");
      statecodelist.clear();
      List<Object?>? list = await NetworkCall()
          .getMethod(URLS().get_state_code, URLS().get_state_code_url, context);
      if (list != null) {
        Navigator.pop(context);
        List<Getstatecoderesponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            if (response[0].data!.isNotEmpty) {
              for (var item in response[0].data!) {
                statecodelist.add(item.stateOfRegistration!);
              }
            }

            setState(() {});
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

  Future<void> Networkcallforgetvehicledescriptor() async {
    try {
      print(widget.vehicledescriptor);
      ProgressDialog.showProgressDialog(context, " title");
      vehicledescriptor.clear();
      List<Object?>? list = await NetworkCall().getMethod(
          URLS().get_vehicleDescriptor,
          URLS().get_vehicleDescriptor_url,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Getvehicledescriptorreresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            List<String> abc = [];
            if (response[0].data!.isNotEmpty) {
              for (var item in response[0].data!) {
                abc.add(item.vehicleDescriptor!.toLowerCase());
                vehicledescriptor.add(item.vehicleDescriptor!);
              }
            }

            setState(() {});
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

  List<String> tagVehicleClassID = [];
  List<String> tagVehicleClassIDName = [];
  Future<void> Networkcallforgetvehicleclass() async {
    try {
      List<Object?>? list = await NetworkCall().getMethod(
          URLS().get_vehicle_class_api,
          URLS().get_vehicle_class_api_url,
          context);
      if (list != null) {
        List<Getvehicleclassresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            for (int i = 0; i < response[0].data!.length; i++) {
              tagVehicleClassID.add(response[0].data![i].id!);
              tagVehicleClassIDName.add(response[0].data![i].id! +
                  "-" +
                  response[0].data![i].categoryName!);
            }

            setState(() {});
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
        SomethingWentWrongSnackBarDesign(context);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> Networkcallforgetmapperclass(String vehicleId) async {
    try {
      npciVehicleClassID.clear();
      npciVehicleClassIDName.clear();
      String vehiclclassid =
          createjson().createjsonforgetmapperclass(vehicleId, context);
      List<Object?>? list = await NetworkCall().postMethod(
        URLS().get_mapper_class_api,
        URLS().get_mapper_class_api_url,
        vehiclclassid,
        context,
      );
      if (list != null) {
        List<Getmapperclassresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            for (int i = 0; i < response[0].data!.length; i++) {
              npciVehicleClassID.add(response[0].data![i].id!);
              npciVehicleClassIDName.add(response[0].data![i].id! +
                  '-' +
                  response[0].data![i].subCategoryName!);
            }

            setState(() {});
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
    clearfields();
  }

  clearfields() {
    vehiclemaker.clear();
    vehiclemakerselectedValue = null;
    textEditingControllervehiclemaker.clear();
    vehiclemodellist.clear();
    vehiclemodelselectedValue = null;
    textEditingControllervehiclemodel.clear();

    type.clear();
    typeselectedValue = null;
    textEditingControllertype.clear();
    vehicletype.clear();
    vehicletypeselectedValue = null;
    textEditingControllervehicletype.clear();

    npciVehicleClassID.clear();
    npciVehicleClassIDName.clear();
    npciVehicleClassIDselectedValue = null;
    npciVehicleClassIDselectedValueName = null;

    textEditingControllernpciVehicleClassID.clear();

    tagVehicleClassID.clear();
    tagVehicleClassIDName.clear();
    tagVehicleClassIDselectedValue = null;
    tagVehicleClassIDselectedValueName = null;
    textEditingControllertagVehicleClassID.clear();
    vehiclecolorcontroller.clear();
    statecodelist.clear();
    stateselectedValue = null;
    textEditingControllerstate.clear();
    vehicledescriptor.clear();
    vehicledescriptorselectedValue = null;
    textEditingControllervehicledescriptor.clear();
    nationalpermitlist.clear();
    nationalpermitselectedValue = null;
    usenationalpermitselectedValue = null;
    textEditingControllernationalpermit.clear();
    permitexirydate = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set vehicle details',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 1, child: vehiclemakerdropdown()),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(flex: 1, child: vehiclemodeldropdown()),
                ],
              ),
              space(),
              vehicletypedropdown(),
              space(),
              tagVehicleClassIDtypedropdown(),
              space(),
              npciVehicleClassIDdropdown(),
              space(),
              npciVehicleClassIDselectedValue != "" &&
                      npciVehicleClassIDselectedValue == "20"
                  ? Container()
                  : Row(
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (value) {
                            typeselectedValue = null;
                            textEditingControllertype.clear();
                            _isChecked = value!;
                            if (_isChecked == true) {
                              textEditingControllertype.text = "LPV";
                              setState(() {});
                            } else {
                              textEditingControllertype.text = "LMV";
                              setState(() {});
                            }
                          },
                        ),
                        Flexible(
                          child: Text(
                            'commercial Vehicle',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
              space(),
              Container(
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
                child: TextFormField(
                  controller: textEditingControllertype,
                  enabled: true,
                  readOnly: true,
                  decoration: InputDecoration(
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
              ),
              space(),
              Container(
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
                  controller: vehiclecolorcontroller,
                  decoration: InputDecoration(
                    hintText: 'Enter Vehicle Color*',
                    errorText: validatecolor ? null : errormessageforcolor,
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
              ),
              space(),
              statedropdown(),
              space(),
              vehicledescriptordropdown(),
              space(),
              nationalpermitdropdown(),
              space(),
              showdatepicker ? dobwidget() : Container(),
              showdatepicker ? space() : Container(),
              Container(
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
                    validatefields();
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
                    width:
                        double.infinity, // Make button width match its parent
                    child: Center(
                      child: Text(
                        'Proceed',
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

  Widget space() {
    return SizedBox(
      height: 20,
    );
  }

  Widget vehiclemakerdropdown() {
    return vehiclemaker.isNotEmpty
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
                      'Select Vehicle Maker*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: vehiclemaker
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
                    value: vehiclemakerselectedValue,
                    onChanged: (value) {
                      vehiclemodellist.clear();
                      vehiclemodelselectedValue = null;
                      setState(() {
                        vehiclemakerselectedValue = value;
                        validatevehiclemaker = true;
                      });

                      Networkcallforvehiclemodel(vehiclemakerselectedValue!);
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
                      searchController: textEditingControllervehiclemaker,
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
                          controller: textEditingControllervehiclemaker,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for vehicle maker',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        print(searchValue.toLowerCase());
                        return item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllervehiclemaker.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatevehiclemaker
                  ? Container()
                  : Text(
                      errormessageformaker,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
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
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        print(searchValue.toLowerCase());
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

  Widget vehicledescriptordropdown() {
    return vehicledescriptor.isNotEmpty
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
                      'Select Vehicle Descriptor*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: vehicledescriptor
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
                    value: vehicledescriptorselectedValue,
                    onChanged: (value) {
                      setState(() {
                        validatevehicleDescriptor = true;
                        vehicledescriptorselectedValue = value;
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
                      searchController: textEditingControllervehicledescriptor,
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
                          controller: textEditingControllervehicledescriptor,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for vehicle descriptor',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        print(searchValue.toLowerCase());
                        return item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllervehicledescriptor.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatevehicleDescriptor
                  ? Container()
                  : Text(
                      errormessageforvehicleDescriptor,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
  }

  Widget nationalpermitdropdown() {
    return vehicledescriptor.isNotEmpty
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
                      'Select National Permit*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: nationalpermitlist
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
                    value: usenationalpermitselectedValue,
                    onChanged: (value) {
                      setState(() {
                        validatenationalpermit = true;
                        usenationalpermitselectedValue = value;
                        if (usenationalpermitselectedValue == "Yes") {
                          showdatepicker = true;
                          nationalpermitselectedValue = "1";
                        } else {
                          nationalpermitselectedValue = "2";
                          showdatepicker = false;
                        }
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
                      searchController: textEditingControllernationalpermit,
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
                          controller: textEditingControllernationalpermit,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for national permit',
                            hintStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        print(searchValue.toLowerCase());
                        return item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllernationalpermit.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatenationalpermit
                  ? Container()
                  : Text(
                      errormessagefornationalpermit,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
  }

  Widget dobwidget() {
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
        controller: _dobcontroller,
        onChanged: (value) {
          if (value.isNotEmpty) {
            validateexpirydate = true;
          } else {
            validateexpirydate = false;
          }
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Date Of Permit Expiry*',
          errorText: validateexpirydate ? null : errorforexpiry,
          errorStyle: TextStyle(color: Colors.red, fontSize: 10),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 252, 250, 250)),
          ),
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          suffixIcon: GestureDetector(
            onTap: () async {
              validateexpirydate = true;
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now().add(Duration(days: 365 * 4)),
              );

              if (pickedDate != null) {
                String day = pickedDate.day.toString();
                String month = pickedDate.month.toString();
                String year = pickedDate.year.toString();
                String date = '$day/$month/$year';
                _dobcontroller.text = date;
                setState(() {});
                permitexirydate = _dobcontroller.text;
                validateexpirydate = true;
                setState(() {});
              }
            },
            child: Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  Widget vehiclemodeldropdown() {
    return vehiclemodellist.isNotEmpty
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
                      'Select Vehicle Model*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),

                    items: vehiclemodellist
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
                    value: vehiclemodelselectedValue,
                    onChanged: (value) {
                      setState(() {
                        vehiclemodelselectedValue = value;
                        validatemodel = true;
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
                      searchController: textEditingControllervehiclemodel,
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
                          controller: textEditingControllervehiclemodel,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for vehicle model',
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
                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllervehiclemodel.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatemodel
                  ? Container()
                  : Text(
                      errormessageformodel,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Column(
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
                      'Select Vehicle Model*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),

                    items: [],
                    value: vehiclemodelselectedValue,
                    onChanged: (value) {
                      setState(() {
                        vehiclemodelselectedValue = value;
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
                      searchController: textEditingControllervehiclemodel,
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
                          controller: textEditingControllervehiclemodel,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for vehicle model',
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
                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllervehiclemodel.clear();
                      }
                    },
                  ),
                ),
              ),
            ],
          );
  }

  Widget typedropdown() {
    return type.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 55,
                // margin: EdgeInsets.only(bottom: 20),
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
                      'Select Type*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),

                    items: type
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
                    value: typeselectedValue,
                    onChanged: (value) {
                      setState(() {
                        typeselectedValue = value;
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
                      searchController: textEditingControllertype,
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
                          controller: textEditingControllertype,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for type',
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
                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllertype.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatetype
                  ? Container()
                  : Text(
                      errormessagefortype,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
  }

  Widget vehicletypedropdown() {
    return vehicletype.isNotEmpty
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
                      'Select Vehicle Type*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),

                    items: vehicletype
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
                    value: vehicletypeselectedValue,
                    onChanged: (value) {
                      setState(() {
                        vehicletypeselectedValue = value;
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
                      searchController: textEditingControllervehicletype,
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
                          controller: textEditingControllervehicletype,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for vehicle type',
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
                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllervehicletype.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatevehicletype
                  ? Container()
                  : Text(
                      errormessageforvehicletype,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
  }

  Widget npciVehicleClassIDdropdown() {
    return npciVehicleClassID.isNotEmpty
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
                      'Select Mapper*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),

                    items: npciVehicleClassIDName
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
                    value: npciVehicleClassIDselectedValueName,
                    onChanged: (value) {
                      setState(() {
                        validatenpciid = true;
                        npciVehicleClassIDselectedValueName = value;
                        List<String> abc = value!.split("-");
                        print(value);
                        npciVehicleClassIDselectedValue = abc[0];
                        print(npciVehicleClassIDselectedValue);
                        if (npciVehicleClassIDselectedValue == "20") {
                          textEditingControllertype.text = "LGV";
                        } else {
                          if (_isChecked == true) {
                            textEditingControllertype.text = "LPV";
                          } else {
                            textEditingControllertype.text = "LMV";
                          }
                        }
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
                      searchController: textEditingControllernpciVehicleClassID,
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
                          controller: textEditingControllernpciVehicleClassID,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for mapper class id',
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
                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllernpciVehicleClassID.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatenpciid
                  ? Container()
                  : Text(
                      errormessagefornpciid,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
  }

  Widget tagVehicleClassIDtypedropdown() {
    return tagVehicleClassID.isNotEmpty
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
                      'Select Tag Vehicle*',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),

                    items: tagVehicleClassIDName
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
                    value: tagVehicleClassIDselectedValueName,
                    onChanged: (value) {
                      setState(() {
                        tagVehicleClassIDselectedValueName = value;
                        List<String> abc = value!.split("-");
                        print(value);
                        tagVehicleClassIDselectedValue = abc[0];
                        print(tagVehicleClassIDselectedValue);
                        Networkcallforgetmapperclass(
                            tagVehicleClassIDselectedValue!);
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
                      searchController: textEditingControllertagVehicleClassID,
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
                          controller: textEditingControllertagVehicleClassID,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Search for tag vehicle class id',
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
                    //This to clear the search value when you close the menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        textEditingControllertagVehicleClassID.clear();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              validatetagid
                  ? Container()
                  : Text(
                      errormessagefortagid,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    )
            ],
          )
        : Container();
  }

  bool validatevehiclemaker = true,
      validatemodel = true,
      validatetype = true,
      validatevehicletype = true,
      validatenpciid = true,
      validatetagid = true,
      validatecolor = true,
      validatestatecode = true,
      validatevehicleDescriptor = true,
      validatenationalpermit = true,
      validateexpirydate = true;
  String errormessageformaker = "Please select vehicle maker",
      errormessageforstate = "Please select state code",
      errormessageformodel = "Please select vehicle model",
      errormessagefortype = "Please select type",
      errormessageforvehicletype = "Please select vehicle type",
      errormessagefornpciid = "Please select mapper class id",
      errormessagefortagid = "Please select tag vehicle class id",
      errormessageforcolor = "Please enter color of vehicle",
      errormessageforvehicleDescriptor = "Please select vehicle descriptor",
      errormessagefornationalpermit = "Please select national permit",
      errorforexpiry = "Please select date of permit expiry";
  validatefields() {
    validatevehiclemaker = true;
    validatemodel = true;
    validatetype = true;
    validatevehicletype = true;
    validatenpciid = true;
    validatetagid = true;
    validatecolor = true;
    validatestatecode = true;
    validatevehicleDescriptor = true;
    validatenationalpermit = true;
    validateexpirydate = true;
    if (vehiclemakerselectedValue == null &&
        vehicletypeselectedValue == null &&
        npciVehicleClassIDselectedValueName == null &&
        tagVehicleClassIDselectedValueName == null &&
        vehiclemodelselectedValue == null &&
        vehiclecolorcontroller.text.isEmpty &&
        stateselectedValue == null &&
        vehicledescriptorselectedValue == null &&
        nationalpermitselectedValue == null &&
        (nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validatevehiclemaker = false;
      validatemodel = false;

      validatevehicletype = false;
      validatenpciid = false;
      validatetagid = false;
      validatecolor = false;
      validatestatecode = false;
      validatevehicleDescriptor = false;
      validatenationalpermit = false;
      validateexpirydate = false;
      setState(() {});
    } else if (vehicletypeselectedValue == null &&
        npciVehicleClassIDselectedValueName == null &&
        tagVehicleClassIDselectedValueName == null &&
        vehiclemakerselectedValue == null &&
        vehiclecolorcontroller.text.isEmpty &&
        stateselectedValue == null &&
        vehicledescriptorselectedValue == null &&
        nationalpermitselectedValue == null &&
        (nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validatemodel = false;
      validatevehicletype = false;
      validatenpciid = false;
      validatetagid = false;
      validatecolor = false;
      validatestatecode = false;
      validatevehicleDescriptor = false;
      validatenationalpermit = false;
      validateexpirydate = false;
      setState(() {});
    } else if (vehicletypeselectedValue == null &&
        npciVehicleClassIDselectedValueName == null &&
        tagVehicleClassIDselectedValueName == null &&
        vehiclemodelselectedValue == null &&
        vehiclecolorcontroller.text.isEmpty &&
        stateselectedValue == null &&
        vehicledescriptorselectedValue == null &&
        nationalpermitselectedValue == null &&
        (nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validatevehicletype = false;
      validatemodel = false;
      validatenpciid = false;
      validatetagid = false;
      validatecolor = false;
      validatestatecode = false;
      validatevehicleDescriptor = false;
      validatenationalpermit = false;
      validateexpirydate = false;
      setState(() {});
    } else if (npciVehicleClassIDselectedValueName == null &&
        tagVehicleClassIDselectedValueName == null &&
        vehiclemodelselectedValue == null &&
        vehiclecolorcontroller.text.isEmpty &&
        stateselectedValue == null &&
        vehicledescriptorselectedValue == null &&
        nationalpermitselectedValue == null &&
        (nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validatenpciid = false;
      validatemodel = false;
      validatetagid = false;
      validatecolor = false;
      validatestatecode = false;
      validatevehicleDescriptor = false;
      validatenationalpermit = false;
      validateexpirydate = false;
      setState(() {});
    } else if (tagVehicleClassIDselectedValueName == null &&
        vehiclemodelselectedValue == null &&
        vehiclecolorcontroller.text.isEmpty &&
        stateselectedValue == null &&
        vehicledescriptorselectedValue == null &&
        nationalpermitselectedValue == null &&
        (nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validatetagid = false;
      validatemodel = false;

      validatecolor = false;
      validatestatecode = false;
      validatevehicleDescriptor = false;
      validatenationalpermit = false;
      validateexpirydate = false;
      setState(() {});
    } else if (vehiclemodelselectedValue == null &&
        vehiclecolorcontroller.text.isEmpty &&
        stateselectedValue == null &&
        vehicledescriptorselectedValue == null &&
        nationalpermitselectedValue == null &&
        (nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validatemodel = false;

      validatecolor = false;
      validatestatecode = false;
      validatevehicleDescriptor = false;
      validatenationalpermit = false;
      validateexpirydate = false;
      setState(() {});
    } else if (vehiclecolorcontroller.text.isEmpty &&
        stateselectedValue == null &&
        vehicledescriptorselectedValue == null &&
        nationalpermitselectedValue == null &&
        (nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validatecolor = false;
      validatestatecode = false;
      validatevehicleDescriptor = false;
      validatenationalpermit = false;
      validateexpirydate = false;
      setState(() {});
    } else if (stateselectedValue == null &&
        vehicledescriptorselectedValue == null &&
        nationalpermitselectedValue == null &&
        (nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validatestatecode = false;
      validatevehicleDescriptor = false;
      validatenationalpermit = false;
      validateexpirydate = false;
      setState(() {});
    } else if (vehicledescriptorselectedValue == null &&
        nationalpermitselectedValue == null &&
        (nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validatevehicleDescriptor = false;
      validatenationalpermit = false;
      validateexpirydate = false;
      setState(() {});
    } else if (nationalpermitselectedValue == null &&
        (nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validatenationalpermit = false;
      validateexpirydate = false;
      setState(() {});
    } else if ((nationalpermitselectedValue == "1" && permitexirydate == "")) {
      validateexpirydate = false;
      setState(() {});
    } else if (vehiclemakerselectedValue == null) {
      validatevehiclemaker = false;

      setState(() {});
    } else if (vehiclemodelselectedValue == null) {
      validatemodel = false;
      setState(() {});
    } else if (tagVehicleClassIDselectedValueName == null) {
      validatetagid = false;

      setState(() {});
    } else if (npciVehicleClassIDselectedValueName == null) {
      validatenpciid = false;

      setState(() {});
    } else if (vehicletypeselectedValue == null) {
      validatevehicletype = false;

      setState(() {});
    } else if (vehiclecolorcontroller.text.isEmpty) {
      validatecolor = false;

      setState(() {});
    } else if (stateselectedValue == null) {
      validatestatecode = false;

      setState(() {});
    } else if (vehicledescriptorselectedValue == null) {
      validatevehicleDescriptor = false;

      setState(() {});
    } else if (nationalpermitselectedValue == null) {
      validatenationalpermit = false;

      setState(() {});
    } else {
      setState(() {});
      Networkcallforsetvehicledetailsmanually();
    }
  }

  Future<void> Networkcallforsetvehicledetailsmanually() async {
    try {
      ProgressDialog.showProgressDialog(context, " title");
      String assignfaasttag = createjson()
          .createjsonforsetvehicledetailsmanually(
              vehiclemakerselectedValue!,
              vehiclemodelselectedValue!,
              textEditingControllertype.text,
              vehicletypeselectedValue!,
              npciVehicleClassIDselectedValue!,
              tagVehicleClassIDselectedValue!,
              vehiclecolorcontroller.text,
              "Active",
              widget.vehicle_number,
              stateselectedValue!,
              vehicledescriptorselectedValue!,
              nationalpermitselectedValue!,
              permitexirydate,
              context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().set_manually_vehicle_details,
          URLS().set_manually_vehicle_details_url,
          assignfaasttag,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Setvehicledetailsmanuallyresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            SnackBarDesign(
                "Vehicle details set successfully!!",
                context,
                colorfile().sucessmessagebcColor,
                colorfile().sucessmessagetxColor);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerDetailsPage(
                    widget.vehicle_number, widget.sessionId),
              ),
            );
            break;
          case "false":
            SnackBarDesign(
                "Unable to set vehicle details , Please try again",
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
