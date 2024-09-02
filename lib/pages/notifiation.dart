import 'package:fast_tag/api/response/getnotificationresponse.dart';
import 'package:fast_tag/utility/progressdialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../api/network/create_json.dart';
import '../api/network/network.dart';
import '../api/network/uri.dart';
import '../utility/apputility.dart';
import '../utility/colorfile.dart';
import '../utility/snackbardesign.dart';
import 'skeletonpage.dart';

List<GetnotificationDatum> notificationlist = [];
bool nodata = true;

class NotificationPage extends StatefulWidget {
  State createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Networkcallfornotificationlist(true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    notificationlist.clear();
  }

  Future<void> Networkcallfornotificationlist(bool showprogress) async {
    try {
      if (showprogress) {
        ProgressDialog.showProgressDialog(context, "title");
      }
      String createjsonforstocklist =
          createjson().createjsonforstocklist(AppUtility.AgentId, context);
      List<Object?>? list = await NetworkCall().postMethod(
          URLS().get_my_notifications,
          URLS().get_my_notifications_url,
          createjsonforstocklist,
          context);
      if (list != null) {
        if (showprogress) {
          Navigator.pop(context);
        }
        List<Getnotificationresponse> response = List.from(list!);
        String status = response[0].status!;
        switch (status) {
          case "true":
            notificationlist = response[0].data!;
            if (notificationlist.isNotEmpty) {
              nodata = true;
            } else {
              nodata = false;
            }
            setState(() {});
            break;
          case "false":
            nodata = false;
            SnackBarDesign(
                response[0].message!,
                context,
                colorfile().errormessagebcColor,
                colorfile().errormessagetxColor);
            break;
        }
      } else {
        if (showprogress) {
          Navigator.pop(context);
        }
        nodata = false;
        setState(() {});
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
          title: Text('Notifications',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D2024),
                fontSize: 18,
              )),
        ),
        body: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(const Duration(seconds: 1), () {
                Networkcallfornotificationlist(false);
              });
            },
            child: notificationlist.isEmpty
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
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: notificationlist.length,
                      itemBuilder: (context, index) {
                        DateTime now = DateTime.now();

                        Duration duration = now
                            .difference(notificationlist[index].createdOn!)
                            .abs();

                        final days = duration.inDays;
                        final hours = duration.inHours % 24;
                        final minutes = duration.inMinutes % 60;

                        String timeAgo;
                        if (days > 0) {
                          timeAgo =
                              (days == 1 ? '$days day ago' : '$days days ago');
                        } else if (hours > 0) {
                          timeAgo = ('$hours hours $minutes minutes ago');
                        } else {
                          timeAgo = ('$minutes minutes ago');
                        }
                        return NotificationItem(
                          message: notificationlist[index].description!,
                          timeAgo: timeAgo,
                        );
                      },
                    ),
                  )));
  }
}

class NotificationItem extends StatelessWidget {
  final String message;
  final String timeAgo;

  NotificationItem({
    required this.message,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(248, 243, 242, 242),
                ),
                // child: Icon(Icons.notifications_outlined),
                child: Image.asset(
                  'images/not.png', // Replace this with your image path
                  color: Colors.blue,
                  fit: BoxFit.none,
                  width: 10.0,
                  height: 10.0,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                flex:
                    4, // This makes the second column 3 times wider than the third column
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              Expanded(
                flex:
                    1, // This makes the third column 1 time wider than the third column
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeAgo,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 8,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 0,
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NotificationPage(),
  ));
}
