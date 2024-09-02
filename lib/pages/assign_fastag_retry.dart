import 'package:dio/dio.dart';
import 'package:fast_tag/api/network/create_json.dart';
import 'package:fast_tag/api/network/network.dart';
import 'package:fast_tag/api/network/uri.dart';
import 'package:fast_tag/api/response/assignfasttagresponse.dart';
import 'package:fast_tag/pages/assign_otp.dart';
import 'package:fast_tag/pages/replace_fastag.dart';
import 'package:fast_tag/utility/colorfile.dart';
import 'package:fast_tag/utility/progressdialog.dart';
import 'package:fast_tag/utility/snackbardesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

final vehiclecontroller = TextEditingController();
final mobilecontroller = TextEditingController();
final chassisnumbercontroller = TextEditingController();
final enginecontroller = TextEditingController();
bool ischasisselected = true;

class AssignFastagRetryPage extends StatefulWidget {
  String mobilenumber, vehiclenumber, ischasis, chasisnumber, enginenumber;
  AssignFastagRetryPage(this.mobilenumber, this.vehiclenumber, this.ischasis,
      this.chasisnumber, this.enginenumber);
  State createState() => AssignFastagRetryPageState();
}

class AssignFastagRetryPageState extends State<AssignFastagRetryPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mobilecontroller.text = widget.mobilenumber;
    vehiclecontroller.text = widget.vehiclenumber;
    enginecontroller.text = widget.enginenumber;
    chassisnumbercontroller.text = widget.chasisnumber;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    vehiclecontroller.clear();
    mobilecontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assign FasTag',
          style: TextStyle(
            fontSize: 20, // 25px size
            fontWeight: FontWeight.bold, // Bold text
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'images/fastatag1.png', // Make sure to replace with your actual image asset
                  height: 400, // Adjust the height as needed
                ),
              ),

              Text(
                'Enter Details',
                style: TextStyle(
                  fontSize: 25, // 25px size
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
              SizedBox(height: 20), // Adding space before the first text field
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
                  controller: vehiclecontroller,
                  readOnly: true,
                  enabled: true,
                  decoration: InputDecoration(
                    hintText: 'Enter Vehicle Number*',

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
              SizedBox(height: 20),

              // Adding space before the second text field
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
                  controller: mobilecontroller,
                  readOnly: true,
                  enabled: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter Mobile Number*',

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
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 5), // Offset in x and y directions
                    ),
                  ],
                ),
                child: TextField(
                  readOnly: true,
                  enabled: true,
                  controller: enginecontroller,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    setState(() {});
                  },
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter Last 5 Digits of Engine Number*',
                    errorStyle: TextStyle(color: Colors.red, fontSize: 10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 252, 250, 250)!),
                    ),
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                ),
              ),
              // Row(
              //   children: [
              //     Checkbox(
              //       value: ischasisselected, // Use the state variable here
              //       onChanged: (value) {
              //         ischasisselected = value!;
              //         setState(() {});
              //       },
              //     ),
              //     Flexible(
              //       child: Text(
              //         'Chassis Number',
              //         style:
              //             TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
              //       ),
              //     ),
              //   ],
              // ),
              widget.ischasis == "1"
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
                        readOnly: true,
                        enabled: true,
                        controller: chassisnumbercontroller,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Z0-9]')),
                        ],
                        keyboardType: TextInputType.visiblePassword,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 5,
                        decoration: InputDecoration(
                          hintText: 'Enter last 5 digits of chasis number',
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
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Networkcallforassignfasttag();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xFF0056D0),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5.0), // Button corner radius 5px
                      ),
                    ),
                  ),
                  child: Container(
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

  Future<void> Networkcallforassignfasttag() async {
    try {
      ProgressDialog.showProgressDialog(context, " title");
      String assignfaasttag = createjson().createjsonforassignfasttag(
        vehiclecontroller.text,
        mobilecontroller.text,
        widget.ischasis,
        chassisnumbercontroller.text,
        // enginecontroller.text,
      );
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().generate_otp_by_vehicle,
          URLS().generate_otp_by_vehicle_url,
          assignfaasttag,
          context);
      if (list != null) {
        Navigator.pop(context);
        List<Assignvehicleresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            SnackBarDesign(
                "OTP send on your mobile number",
                context,
                colorfile().sucessmessagebcColor,
                colorfile().sucessmessagetxColor);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AssignOtpPage(
                      response[0].data![0].requestId!,
                      response[0].data![0].sessionId!,
                      mobilecontroller.text,
                      vehiclecontroller.text,
                      ischasisselected ? "0" : "1",
                      chassisnumbercontroller.text,
                      enginecontroller.text)),
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
