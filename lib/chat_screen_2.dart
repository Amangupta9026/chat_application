import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:timeago_flutter/timeago_flutter.dart';


class ChatRoomScreen extends StatefulWidget {
  // final String? userId;
  final String? userName;
  // final String? listenerId;
  final String? listenerName;
  final bool? isTextFieldVisible;
  final bool isfromListnerInbox;
  final bool isListener;

  const ChatRoomScreen({
    Key? key,
    // this.listenerId,
    this.listenerName,
    this.isListener = false,
    // this.userId,
    this.userName,
    this.isTextFieldVisible,
    this.isfromListnerInbox = false,
  }) : super(key: key);

  @override
  ChatRoomScreenState createState() => ChatRoomScreenState();
}

class ChatRoomScreenState extends State<ChatRoomScreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;

  String? docID;
  final TextEditingController _chatController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime lastTime = DateTime.now().subtract(const Duration(seconds: 60));
  

  int? sendvalue;
  
  String chatDocId = '';
  String attherate = '@';
  String hash = '#';
  String dotCom = '.com';
  bool isProgressRunning = false;

  final DateTime now = DateTime.now();
  String? token;

  Timer? _timer;

  int listenerId = 2;
  int userId = 1;
  String listenerName = 'Receiver';
  String userName = 'Sender';

  void tokenDevice() async {
    token = await FirebaseMessaging.instance.getToken();
  }

  @override
  void initState() {
    // log(widget.userName, name: 'userName');
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bool isListener = false;
    tokenDevice();

    // loadProviderData();

    _firestore
        .collection('chatroom')
        .where('user', isEqualTo: userId)
        .where('listener', isEqualTo: listenerId)
        .get()
        .then((value) {
      setState(() {
        docID = value.docs.isNotEmpty ? value.docs.first.id : null;
      });

      // is Seen
      if (docID != null) {
        _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .where('user_type', isEqualTo: isListener ? 'user' : 'listener')
            .get()
            .then((value) {
          // ignore: avoid_function_literals_in_foreach_calls
        
        });
        // set status online
      }

      checkStatus();

      //Uncomwent
    });

    _scrollController = ScrollController();
  }

  @override
  void dispose() async {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _scrollController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  checkStatus() async {
    var data = await _firestore.collection('chatroom').doc(docID).get();
  }

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  Future<void> onSendMessage(String id) async {
    if (_chatController.text.trim().isNotEmpty) {
      final chatRoomDetails =
          await _firestore.collection('chatroom').doc(docID).get();
      Map<String, dynamic> messages = {
        // "isImage": false,
        "sendby": widget.isListener ? listenerName : userName,
        //isListener ? widget.listenerName : widget.userName,
        "message": _chatController.text,
        "time": FieldValue.serverTimestamp(),
       
        "user_type": 'Chat',
        //isListener ? "listener" : "user",
      
      };
      if (docID == null) {
        var data = await _firestore.collection('chatroom').add({
          'user': userId,
          'user_name': userName,
          'listener': listenerId,
          'listener_name': listenerName,
          "last_time": FieldValue.serverTimestamp(),
          "listener_count": widget.isListener ? 1 : 0,
          "user_count": widget.isListener ? 0 : 1,
        });
        setState(() {
          docID = data.id;
        });

        _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .add(messages);

        // sendNotification(
        //     _chatController.text.trim(), widget.listenerId, widget.userName);
        _chatController.clear();
      } else {
        var data = await _firestore.collection('chatroom').doc(docID).get();

        await _firestore
            .collection('chatroom')
            .doc(docID)
            .collection('chats')
            .add(messages);
        await _firestore.collection('chatroom').doc(docID).update({
          "last_time": FieldValue.serverTimestamp(),
          "listener_count": widget.isListener ? data["listener_count"] + 1 : 0,
          "user_count": widget.isListener ? 0 : data["user_count"] + 1,
        });

        // sendNotification(
        //     _chatController.text.trim(), widget.listenerId, widget.userName);
      }
     
      _chatController.clear();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter some message')));
    }
  }

  onChatPushNotify() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      EasyLoading.show(
          status: "Connecting with our secure server",
          maskType: EasyLoadingMaskType.clear);
      // var data = await APIServices.getAgoraTokens();
      EasyLoading.dismiss();
      
    }
    
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        leadingWidth: 15,
        title: const Text('Chat'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/chat_bg.jpg"))),
                // height: size.height / 1.25,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chatroom')
                        .doc(docID)
                        .collection('chats')
                        .orderBy('time', descending: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        _firestore
                            .collection('chatroom')
                            .doc(docID)
                            .get()
                            .then((value) {
                          _firestore.collection('chatroom').doc(docID).update({
                            "last_time": FieldValue.serverTimestamp(),
                            "listener_count": widget.isListener
                                ? value.exists &&
                                        value
                                            .data()!
                                            .containsKey("listener_count")
                                    ? value["listener_count"]
                                    : 0
                                : 0,
                            "user_count": widget.isListener
                                ? 0
                                : value.exists &&
                                        value.data()!.containsKey("user_count")
                                    ? value["user_count"]
                                    : 0,
                          });
                        });

                        return ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length ?? 0,
                            itemBuilder: (context, index) {
                              return Container(
                                key: ValueKey(snapshot.data!.docs[index].id),
                                width: size.width,
                                alignment: widget.isListener
                                    ? snapshot.data!.docs[index]['sendby'] ==
                                            listenerName
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft
                                    : snapshot.data!.docs[index]['sendby'] ==
                                            userName
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 8,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: widget.isListener
                                              ? snapshot.data!.docs[index]
                                                          ['sendby'] ==
                                                      listenerName
                                                  ? Colors.blue
                                                  : Colors.green
                                              : snapshot.data!.docs[index]
                                                          ['sendby'] ==
                                                      userName
                                                  ? const Color(0xff23408e)
                                                  : Colors.green),
                                      child: Column(
                                        crossAxisAlignment: widget.isListener
                                            ? snapshot.data!.docs[index]
                                                        ['sendby'] ==
                                                    listenerName
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start
                                            : snapshot.data!.docs[index]
                                                        ['sendby'] ==
                                                    userName
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                        children: [
                                         
                                          const SizedBox(height: 10),
                                          Text(
                                            snapshot.data!.docs[index]
                                                ['message'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Timeago(
                                            date: snapshot.data!.docs[index]
                                                        ['time'] ==
                                                    null
                                                ? DateTime.now()
                                                : snapshot
                                                    .data!.docs[index]['time']
                                                    .toDate(),
                                            builder: (BuildContext context,
                                                String value) {
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    value,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.0,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  StreamBuilder(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'chatroom')
                                                          .doc(docID)
                                                          .collection('chats')
                                                          .doc(snapshot.data!
                                                              .docs[index].id)
                                                          .snapshots(),
                                                      builder: (context,
                                                          AsyncSnapshot<
                                                                  DocumentSnapshot>
                                                              snapshot2) {
                                                        // Is seen double check
                                                        if (snapshot2.hasData &&
                                                            snapshot2.data !=
                                                                null) {
                                                         
                                                            return const Icon(
                                                              Icons.done,
                                                              color: Colors.red,
                                                              size: 15,
                                                            );
                                                          
                                                        }
                                                        return const SizedBox
                                                            .shrink();
                                                      })
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              // Text(
                              //     snapshot.data!.docs[index]['message']);
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
              ),
            ),
            if (widget.isTextFieldVisible == false) ...{
              const SizedBox(
                height: 10,
              ),
            } else ...{
              Container(
                height: size.height / 10.0,
                width: size.width,
                alignment: Alignment.center,
                child: SizedBox(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    children: [
                      SizedBox(
                        height: size.height / 12,
                        width: size.width / 1.32,
                        child: TextField(
                          autofocus: true,
                          controller: _chatController,
                          decoration: const InputDecoration(
                            hintText: 'Type here',
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                          onTap: () {
                            onSendMessage(chatDocId);
                            onChatPushNotify();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(Icons.send),
                          )),
                    ],
                  ),
                ),
              ),
            }
          ],
        ),
      ),
    );
  }
}
