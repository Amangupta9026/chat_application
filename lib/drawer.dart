// ignore_for_file: non_constant_identifier_names;

import 'package:chat_application/chat_screen_2.dart';
import 'package:chat_application/second_app/inbox.dart';
import 'package:flutter/material.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  DrawerScreenState createState() => DrawerScreenState();
}

class DrawerScreenState extends State<DrawerScreen> {
  bool isProgressRunning = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(
                    height: 45,
                  ),
                  customRow(
                    "User Chat Screen",
                    const Icon(Icons.home, color: Colors.black),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatRoomScreen(
                            isListener: false,
                          ),
                        ),
                      );
                    },
                  ),
                  customRow(
                    "Receiver Chat Screen",
                    const Icon(Icons.person, color: Colors.black),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListnerInboxScreen(
                            
                          
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget customRow(String txt, Icon icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, right: 13),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: icon,
              ),
            ),

            //   Icon(icon, color: Theme.of(context).textTheme.headline6.color),
            const SizedBox(
              width: 15,
            ),
            Text(
              txt,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button

    Widget okButton = TextButton(
      child: Container(
          color: Colors.blue,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(25.0, 5, 25, 5),
            child: Text(
              "OK",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
      onPressed: () {
        Navigator.pop(context);
        Scaffold.of(context).openEndDrawer();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(0),
      insetPadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.all(0),
      buttonPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: const [
                    Text("You are Anonymous"),
                  ],
                ),
              )),
        ],
      ),
      content: const Padding(
        padding: EdgeInsets.fromLTRB(14.0, 18, 14, 20),
        child: Text("Dear user,\nYour profile is anonymous to everyone."),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
