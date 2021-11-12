import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unitext/helper/constants.dart';
import 'package:unitext/services/database.dart';
import 'package:unitext/widgets/widgets.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  String chatRoomId;
  String receiver;

  Chat({required this.chatRoomId, required this.receiver});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  late Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  String? name;

  Widget chatMessages(){
    return Container(
      alignment: FractionalOffset.center,
      margin: EdgeInsets.only(bottom: 70),
      child: StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot){
          return snapshot.hasData ?  ListView.builder(
            itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              reverse: true,
              itemBuilder: (_, index){
                return MessageTile(
                  message: snapshot.data.docs[index].get('message'),
                  sendByMe: Constants.myUid == snapshot.data.docs[index].get('sendBy'),
                  sendTime: snapshot.data.docs[index].get('time'),
                );
              }) : Container();
        },
      ),
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myUid,
        "message": messageEditingController.text,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiver),
        elevation: 0.0,
        centerTitle: false,
      ),
      body: Container(
        child: Stack(
          fit: StackFit.loose,
          alignment: AlignmentDirectional.bottomStart,
          children: [
            chatMessages(),
            Container(alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xFF2C2F33),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageEditingController,
                          style: simpleTextStyle(),
                          decoration: InputDecoration(
                              hintText: "Enter Your Message ...",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none
                              ),
                          ),
                        ),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              color: const Color(0x36FFFFFF),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          child: Center(child: Icon(Icons.send))
                      )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final int sendTime;

  MessageTile({required this.message, required this.sendByMe, required this.sendTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe ? 0 : 12,
          right: sendByMe ? 12 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(
            top: 10, bottom: 10, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe ? BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
            ) :
            BorderRadius.only(
        topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
          bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe ? [
                const Color(0xff007EF4),
                const Color(0xff2A75BC)
              ]
                  : [
                const Color(0x1AFFFFFF),
                const Color(0x1AFFFFFF)
              ],
            )
        ),
        child: Column(
          children: [
            Text(message,
                textAlign: TextAlign.left,
                style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w300)),
            Text(DateFormat('dd/MM/yyyy, hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(sendTime)),
            textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 8
              ),
            ),
          ],
        ),
      ),
    );
  }
}

