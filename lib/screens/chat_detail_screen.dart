import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:car_pool_project/models/chat_detail.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// ignore: depend_on_referenced_packages
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prefs/prefs.dart';
import 'package:uuid/uuid.dart';
import '../models/chat.dart' as c;
import '../models/user.dart';
import '../gobal_function/data.dart';
import 'package:car_pool_project/global.dart' as globals;

// ignore: must_be_immutable
class ChatDetailScreen extends StatefulWidget {
  User? user;
  String? pushFrom;
  c.Chat? chatDB;
  ChatDetailScreen({
    super.key,
    this.user,
    this.pushFrom,
    this.chatDB,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late List<types.Message> _messages = [];
  types.User _userChat = types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  User? user = User();
  c.Chat chatDB = c.Chat();
  String? pushFrom = "Chat";

  String firstName = "Fristname";
  String lastName = "Lastname";
  String img = "";

  @override
  void initState() {
    super.initState();
    user = widget.user;
    chatDB = widget.chatDB ?? c.Chat();
    pushFrom = widget.pushFrom;
    _userChat = types.User(id: (user!.id.toString()));
    updateUI();
    // _loadMessages();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    (InkWell(
                      onTap: () {},
                      child: CircleAvatar(
                        maxRadius: 20,
                        child: (img != ""
                            ? ClipOval(
                                child: Image.network(
                                  img,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : null),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text("$firstName $lastName"),
            ],
          ),
          backgroundColor: Colors.pink,
        ),
        body: Chat(
          messages: _messages,
          onAttachmentPressed: _handleAttachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: _userChat,
        ),
      );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _handleFileSelection() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //   );

  //   if (result != null && result.files.single.path != null) {
  //     final message = types.FileMessage(
  //       author: _userChat,
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //       id: const Uuid().v4(),
  //       mimeType: lookupMimeType(result.files.single.path!),
  //       name: result.files.single.name,
  //       size: result.files.single.size,
  //       uri: result.files.single.path!,
  //     );

  //     _addMessage(message);
  //   }
  // }

  // void _handleImageSelection() async {
  //   final result = await ImagePicker().pickImage(
  //     imageQuality: 70,
  //     maxWidth: 1440,
  //     source: ImageSource.gallery,
  //   );

  //   if (result != null) {
  //     final bytes = await result.readAsBytes();
  //     final image = await decodeImageFromList(bytes);

  //     final message = types.ImageMessage(
  //       author: _userChat,
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //       height: image.height.toDouble(),
  //       id: const Uuid().v4(),
  //       name: result.name,
  //       size: bytes.length,
  //       uri: result.path,
  //       width: image.width.toDouble(),
  //     );

  //     _addMessage(message);
  //   }
  // }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;
      if (message.uri.startsWith('https')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _userChat,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    var data = GlobalData();
    final response = data.test();
    final messages = response
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    for (var message in messages) {
      _messages.add(message);
    }
  }

  void updateUI() async {
    final prefs = await SharedPreferences.getInstance();

    if (pushFrom != "Chat") {
      var tempData = await ChatDetail.startChatDetails(
          prefs.getString('jwt') ?? "", chatDB);
      if (tempData != null) {
        setState(() {
          chatDB = tempData[0];
        });
        _messages = tempData[1] ?? [];

        // for (var message in tempData[1]) {
        //   _messages.insert(0, message);
        // }
      }
    } else {
      _messages = await ChatDetail.getChatDetails(
              prefs.getString('jwt') ?? "", chatDB) ??
          [];
    }

    if (chatDB.sendUserID != user!.id) {
      setState(() {
        firstName = chatDB.sendUser!.firstName ?? "FristName";
        lastName = chatDB.sendUser!.lastName ?? "FristName";
        img = "http://${globals.serverIP}/profiles/${chatDB.sendUser!.img}";
      });
    } else {
      setState(() {
        firstName = chatDB.createdUser!.firstName ?? "FristName";
        lastName = chatDB.createdUser!.lastName ?? "FristName";
        img = "http://${globals.serverIP}/profiles/${chatDB.createdUser!.img}";
      });
    }
  }
}
