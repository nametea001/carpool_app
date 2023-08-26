import 'package:car_pool_project/gobal_function/color.dart';
import 'package:car_pool_project/models/chat.dart';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:car_pool_project/gobal_function/data.dart';
import 'package:intl/intl.dart';
import 'package:prefs/prefs.dart';
import 'package:car_pool_project/global.dart' as globals;

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  User? user;
  ChatScreen({
    super.key,
    this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  GlobalData globalData = GlobalData();
  User user = User();
  List<Chat> chats = [];

  List checkChatType(Chat chat) {
    String name = "";
    String? img = "";
    if (chat.chatType == "PRIVATE") {
      name = chat.sendUserID != user.id
          ? "${chat.sendUser!.firstName ?? 'Firstname'} ${chat.sendUser!.lastName ?? 'Lastname'}"
          : "${chat.createdUser!.firstName ?? 'Firstname'} ${chat.createdUser!.lastName ?? 'Lastname'}";
      img = chat.sendUserID != user.id
          ? "http://${globals.serverIP}/profiles/${chat.sendUser!.img}"
          : "http://${globals.serverIP}/profiles/${chat.createdUser!.img}";
    } else {
      name = "${chat.post!.endName}";
      img = chat.post!.endName;
    }
    return [name, img];
  }

  List<ListTile> getListTile() {
    var c = GetColor();
    List<ListTile> list = [];
    int i = 0;
    for (var chat in chats) {
      var name = checkChatType(chat);
      var l = ListTile(
        tileColor: c.colorListTile(i),
        contentPadding: const EdgeInsets.only(
            top: 15.0, left: 15.0, right: 10.0, bottom: 5.0),
        leading: CircleAvatar(
          maxRadius: 30,
          child: ClipOval(
            child: Image.network(
              name[1],
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  " ${name[0]}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 23),
                ),
              ],
            ),
          ],
        ),
        subtitle: Text(" ${chat.chatDetail!.msg}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: chat.chatUserLog!.count == 0 ? null : Colors.black,
            )),
        // trailing: Text(dateTimeformat(DateTime.now())),
        trailing:
            Text(DateFormat("HH:mm:").format(chat.createdAt ?? DateTime.now())),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                      user: user,
                      chatDB: chat,
                      pushFrom: "Chat",
                    )),
          );
        },
      );
      i++;
      list.add(l);
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    user = (widget.user)!;
    updateUI();
  }

  updateUI() async {
    final prefs = await SharedPreferences.getInstance();
    List<Chat>? tempData = await Chat.getChats(prefs.getString('jwt') ?? "");

    setState(() {
      chats = tempData ?? [];
    });
  }

  Widget listView() {
    if (chats.isNotEmpty) {
      return Expanded(
          child: RefreshIndicator(
        onRefresh: () async {
          updateUI();
        },
        child: ListView(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          // physics: BouncingScrollPhysics(),
          // physics: AlwaysScrollableScrollPhysics(),
          children: getListTile(),
        ),
      ));
    } else {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No data",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: listView(),
          ),
        ],
      ),
    );
  }
}
