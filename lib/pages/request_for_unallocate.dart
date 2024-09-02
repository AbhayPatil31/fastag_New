import 'package:fast_tag/api/call/gettagforunallocatecall.dart';
import 'package:fast_tag/api/network/create_json.dart';
import 'package:fast_tag/api/response/gettagforunallocateresponse.dart';
import 'package:fast_tag/api/response/requestcategoryresponse.dart';
import 'package:fast_tag/pages/request_list.dart';
import 'package:fast_tag/utility/apputility.dart';
import 'package:fast_tag/utility/progressdialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../api/network/network.dart';
import '../api/network/uri.dart';
import '../api/response/categorydetailsresponse.dart';
import '../utility/colorfile.dart';
import '../utility/snackbardesign.dart';
import '../api/call/categorydetailscall.dart' as categorycall;
import 'request_unallocated_list.dart';
import 'skeletonpage.dart';

List<GettagforunallocateDatum> requestcategory = [];
bool nodata = true;

class RequestForUnallocate extends StatefulWidget {
  State createState() => RequestForUnallocateState();
}

class RequestForUnallocateState extends State<RequestForUnallocate> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Networkcallforwallettransactionhistory();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    requestcategory.clear();
    listofcategory.clear();
  }

  Future<void> Networkcallforwallettransactionhistory() async {
    try {
      String jsonstring =
          createjson().createjsonforgettagforunallocate(context);

      List<Object?>? list = await NetworkCall().postMethod(
          URLS().get_tag_for_unallocate,
          URLS().get_tag_for_unallocate_url,
          jsonstring,
          context);
      if (list != null) {
        List<Gettagforunallocateresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            requestcategory = response[0].data!;
            if (requestcategory.isNotEmpty) {
              nodata = true;
            } else {
              nodata = false;
            }
            setState(() {});
            break;
          case "false":
            nodata = false;
            setState(() {});
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

  bool sendrequest = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request For Unallocate',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2024),
              fontSize: 18,
            )),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Table Header Row
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade700),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                  // color: Colors.blue,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.blue.shade700),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'Tag Class',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0056D0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Allocated',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0056D0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.blue,
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Request',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0056D0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.blue.shade700),
                      right: BorderSide(color: Colors.blue.shade700),
                      bottom: BorderSide(color: Colors.blue.shade700),
                    ),
                  ),
                  child: requestcategory.isEmpty
                      ? nodata
                          ? Skeleton()
                          : Column(
                              children: [
                                Center(
                                  child: Lottie.asset(
                                    'images/nodatawithvehicle.json',
                                  ),
                                ),
                                Text(
                                  ' No stock found ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Looks like you haven't any stock yet ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            )
                      : Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.blue.shade700),
                              right: BorderSide(color: Colors.blue.shade700),
                              bottom: BorderSide(color: Colors.blue.shade700),
                            ),
                          ),
                          child: ListView.builder(
                            itemCount: requestcategory.length,
                            itemBuilder: (context, index) {
                              // controllerfortext.addIf(
                              //     requestcategory[index].vehicleClassCount != "",
                              //     index,
                              //     TextEditingController(
                              //         text: requestcategory[index]
                              //             .vehicleClassCount));
                              controllerfortext.putIfAbsent(index,
                                  () => TextEditingController(text: null));
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom:
                                        BorderSide(color: Colors.blue.shade700),
                                  ),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                  color: Colors.blue.shade700),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Text(
                                              requestcategory[index]
                                                          .categoryName ==
                                                      null
                                                  ? '-'
                                                  : requestcategory[index]
                                                      .categoryName!,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            requestcategory[index]
                                                .vehicleClassCount!,
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(
                                        color: Colors.blue,
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller: controllerfortext[index],
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              if (int.parse(
                                                      requestcategory[index]
                                                          .vehicleClassCount!) <
                                                  int.parse(
                                                      controllerfortext[index]!
                                                          .text)) {
                                                SnackBarDesign(
                                                    requestcategory[index]
                                                            .categoryName! +
                                                        " requested value must be less than original value",
                                                    context,
                                                    colorfile()
                                                        .errormessagebcColor,
                                                    colorfile()
                                                        .errormessagetxColor);
                                                sendrequest = false;
                                              } else {
                                                sendrequest = true;
                                              }
                                            } else {
                                              sendrequest = true;
                                            }
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border:
                                                InputBorder.none, // No border
                                            // hintText: 'Enter text', // Placeholder text
                                            contentPadding: EdgeInsets.symmetric(
                                                horizontal:
                                                    10.0), // Optional padding
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),

              // Table Footer Row
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF0056D0)),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF08469D),
                      Color(0xFF0056D0),
                      Color(0xFF0C92DD),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  color: Color(0xFF0056D0),
                ),
                child: GestureDetector(
                  onTap: () {
                    listofcategory.clear();
                    if (sendrequest) {
                      for (int i = 0; i < controllerfortext.length; i++) {
                        if (controllerfortext[i]!.value!.text.isNotEmpty) {
                          categorycall.Category abc = categorycall.Category(
                            categoryId: requestcategory[i].category_id!,
                            requested: controllerfortext[i]!.value!.text,
                          );
                          listofcategory.add(abc);
                        }
                      }
                      if (listofcategory.isNotEmpty) {
                        Networkcallforaddcategorydetails();
                      } else {
                        SnackBarDesign(
                            "Atleast request for one tag class",
                            context,
                            colorfile().errormessagebcColor,
                            colorfile().errormessagetxColor);
                      }
                    } else {
                      SnackBarDesign(
                          "requested value must be less than original value",
                          context,
                          colorfile().errormessagebcColor,
                          colorfile().errormessagetxColor);
                    }
                  },
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                            child: Text(
                              'Send Request',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  var controllerfortext = <int, TextEditingController>{};
  hexStringToHexInt(String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff' + hex : hex;
    int val = int.parse(hex, radix: 16);
    return val;
  }

  List<categorycall.Category> listofcategory = [];
  Future<void> Networkcallforaddcategorydetails() async {
    try {
      ProgressDialog.showProgressDialog(context, " title");
      String createjsonstring = createjson().createjsonforcategorydetails(
          AppUtility.AgentId, listofcategory, context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().fastag_category_details_api,
          URLS().set_tag_for_unallocate_url,
          createjsonstring,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Categorydetailsresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            SnackBarDesign(
                "Request Send Sucessfully!",
                context,
                colorfile().sucessmessagebcColor,
                colorfile().sucessmessagetxColor);
            setState(() {});
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RequestUnallocatedList()),
            );
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
}
