// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

class ConfigSystem {
  static Future<String> getServer() async {
    // try {
    //   final directory = await getApplicationDocumentsDirectory();
    //   final file = File('${directory.path}/server.txt');
    //   String text = await file.readAsString();
    //   if (text == "") {
    //     setServer('192.168.1.2');
    //     return '192.168.1.2';
    //   }
    //   return text;
    // } catch (e) {
    //   setServer('192.168.1.2');
    //   return '192.168.1.2';
    // }
    return '10.0.2.2:3000'; // 10.0.3.2 if fisrt not work
  }

  // static void setServer(String serverIP) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final file = File('${directory.path}/server.txt');
  //   final text = serverIP;
  //   await file.writeAsString(text);
  // }
}
