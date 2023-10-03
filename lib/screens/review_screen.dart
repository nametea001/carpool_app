// import 'package:car_pool_project/gobal_function/color.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:car_pool_project/gobal_function/data.dart';
import 'package:car_pool_project/models/post.dart';
import 'package:car_pool_project/models/review.dart';
import 'package:car_pool_project/models/review_user_log.dart';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/screens/post_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:car_pool_project/global.dart' as globals;

import '../models/chat.dart';
import '../models/report_reason.dart';
import 'chat_detail_screen.dart';

class ReviewScreen extends StatefulWidget {
  final User user;
  final List<ReportReason> reportReasons;

  const ReviewScreen({
    super.key,
    required this.user,
    required this.reportReasons,
  });
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with SingleTickerProviderStateMixin {
  User user = User();
  GlobalData globalData = GlobalData();
  bool _isLoading = true;
  List<Review> reviewUserPost = [];
  List<Review> reviews = [];
  double avgReview = 0.0;
  // List<Post> posts = [];
  List<ReviewUserLog> reviewUserLogs = [];

  List<ReportReason> reportReasons = [];

  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  final FocusNode _focusNodeReviewDescription = FocusNode();
  final TextEditingController _descriptionController = TextEditingController();

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
    _tabController.dispose();
  }

  Widget listViewReview() {
    List<ListTile> list = [];
    for (ReviewUserLog reviewUserLog in reviewUserLogs) {
      Post? post = reviewUserLog.post;
      var l = ListTile(
        // tileColor: c.colorListTile(i),
        contentPadding: const EdgeInsets.only(
            top: 5.0, left: 15.0, right: 10.0, bottom: 5.0),
        leading: (post!.user!.img != null
            ? GestureDetector(
                onTap: () async {
                  var tempData = await Review.getReviews(post.createdUserID!);
                  setState(() {
                    reviewUserPost = tempData![0] ?? [];
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
                        "${globals.protocol}${globals.serverIP}/profiles/${post.user!.img!}",
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
                  color:
                      colorSeat(post.countPostMember!, post.postDetail!.seat!),
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
          showDetailReviewLog(reviewUserLog);
        },
      );
      // i++;
      list.add(l);
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
          // physics: BouncingScrollPhysics(),
          // physics: AlwaysScrollableScrollPhysics(),
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

  Widget listViewMyReview() {
    List<ListTile> list = [];
    for (Review r in reviews) {
      Post post = r.post!;
      var l = ListTile(
        // tileColor: c.colorListTile(i),
        contentPadding: const EdgeInsets.only(
            top: 5.0, left: 15.0, right: 10.0, bottom: 5.0),
        leading: (post.user!.img != null
            ? GestureDetector(
                onTap: () async {
                  var tempData = await Review.getReviews(post.createdUserID!);
                  setState(() {
                    reviewUserPost = tempData![0] ?? [];
                    avgReview =
                        tempData[1] != null ? tempData[1].toDouble() : 0.0;
                  });
                  User? u = post.user;
                  u!.id = post.createdUserID;
                  showDetailReview(u);
                },
                child: CircleAvatar(
                  maxRadius: 30,
                  child: ClipOval(
                    child: Image.network(
                        "${globals.protocol}${globals.serverIP}/profiles/${post.user!.img!}",
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
                  color:
                      colorSeat(post.countPostMember!, post.postDetail!.seat!),
                ),
                Text(
                  "${post.countPostMember}/${post.postDetail!.seat}",
                  // style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Row(
              children: [
                RatingBarIndicator(
                  rating: (r.score)!.toDouble(),
                  itemCount: 5,
                  itemSize: 25,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ],
            )
          ],
        ),
        // subtitle: Column(
        //   children: [],
        // ),
        trailing: Text("${post.postDetail!.price}"),
        onTap: () {
          showDetailMyReview(r);
        },
      );
      // i++;
      list.add(l);
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
          // physics: BouncingScrollPhysics(),
          // physics: AlwaysScrollableScrollPhysics(),
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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, reviewUserLogs.length);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text("Review"),
          backgroundColor: const Color.fromRGBO(233, 30, 99, 1),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              // unselectedLabelColor: Colors.black,
              tabs: [
                Tab(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2.4,
                        child: const Center(child: Text("Review")))),
                Tab(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2.4,
                        child: const Center(child: Text("My Score")))),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            (_isLoading ? listLoader() : listViewReview()),
            (_isLoading ? listLoader() : listViewMyReview()),
          ],
        ),
      ),
    );
  }

  void updateUI() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    var tempData = await Review.getMyReviews(prefs.getString('jwt') ?? "");
    if (tempData != null) {
      reviews = tempData[0];
      reviewUserLogs = tempData[1];
    }
    setState(() {
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

  void showDetailMyReview(Review r) {
    Post? post = r.post;
    User? u = r.post!.user;
    u!.id = post!.createdUserID;
    bool isOnEdit = false;
    bool stateMoreNameStart = false;
    bool stateMoreNameEnd = false;
    double ratingScore = 0;
    _descriptionController.text = r.description ?? "";
    ratingScore = r.score != null ? r.score!.toDouble() : 0;

    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Detail'),
              insetPadding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 30, top: 30),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return GestureDetector(
                  onTap: () {
                    _focusNodeReviewDescription.unfocus();
                  },
                  child: SizedBox(
                    // color: Colors.white, // Dialog background
                    width: MediaQuery.of(context).size.width, // Dialog width
                    height: MediaQuery.of(context).size.height -
                        200, // Dialog height
                    child: SingleChildScrollView(
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
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
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
                                        SizedBox(width: 10),
                                        Text("Chat")
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PostDetailScreen(
                                            user: user,
                                            isAdd: false,
                                            isback: post.isBack,
                                            post: post,
                                            reportReasons: reportReasons,
                                            // reportReasons: ,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.description),
                                        SizedBox(width: 10),
                                        Text("Detail")
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              // Text(p.)
                            ],
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      stateMoreNameStart = !stateMoreNameStart;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.pin_drop,
                                        color: Colors.red,
                                      ),
                                      Flexible(
                                        child: Text(
                                          "${post.startName}",
                                          overflow: stateMoreNameStart
                                              ? null
                                              : TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      stateMoreNameEnd = !stateMoreNameEnd;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.golf_course,
                                        color: Colors.green,
                                      ),
                                      Flexible(
                                        child: Text(
                                          "${post.endName}",
                                          // textAlign: TextAlign.justify,
                                          overflow: stateMoreNameEnd
                                              ? null
                                              : TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.alarm,
                                      color: Colors.orange,
                                    ),
                                    Text(globalData.dateTimeFormatForPost(
                                        post.dateTimeStart)),
                                    const SizedBox(width: 20),
                                    Icon(
                                      Icons.airline_seat_recline_normal,
                                      color: colorSeat(post.countPostMember!,
                                          post.postDetail!.seat!),
                                    ),
                                    Text(
                                      "${post.countPostMember}/${post.postDetail!.seat}",
                                      // style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                isOnEdit == false
                                    ? RatingBarIndicator(
                                        rating: ratingScore,
                                        itemCount: 5,
                                        // itemSize: 5,
                                        direction: Axis.horizontal,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 0.3, vertical: 0.2),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                      )
                                    : RatingBar.builder(
                                        initialRating: ratingScore,
                                        minRating: 0,
                                        direction: Axis.horizontal,
                                        // allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 0.3, vertical: 0.2),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amberAccent,
                                        ),
                                        onRatingUpdate: (rating) {
                                          r.score = rating.toInt();
                                        },
                                      ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        onTap: () {
                                          if (!isOnEdit) {
                                            _focusNodeReviewDescription
                                                .unfocus();
                                          }
                                        },
                                        readOnly: !isOnEdit,
                                        focusNode: _focusNodeReviewDescription,
                                        controller: _descriptionController,
                                        maxLines: 3,
                                        onChanged: (value) {
                                          r.description = value;
                                        },
                                        decoration: InputDecoration(
                                            labelText: "ข้อความ",
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              // borderSide: BorderSide.none,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.edit_note,
                                              color: Colors.pink,
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: isOnEdit == false
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.amber),
                                              onPressed: () {
                                                setState(() {
                                                  isOnEdit = true;
                                                });
                                              },
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.edit_document),
                                                  SizedBox(width: 10),
                                                  Text("Edit")
                                                ],
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.green),
                                                  onPressed: () {
                                                    showConfirmEditReview(r);
                                                    // Navigator.pop(context);
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons
                                                          .check_circle_outline),
                                                      SizedBox(width: 10),
                                                      Text("Confirm")
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  onPressed: () {
                                                    _descriptionController
                                                            .text =
                                                        r.description ?? "";
                                                    _focusNodeReviewDescription
                                                        .unfocus();
                                                    setState(() {
                                                      ratingScore =
                                                          r.score!.toDouble();
                                                      isOnEdit = false;
                                                    });
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons
                                                          .cancel_outlined),
                                                      SizedBox(width: 10),
                                                      Text("Cancel")
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
  }

  void showDetailReviewLog(ReviewUserLog reviewUserLog) {
    Post? post = reviewUserLog.post;
    User? u = post!.user;
    u!.id = post.createdUserID;
    double ratingScore = 0;
    bool stateMoreNameStart = false;
    bool stateMoreNameEnd = false;
    Review review = Review(
      postID: post.id,
      userID: post.createdUserID,
      score: 0,
      description: "",
    );
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Review'),
              insetPadding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 30, top: 30),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return GestureDetector(
                  onTap: () {
                    _focusNodeReviewDescription.unfocus();
                  },
                  child: SizedBox(
                    // color: Colors.white, // Dialog background
                    width: MediaQuery.of(context).size.width, // Dialog width
                    height: MediaQuery.of(context).size.height -
                        200, // Dialog height
                    child: SingleChildScrollView(
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
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
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
                                        SizedBox(width: 10),
                                        Text("Chat")
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PostDetailScreen(
                                            user: user,
                                            isAdd: false,
                                            isback: post.isBack,
                                            post: post,
                                            reportReasons: reportReasons,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(Icons.description),
                                        SizedBox(width: 10),
                                        Text("Detail")
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              // Text(p.)
                            ],
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      stateMoreNameStart = !stateMoreNameStart;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.pin_drop,
                                        color: Colors.red,
                                      ),
                                      Flexible(
                                        child: Text(
                                          "${post.startName}",
                                          overflow: stateMoreNameStart
                                              ? null
                                              : TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      stateMoreNameEnd = !stateMoreNameEnd;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.golf_course,
                                        color: Colors.green,
                                      ),
                                      Flexible(
                                        child: Text(
                                          "${post.endName}",
                                          // textAlign: TextAlign.justify,
                                          overflow: stateMoreNameEnd
                                              ? null
                                              : TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.alarm,
                                      color: Colors.orange,
                                    ),
                                    Text(globalData.dateTimeFormatForPost(
                                        post.dateTimeStart)),
                                    const SizedBox(width: 20),
                                    Icon(
                                      Icons.airline_seat_recline_normal,
                                      color: colorSeat(post.countPostMember!,
                                          post.postDetail!.seat!),
                                    ),
                                    Text(
                                      "${post.countPostMember}/${post.postDetail!.seat}",
                                      // style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                RatingBar.builder(
                                  initialRating: ratingScore,
                                  direction: Axis.horizontal,
                                  // allowHalfRating: true,
                                  itemCount: 5,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 0.3, vertical: 0.2),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amberAccent,
                                  ),
                                  onRatingUpdate: (rating) {
                                    review.score = rating.toInt();
                                    // print(rating);
                                  },
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        // autofocus: true,
                                        focusNode: _focusNodeReviewDescription,
                                        // controller: _descriptionController,
                                        maxLines: 3,
                                        onChanged: (value) {
                                          review.description = value;
                                        },
                                        decoration: InputDecoration(
                                            labelText: "ข้อความ",
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              // borderSide: BorderSide.none,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.edit_note,
                                              color: Colors.pink,
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      onPressed: () {
                                        showConfirmReview(
                                            reviewUserLog.id!, review);
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.check_circle_outline),
                                          SizedBox(width: 10),
                                          Text("Review")
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
  }

  void showConfirmEditReview(Review review) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Edit Review'),
        content: const Text("ยืนยันการแก้่ไข"),
        actions: [
          TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                Review? tempData = await Review.editMyReview(
                    prefs.getString('jwt') ?? "", review);
                if (tempData != null) {
                  for (Review r in reviews) {
                    if (r.id == tempData.id) {
                      setState(() {
                        r = tempData;
                      });
                      break;
                    }
                  }
                }
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Confirm')),
          TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  void showConfirmReview(int reviewUserLogID, Review r) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Review'),
        content: const Text("ยืนยันการรีวิว"),
        actions: [
          TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                Navigator.pop(context);
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                Review? tempData = await Review.addReview(
                    prefs.getString('jwt') ?? "", reviewUserLogID, r);
                if (tempData != null) {
                  reviewUserLogs
                      .removeWhere((r) => r.post!.id! == tempData.post!.id);
                  setState(() {
                    reviewUserLogs = reviewUserLogs;
                    reviews.insert(0, tempData);
                  });
                  _tabController.animateTo(1);
                }
              },
              child: const Text('Confirm')),
          TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  List<ListTile> getListTileReviews() {
    List<ListTile> list = [];
    // int i = 0;
    for (Review review in reviewUserPost) {
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
                          (reviewUserPost.isEmpty
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
