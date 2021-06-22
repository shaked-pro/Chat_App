import 'dart:developer';
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
  static String id = 'chat';
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _autho = FirebaseAuth.instance;
  String msg;
  final _Myfirestore = FirebaseFirestore.instance;
  bool isMe = false;
  var LoggedIn;

  @override
  void initState() {
    super.initState();
    GetCurrentUser();
  }

  void GetCurrentUser() async {
    final user = await _autho.currentUser;
    try {
      if (user != null) LoggedIn = user;
    } catch (e) {
      print('unable to identidy uesr');
    }
  }

  @override
  Widget build(BuildContext context) {
    //print(LoggedInuser);
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _autho.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _Myfirestore.collection('messages').snapshots(),
                builder: (context, Snapshot) {
                  if (Snapshot.hasData) {
                    final messages = Snapshot.data.docs;
                    //print(Snapshot.data.docs.runtimeType);
                    List<ChatBubble> messageswidgets = [];
                    messages.sort((a, b) => b['time'].compareTo(a['time']));
                    for (var msg1 in messages) {
                      String textmessage = msg1['text'];
                      String textsender = msg1['sender'];

                      print(LoggedIn);
                      if (LoggedIn.email == textsender) {
                        isMe = true;
                      } else {
                        isMe = false;
                      }

                      final messagewidget = ChatBubble(
                          sender: textsender, text: textmessage, isMe: isMe);
                      messageswidgets.add(messagewidget);
                    }
                    return Expanded(
                        child: ListView(
                            reverse: true,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            children: messageswidgets));
                  } else {
                    return (Center(child: CircularProgressIndicator()));
                  }
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        msg = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      var user = await _autho.currentUser;
                      await _Myfirestore.collection('messages').add({
                        'text': msg,
                        'sender': user.email,
                        'time': DateTime.now()
                      });
                      messageTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  String sender, text;
  bool isMe;
  ChatBubble({this.sender, this.text, this.isMe});
  @override
  Widget build(BuildContext context) {
    print(isMe);
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          '$sender',
          style: TextStyle(color: Colors.white54, fontSize: 12.5),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(12),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: (Text(
                '$text',
                style: TextStyle(color: isMe ? Colors.white : Colors.black),
              )),
            ),
          ),
        ),
      ],
    );
  }
}
