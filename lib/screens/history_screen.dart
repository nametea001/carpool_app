// import 'package:car_pool_project/gobal_function/color.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:car_pool_project/gobal_function/data.dart';
import 'package:car_pool_project/models/post.dart';
import 'package:car_pool_project/models/review.dart';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/screens/post_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:car_pool_project/global.dart' as globals;
import '../models/chat.dart';
import '../models/report_reason.dart';
import 'chat_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final User user;
  final List<ReportReason> reportReasons;

  const HistoryScreen({
    super.key,
    required this.user,
    required this.reportReasons,
  });
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  User user = User();
  GlobalData globalData = GlobalData();
  bool _isLoading = true;
  List<Post> posts = [];
  List<Post> postsState = [];
  List<int> postIDKey = [];

  List<Review> reviews = [];
  double avgReview = 0.0;

  bool settingMyPost = true;
  bool settingJoinPost = true;

  List<ReportReason> reportReasons = [];

  @override
  void initState() {
    super.initState();
    user = (widget.user);
    setState(() {
      _isLoading = true;
    });
    updateUI();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget listViewPostStatusALL() {
    if (postsState.isNotEmpty) {
      List<ListTile> list = [];
      for (Post post in postsState) {
        var l = ListTile(
          contentPadding: const EdgeInsets.only(
              top: 5.0, left: 15.0, right: 10.0, bottom: 5.0),
          leading: (post.user!.img != null
              ? GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    var tempData = await Review.getReviews(
                        prefs.getString('jwt') ?? "", post.createdUserID!);
                    setState(() {
                      reviews = tempData![0] ?? [];
                      avgReview = globalData.avgDecimalPointFormat(tempData[1]);
                    });
                    User? u = post.user;
                    u!.id = post.createdUserID;
                    showDetailReview(u);
                  },
                  child: CircleAvatar(
                    maxRadius: 30,
                    child: ClipOval(
                      child: Image.network(
                          "${globals.protocol}${globals.serverIP}/profiles/${post.user!.img}",
                          fit: BoxFit.cover),
                    ),
                  ),
                )
              : null),
          // tileColor: Colors.amberAccent,
          title: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.pin_drop,
                    color: Colors.red,
                  ),
                  Flexible(
                    child: Text(
                      "${post.startName}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.golf_course,
                    color: Colors.green,
                  ),
                  Flexible(
                    child: Text(
                      "${post.endName}",
                      // textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.alarm,
                    color: Colors.orange,
                  ),
                  Text(globalData.dateTimeFormatForPost(post.dateTimeStart)),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.airline_seat_recline_normal,
                    color: colorSeat(
                        post.countPostMember!, post.postDetail!.seat!),
                  ),
                  Text(
                    "${post.countPostMember}/${post.postDetail!.seat}",
                    // style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
          // subtitle: Column(
          //   children: [],
          // ),
          trailing: Column(
            children: [
              Text("${post.postDetail!.price}"),
              // const SizedBox(height: 5),
              Text(
                "${post.status}",
                style: TextStyle(
                    color: colorStatus(post.status!),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(
                  user: user,
                  isAdd: false,
                  isback: post.isBack,
                  post: post,
                  isView: true,
                  reportReasons: reportReasons,
                ),
              ),
            );
          },
        );
        list.add(l);
      }
      return Expanded(
          child: RefreshIndicator(
        onRefresh: () async {
          updateUI();
        },
        child: ListView(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          children: list,
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

  Widget listViewPostStatus(String status) {
    List<ListTile> list = [];
    for (Post post in postsState) {
      if (post.status == status) {
        var l = ListTile(
          // tileColor: c.colorListTile(i),
          contentPadding: const EdgeInsets.only(
              top: 5.0, left: 15.0, right: 10.0, bottom: 5.0),
          leading: (post.user!.img != null
              ? GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    var tempData = await Review.getReviews(
                        prefs.getString('jwt') ?? "", post.createdUserID!);
                    setState(() {
                      reviews = tempData![0] ?? [];
                      avgReview = globalData.avgDecimalPointFormat(tempData[1]);
                    });
                    User? u = post.user;
                    u!.id = post.createdUserID;
                    showDetailReview(u);
                  },
                  child: CircleAvatar(
                    maxRadius: 30,
                    child: ClipOval(
                      child: Image.network(
                          "${globals.protocol}${globals.serverIP}/profiles/${post.user!.img}",
                          fit: BoxFit.cover),
                    ),
                  ),
                )
              : null),
          // tileColor: Colors.amberAccent,
          title: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.pin_drop,
                    color: Colors.red,
                  ),
                  Flexible(
                    child: Text(
                      "${post.startName}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.golf_course,
                    color: Colors.green,
                  ),
                  Flexible(
                    child: Text(
                      "${post.endName}",
                      // textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.alarm,
                    color: Colors.orange,
                  ),
                  Text(globalData.dateTimeFormatForPost(post.dateTimeStart)),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.airline_seat_recline_normal,
                    color: colorSeat(
                        post.countPostMember!, post.postDetail!.seat!),
                  ),
                  Text(
                    "${post.countPostMember}/${post.postDetail!.seat}",
                    // style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
          trailing: Text("${post.postDetail!.price}"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(
                  user: user,
                  isAdd: false,
                  isback: post.isBack,
                  post: post,
                  isView: true,
                  reportReasons: reportReasons,
                ),
              ),
            );
          },
        );
        list.add(l);
      }
    }
    if (list.isNotEmpty) {
      return Expanded(
          child: RefreshIndicator(
        onRefresh: () async {
          updateUI();
        },
        child: ListView(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          children: list,
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
    return DefaultTabController(
      initialIndex: 0,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          backgroundColor: const Color.fromRGBO(233, 30, 99, 1),
          actions: [
            IconButton(
                onPressed: () {
                  showSettingHistory();
                },
                icon: const Icon(Icons.settings))
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              // unselectedLabelColor: Colors.black,
              tabs: [
                Tab(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: const Center(child: Text("All")))),
                Tab(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: const Center(child: Text("New")))),
                Tab(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: const Center(child: Text("In Progress")))),
                Tab(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: const Center(child: Text("Done")))),
                Tab(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 5,
                        child: const Center(child: Text("Cancel")))),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            (_isLoading ? listLoader() : listViewPostStatusALL()),
            (_isLoading ? listLoader() : listViewPostStatus("NEW")),
            (_isLoading ? listLoader() : listViewPostStatus("IN_PROGRESS")),
            (_isLoading ? listLoader() : listViewPostStatus("DONE")),
            (_isLoading ? listLoader() : listViewPostStatus("CANCEL")),
          ],
        ),
      ),
    );
  }

  void fillterPost() {
    if (settingMyPost && settingJoinPost) {
      setState(() {
        postsState = posts;
      });
    } else if (settingMyPost && !settingJoinPost) {
      List<Post> postTemp = [];
      for (Post p in posts) {
        if (p.createdUserID == user.id) {
          postTemp.add(p);
        }
      }
      setState(() {
        postsState = postTemp;
      });
    } else if (settingJoinPost && !settingMyPost) {
      List<Post> postTemp = [];
      for (Post p in posts) {
        if (p.createdUserID != user.id) {
          postTemp.add(p);
        }
      }
      setState(() {
        postsState = postTemp;
      });
    } else {
      setState(() {
        postsState = posts;
      });
    }
  }

  void updateUI() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();

    List<Post>? tempData =
        await Post.getPostsHistory(prefs.getString('jwt') ?? "");

    setState(() {
      posts = tempData ?? [];
      fillterPost();
      _isLoading = false;
    });
  }

  Color colorSeat(int postMember, int seat) {
    if (postMember / seat == 1) {
      return Colors.deepOrange;
    } else {
      return Colors.blue;
    }
  }

  List<ListTile> getListTileReviews() {
    List<ListTile> list = [];
    // int i = 0;
    for (Review review in reviews) {
      double score = review.score != null ? review.score!.toDouble() : 0.0;
      var l = ListTile(
        // tileColor: getColor.colorListTile(i),
        contentPadding:
            const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0, bottom: 5.0),
        leading: (CircleAvatar(
          maxRadius: 30,
          child: ClipOval(
            child: Image.network(
              "${globals.protocol}${globals.serverIP}/profiles/${review.user!.img}",
              fit: BoxFit.cover,
            ),
          ),
        )),
        // tileColor: getColor.colorListTile(i),
        title: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.pinkAccent,
                ),
                Text(
                  " ${review.user?.firstName} ${review.user?.lastName} ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                RatingBarIndicator(
                  rating: score,
                  itemCount: 5,
                  itemSize: 25,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.golf_course,
                  color: Colors.green,
                ),
                Flexible(
                  child: Text(
                    " ${review.post!.endName}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.alarm_rounded,
                  color: Colors.orange,
                ),
                Text(
                  " ${globalData.dateTimeFormatForPost(DateTime.now())}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.edit,
                  color: Colors.lightBlue,
                ),
                Text(
                  "  ${review.description}",
                ),
              ],
            ),
          ],
        ),
        // trailing: const Text("10"),
        // onTap: () {},
      );
      list.add(l);
    }

    return list;
  }

  void showDetailReview(User u) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Reviews'),
              // insetPadding: EdgeInsets.zero,

              insetPadding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 30, top: 30),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return SizedBox(
                  // color: Colors.white, // Dialog background
                  width: MediaQuery.of(context).size.width, // Dialog width
                  height:
                      MediaQuery.of(context).size.height - 200, // Dialog height
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            child: u.img != null
                                ? ClipOval(
                                    child: Image.network(
                                      "${globals.protocol}${globals.serverIP}/profiles/${u.img}",
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            "${u.firstName} ${u.lastName}",
                            style: const TextStyle(
                                fontSize: 28,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                          Text(
                            "${u.email}",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black),
                          ),
                          Text(
                            "${u.sex}",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black),
                          ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          Visibility(
                            // false ,hide chat if p.userID == userID
                            visible: !(u.id == null || u.id == user.id),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatDetailScreen(
                                                      showBackbt: false,
                                                      user: user,
                                                      chatDB: Chat(
                                                        chatType: "PRIVATE",
                                                        sendUserID: u.id,
                                                      ),
                                                    )));
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.message),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Chat",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ),
                          (reviews.isEmpty
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      SizedBox(height: 30),
                                      Text(
                                        "No review",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      )
                                    ])
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // crossAxisAlignment: CrossAxisAlignment.baseline,
                                  children: [
                                    RatingBarIndicator(
                                      rating: avgReview,
                                      itemCount: 5,
                                      itemSize: 25,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "$avgReview",
                                      style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
                        ],
                      ),
                      // SizedBox(
                      //   height: 30,
                      // ),
                      // Divider(
                      //   color: Colors.black,
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: getListTileReviews(),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close')),
              ],
            ));
    // await showGeneralDialog(
    //   context: context,
    //   pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
    //       backgroundColor: Colors.black87,
    //       body: Column(
    //         children: [],
    //       )),
    // );
  }

  void showSettingHistory() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 10),
                  Text('Setting')
                ],
              ),
              insetPadding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 30, top: 30),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Post",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 10),
                        Switch(
                            // splashRadius: 25,
                            value: settingMyPost,
                            onChanged: (value) {
                              setState(() {
                                settingMyPost = value;
                              });
                              if (settingMyPost == false &&
                                  settingJoinPost == false) {
                                setState(() {
                                  settingJoinPost = true;
                                });
                              }
                              fillterPost();
                            })
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Join Post",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 10),
                        Switch(
                            // splashRadius: 25,
                            value: settingJoinPost,
                            onChanged: (value) {
                              setState(() {
                                settingJoinPost = value;
                              });
                              if (settingMyPost == false &&
                                  settingJoinPost == false) {
                                setState(() {
                                  settingMyPost = true;
                                });
                              }
                              fillterPost();
                            })
                      ],
                    )
                  ],
                );
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close')),
              ],
            ));
  }

  Color? colorStatus(String status) {
    if (status == "NEW") {
      return Colors.green;
    } else if (status == "IN_PROGRESS") {
      return Colors.red;
    } else if (status == "DONE") {
      return Colors.red;
    } else {
      return Colors.red;
    }
  }

  // skeleton_loader
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
