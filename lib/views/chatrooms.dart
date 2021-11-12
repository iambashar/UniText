import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unitext/helper/authenticate.dart';
import 'package:unitext/helper/constants.dart';
import 'package:unitext/services/auth.dart';
import 'package:unitext/services/database.dart';
import 'package:unitext/views/chat.dart';
import 'package:unitext/views/search.dart';
import 'package:unitext/widgets/widgets.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream? chatRooms;
  String? userEmail;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ChatRoomsTile(
                    userName: snapshot.data.docs[index]
                        .get('chatRoomId')
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll(Constants.myUid, ""),
                    chatRoomId: snapshot.data.docs[index].get('chatRoomId'),
                  );
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    userEmail = FirebaseAuth.instance.currentUser!.email;
    getUserInfogetChats();
    super.initState();
  }

  getUserInfogetChats() async {
    try {
      QuerySnapshot snapshot = await DatabaseMethods().getUserInfo(userEmail!);
      Constants.myUid = snapshot.docs[0].get('userUid').toString();
      await DatabaseMethods().getUserChats(Constants.myUid).then((snapshots) {
        setState(() {
          chatRooms = snapshots;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
        elevation: 0.0,
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () {
              AuthService().signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Authenticate()));
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          )
        ],
      ),
      body: Container(
        child: chatRoomsList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Search()));
        },
      ),
    );
  }
}

class ChatRoomsTile extends StatefulWidget {
  final String userName;
  final String chatRoomId;

  ChatRoomsTile({required this.userName, required this.chatRoomId});

  @override
  State<ChatRoomsTile> createState() => _ChatRoomsTileState();
}

class _ChatRoomsTileState extends State<ChatRoomsTile> {
  late String name = 'User';

  @override
  void initState() {
    super.initState();
    getUid();
  }

  getUid() async{
    String uid = widget.userName;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("userUid", isEqualTo: uid)
        .get();

    setState(() {
      name = snapshot.docs[0].get('userName').toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Chat(
                        chatRoomId: widget.chatRoomId,
                        receiver: name
                      )));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Color(0xFF2C2F33),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: CustomTheme.colorAccent,
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: Text(name.substring(0, 1),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Text(name,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w300))
            ],
          ),
        ));
  }
}
