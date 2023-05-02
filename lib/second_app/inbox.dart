import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../chat_screen_2.dart';

class ListnerInboxScreen extends StatefulWidget {
  const ListnerInboxScreen({Key? key}) : super(key: key);

  @override
  ListnerInboxScreenState createState() => ListnerInboxScreenState();
}

class ListnerInboxScreenState extends State<ListnerInboxScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // late QuerySnapshot<Map<String, dynamic>> chats;

  bool _loading = false;
  String id = "";
  String name = "";
  bool isListener = false;
  bool isProgressRunning = false;

  bool isFirstCall = true;

  Future<void> loadData() async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();

    id = '2';
    name = 'Receiver';
    isListener = true;

    // _firestore
    //     .collection('chatroom')
    //     .where('listener', isEqualTo: id)
    //     .get()
    //     .then((value) {
    setState(() {
      _loading = false;
      // chats = value;
    });
    // });
  }

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadData();
    // apiGetDisplayNickName();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.white,
            body: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .where('listener', isEqualTo: 2)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    var chats = snapshot.data!.docs;
                    return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          var item = chats[index];
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChatRoomScreen(
                                            listenerName: 'Receiver',
                                            isListener: true,
                                            // listenerId: 2,
                                            // listenerName: name,
                                            // userId: item['user'],
                                            // userName: 'Anonymous',
                                          )),
                                  (Route<dynamic> route) => false);
                            },
                            title: const Text(
                              'Anonymous',
                              //    item['user_name'],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),

                            subtitle: Visibility(
                              visible: item["user_count"] > 0,
                              child: const Text(
                                'You have a new message',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            // Text(item['session'].toString()),
                            leading: const Icon(Icons.account_circle),
                            trailing: Visibility(
                              visible: item["user_count"] > 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    isListener
                                        ? item["user_count"].toString()
                                        : item["listener_count"].toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container();
                  }
                }),
          );
  }
}
