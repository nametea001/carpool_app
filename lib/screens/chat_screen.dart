// import 'package:car_pool_project/gobal_function/color.dart';
// ignore_for_file: avoid_print, library_prefixes

import 'package:car_pool_project/models/chat.dart';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:car_pool_project/gobal_function/data.dart';
import 'package:prefs/prefs.dart';
import 'package:car_pool_project/global.dart' as globals;
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  User user;
  ChatScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  GlobalData globalData = GlobalData();
  User user = User();
  List<Chat> chats = [];

  bool _isLoading = true;

  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    user = (widget.user);
    initSocketIO();
    updateUI();
    // _isLoading = false;
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  void initSocketIO() {
    String pathSocket = "${globals.webSocketProtocol}${globals.serverIP}/";
    socket = IO.io(
      pathSocket,
      OptionBuilder()
          .setTransports(['websocket'])
          .setPath("/api/socket_io")
          // .setQuery({"user_id": user.id})
          .build(),
    );
    socket.onConnect((_) {
      print('Connected Socket IO Chat');
    });
    socket.on('chat_user_${user.id}', (data) async {
      if (data == "Update_UI") {
        _acceptChat();
      }
    });
    socket.onConnectError((data) => print("Connect Error $data"));
    socket.onDisconnect((data) => print("Disconnect"));
    // socket.on('message', (data) => print(data));
  }

  List checkChatType(Chat chat) {
    String name = "";
    String? img = "";
    String? nameUser = "";
    bool isYou = chat.chatDetail?.createdUserID == user.id ? true : false;
    if (chat.chatType == "PRIVATE") {
      img = chat.sendUserID != user.id
          ? "${globals.protocol}${globals.serverIP}/profiles/${chat.sendUser!.img}"
          : "${globals.protocol}${globals.serverIP}/profiles/${chat.createdUser!.img}";
      nameUser = isYou ? "คุณ:" : " ";
      name = chat.sendUserID != user.id
          ? "${chat.sendUser!.firstName ?? 'Firstname'} ${chat.sendUser!.lastName ?? 'Lastname'}"
          : "${chat.createdUser!.firstName ?? 'Firstname'} ${chat.createdUser!.lastName ?? 'Lastname'}";
    } else {
      img = "${globals.protocol}${globals.serverIP}/profiles/${chat.img}";
      name = chat.post!.endName!;
    }

    if (chat.chatDetail?.createdUserID == user.id) {}

    return [img, name, nameUser];
  }

  List<ListTile> getListTile() {
    // var c = GetColor();
    List<ListTile> list = [];
    // int i = 0;
    for (var chat in chats) {
      var name = checkChatType(chat);
      var l = ListTile(
        // tileColor: c.colorListTile(i),
        contentPadding: const EdgeInsets.only(
            top: 5.0, left: 15.0, right: 10.0, bottom: 5.0),
        leading: CircleAvatar(
          maxRadius: 30,
          child: ClipOval(
            child: Image.network(
              name[0],
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    " ${name[1]}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: chat.chatUserLog!.count == 0
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontSize: 23,
                      color: chat.chatUserLog!.count == 0 ? null : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Flexible(
          child: Text(" ${name[2]}${chat.chatDetail!.msg}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: chat.chatUserLog!.count == 0
                    ? FontWeight.normal
                    : FontWeight.bold,
                fontSize: 16,
                color: chat.chatUserLog!.count == 0 ? null : Colors.black,
              )),
        ),
        // trailing: Text(dateTimeformat(DateTime.now())),
        trailing: Text(globalData.dateTimeFormatForChat(chat.updatedAt)),
        onTap: () {
          setState(() {
            chat.chatUserLog!.count = 0;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                      showBackbt: true,
                      user: user,
                      chatDB: chat,
                      pushFrom: "Chat",
                    )),
          );
        },
      );
      // i++;
      list.add(l);
    }

    return list;
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

  void _acceptChat() async {
    final prefs = await SharedPreferences.getInstance();
    List<Chat>? tempData = await Chat.getChats(prefs.getString('jwt') ?? "");

    setState(() {
      chats.removeWhere(
          (chat1) => tempData!.any((chat2) => chat1.id == chat2.id));
      chats.addAll(tempData!);
    });
  }

  void updateUI() async {
    final prefs = await SharedPreferences.getInstance();
    List<Chat>? tempData = await Chat.getChats(prefs.getString('jwt') ?? "");

    setState(() {
      chats = tempData ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.pink,
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         {
        //           // Map<int, String> data2Map = Map.fromIterable(data2,
        //           //     key: (user) => user.id, value: (u) => u.firstName);
        //           // for (User user1 in data1) {
        //           //   if (data2Map.containsKey(user1.id)) {
        //           //     user1.firstName = data2Map[user1.id]!;
        //           //   }
        //           // }
        //         }
        //       },
        //       icon: Icon(Icons.abc))
        // ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _isLoading
                ? listLoader()
                : Container(
                    child: listView(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget listLoader() {
    var loader = Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          // updateUI();
        },
        child: SingleChildScrollView(
          child: SkeletonLoader(
            builder: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            items: 10,
            period: const Duration(seconds: 2),
            highlightColor: Colors.pink,
            direction: SkeletonDirection.ltr,
          ),
        ),
      ),
    );
    return loader;
  }
}
