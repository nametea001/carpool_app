import 'dart:async';
import 'dart:convert';
import 'package:car_pool_project/models/post.dart';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/screens/post_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

class PostScreen extends StatefulWidget {
  final User? user;
  final Post? posts;

  const PostScreen({
    this.user,
    this.posts,
  });
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  User user = User();
  bool _isLoading = true;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    user = (widget.user)!;
    updateUI(); //loading posts
  }

  // ListTile posts
  List<ListTile> getListTile() {
    List<ListTile> list = [];
    for (var post in posts) {
      var l = ListTile(
        contentPadding:
            EdgeInsets.only(top: 15.0, left: 15.0, right: 10.0, bottom: 5.0),
        leading: (post.img != null
            ? GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  maxRadius: 30,
                  child: ClipOval(
                    child: Image.memory(
                      base64Decode(post.img!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            : null),
        title: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.pin_drop,
                  color: Colors.red,
                ),
                Text(
                  "${post.startAmphireName} ${post.startProvinceName}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.golf_course,
                  color: Colors.green,
                ),
                Text(
                  "${post.endAmphireName} ${post.endProvinceName}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        subtitle: Text("sub test"),
        trailing: Text("test trail"),
        onTap: () {},
      );
      list.add(l);
    }
    for (int i = 0; i < 15; i++) {
      var l = ListTile(
        title: Text("ssssss"),
      );
      list.add(l);
    }

    return list;
  }

  List<Widget> appBarBt() {
    var bt = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            InkWell(
              onTap: () {},
              child: CircleAvatar(
                maxRadius: 20,
                child: user.img != null
                    ? ClipOval(
                        child: Image.memory(
                          base64Decode(user.img!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    ];
    return bt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Post"),
          backgroundColor: Colors.pink,
          actions: appBarBt(),
        ),
        // sidebar
        drawer: Drawer(
          child: ListView(children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pink,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 50.0,
                  ),
                  Row(
                    children: [
                      Text(
                        "${user.email}",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "${user.firstName}  ${user.lastName}",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ListTile(
            //   leading: CircleAvatar(
            //       backgroundColor: Colors.red,
            //       child: ClipOval(
            //         child: Image.memory(
            //           base64Decode(user.img!),
            //         ),
            //       )),
            //   title: Text("My Profile"),
            //   onTap: () => {},
            // ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("My Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("History"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("About"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ]),
        ),
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            (_isLoading
                ? listLoader()
                : Container(
                    child: Expanded(
                        child: RefreshIndicator(
                      onRefresh: () async {
                        updateUI();
                      },
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: getListTile(),
                      ),
                    )),
                  )),
          ],
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostDetailScreen()),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.pink,
        ));
  }

  updateUI() async {
    setState(() {
      _isLoading = true;
    });
    List<Post>? tempData = await Post.getPost(user.username!);
    setState(() {
      posts = tempData ?? [];
      _isLoading = false;
    });
  }

  // skeleton_loader
  Widget listLoader() {
    var s = Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          // updateUI();
        },
        child: SingleChildScrollView(
          child: SkeletonLoader(
            builder: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 10,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
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
            period: Duration(seconds: 2),
            highlightColor: Colors.pink,
            direction: SkeletonDirection.ltr,
          ),
        ),
      ),
    );
    return s;
  }
}
