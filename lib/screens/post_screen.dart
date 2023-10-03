// import 'package:car_pool_project/gobal_function/color.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:car_pool_project/gobal_function/data.dart';
import 'package:car_pool_project/models/chat_user_log.dart';
import 'package:car_pool_project/models/district.dart';
import 'package:car_pool_project/models/post.dart';
import 'package:car_pool_project/models/province.dart';
import 'package:car_pool_project/models/review.dart';
import 'package:car_pool_project/models/review_user_log.dart';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/screens/car_screen.dart';
import 'package:car_pool_project/screens/chat_screen.dart';
import 'package:car_pool_project/screens/history_screen.dart';
import 'package:car_pool_project/screens/post_detail_screen.dart';
import 'package:car_pool_project/screens/profile_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:car_pool_project/global.dart' as globals;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:badges/badges.dart' as badges;
import '../models/chat.dart';
import '../models/report_reason.dart';
import 'chat_detail_screen.dart';
import 'review_screen.dart';

class PostScreen extends StatefulWidget {
  final User user;
  // final Post? posts;

  const PostScreen({
    super.key,
    required this.user,
    // this.posts,
  });
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  User user = User();
  GlobalData globalData = GlobalData();
  bool _isLoading = true;
  Post? postDataSearch = Post();
  List<Post> posts = [];
  List<int> postIDKey = [];

  bool _isStartSearch = false;
  bool _isLogout = false;

  String _stateGoBack = "go";
  bool _isBackSearch = false;

  TextEditingController dateTimeController = TextEditingController();
  DateTime? datetimeSelected;
  TextEditingController dateTimeBackController = TextEditingController();
  DateTime? datetimeBackSelected;

  List<Province?> provinces = [];
  List<District?> districts = [];
  List<Province?> stateProvincesEnd = [];
  List<District?> stateDistrictsStart = [];
  List<District?> stateDistrictsEnd = [];

  bool _isSelectedProvinceStart = false;
  bool _isSelectedProvinceEnd = false;

  District allDistrict = District(
    id: 0,
    provinceID: 0,
    nameTH: "ทุกอำเภอ",
    nameEN: "All District",
  );

  Province? selectedProvinceStart;
  District? selectedDistrictStart;
  Province? selectedProvinceEnd;
  District? selectedDistrictEnd;

  final formKey = GlobalKey<FormState>();

  List<Review> reviews = [];
  double avgReview = 0.0;
  String chatNoti = "";
  String reviewNoti = "";
  // bool _isChat = false;

  // List<ReportReason> reportReasons = [];
  List<ReportReason> reportReasons = [];
  List<ReportReason> reportReasonsUser = [];
  List<ReportReason> reportReasonsReview = [];
  List<ReportReason> reportReasonsPost = [];

  ReportReason? reportReasonPost;
  ReportReason? reportReasonUser;
  ReportReason? reportReasonReview;

  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    user = (widget.user);
    setState(() {
      _isLoading = true;
    });
    getProvince();
    getDistrict();
    updateUI(); //loading posts
    updateChatNoti();
    updateReviewNoti();
    getReportReason();
    initSocketIO();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

// socket IO
  void initSocketIO() {
    String pathSocket = "${globals.webSocketProtocol}${globals.serverIP}/";
    socket = IO.io(
      pathSocket,
      OptionBuilder()
          .setTransports(['websocket'])
          .setPath("/api/socket_io")
          .build(),
    );
    socket.onConnect((_) {
      print('Connected Socket IO');
    });
    socket.on('user_${user.id}', (data) async {
      if (data == "Update_Noti") {
        updateChatNoti();
      } else if (data == "Update_Review") {
        updateReviewNoti();
      }
    });
    socket.on('server_post', (data) async {
      updatePost(data);
    });

    socket.onConnectError((data) => print("Connect Error $data"));
    socket.onDisconnect((data) => print("Disconnect"));
    // socket.on('message', (data) => print(data));
  }

  double potisionEndBadge() {
    if (chatNoti.length == 1) {
      return 4;
    } else if (chatNoti.length == 2) {
      return 2;
    } else if (chatNoti.length == 3) {
      return -2;
    }
    return 0;
  }

  List<Widget> appBarBt() {
    var bt = [
      // Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Row(
      //     children: [
      //       InkWell(
      //         onTap: () {},
      //         child: CircleAvatar(
      //           maxRadius: 20,
      //           child: user.img != null
      //               ? ClipOval(
      //                   child: Image.memory(
      //                     base64Decode(user.img!),
      //                     fit: BoxFit.cover,
      //                   ),
      //                 )
      //               : null,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      IconButton(
          onPressed: () async {
            // stateDistrictsStart.clear();
            // stateDistrictsEnd.clear();
            if (datetimeSelected != null) {
              dateTimeController.text =
                  globalData.dateTimeFormatForPost(datetimeSelected);
            }
            if (datetimeBackSelected != null && _isBackSearch) {
              dateTimeBackController.text =
                  globalData.dateTimeFormatForPost(datetimeBackSelected);
            }
            await showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text('Search'),
                      content: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // select dateitme
                              Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: RadioListTile(
                                        value: "go",
                                        groupValue: _stateGoBack,
                                        onChanged: ((value) {
                                          setState(() {
                                            _stateGoBack = value.toString();
                                            _isBackSearch = false;
                                            dateTimeBackController.text = "";
                                          });
                                        })),
                                  ),
                                  const Text("ไปอย่างเดียว"),
                                  SizedBox(
                                    width: 30,
                                    child: RadioListTile(
                                        value: "back",
                                        groupValue: _stateGoBack,
                                        onChanged: ((value) {
                                          setState(() {
                                            _stateGoBack = value.toString();
                                            _isBackSearch = true;
                                          });
                                        })),
                                  ),
                                  const Text("ไปและกลับ"),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      validator: MultiValidator([
                                        RequiredValidator(
                                            errorText: "Please Select DateTime")
                                      ]),
                                      showCursor: false,
                                      readOnly: true,
                                      focusNode:
                                          FocusNode(canRequestFocus: false),
                                      keyboardType: TextInputType.none,
                                      controller: dateTimeController,
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        DatePicker.showDateTimePicker(
                                          context,
                                          showTitleActions: true,
                                          minTime: DateTime.now(),
                                          currentTime: datetimeSelected !=
                                                      null &&
                                                  datetimeSelected!
                                                      .isAfter(DateTime.now())
                                              ? datetimeSelected
                                              : DateTime.now(),
                                          locale: LocaleType.th,
                                          onConfirm: (time) {
                                            if (datetimeBackSelected != null &&
                                                time.isAfter(
                                                    datetimeBackSelected!) &&
                                                _isBackSearch) {
                                              datetimeBackSelected = time;
                                              dateTimeBackController.text =
                                                  globalData
                                                      .dateTimeFormatForPost(
                                                          time);
                                            }
                                            datetimeSelected = time;
                                            dateTimeController.text = globalData
                                                .dateTimeFormatForPost(time);
                                          },
                                        );
                                      },
                                      decoration: InputDecoration(
                                          labelText: "เวลาเดินทาง",
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            // borderSide: BorderSide.none,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.schedule,
                                            color: Colors.pink,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Visibility(
                                  visible: _isBackSearch,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              validator: (String? str) {
                                                if (str!.isEmpty &&
                                                    _isBackSearch) {
                                                  return "Please Select DateTime Back";
                                                }
                                                return null;
                                              },
                                              showCursor: false,
                                              readOnly: true,
                                              focusNode: FocusNode(
                                                  canRequestFocus: false),
                                              keyboardType: TextInputType.none,
                                              controller:
                                                  dateTimeBackController,
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                DatePicker.showDateTimePicker(
                                                    context,
                                                    showTitleActions: true,
                                                    minTime: datetimeSelected ??
                                                        DateTime.now(),
                                                    currentTime: datetimeSelected !=
                                                                null &&
                                                            datetimeSelected!
                                                                .isAfter(
                                                                    DateTime
                                                                        .now())
                                                        ? datetimeSelected
                                                        : DateTime.now(),
                                                    locale: LocaleType.th,
                                                    onConfirm: (time) {
                                                  datetimeBackSelected = time;
                                                  dateTimeBackController.text =
                                                      globalData
                                                          .dateTimeFormatForPost(
                                                              time);
                                                });
                                              },
                                              decoration: InputDecoration(
                                                  labelText:
                                                      "เวลาเดินทางกลับ ทุกเวลา",
                                                  filled: true,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    // borderSide: BorderSide.none,
                                                  ),
                                                  prefixIcon: const Icon(
                                                    Icons.schedule,
                                                    color: Colors.pink,
                                                  )),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  )),
                              // Select provin end
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownSearch<Province?>(
                                      popupProps: const PopupProps.menu(
                                        showSearchBox: true,
                                        // showSelectedItems: true,
                                        // disabledItemFn: (String s) {
                                        //   return s.startsWith('I');
                                        // },
                                      ),
                                      validator: (p) {
                                        if (p == null) {
                                          return "Please Select Province Start";
                                        }
                                        return null;
                                      },
                                      selectedItem: selectedProvinceStart,
                                      items: provinces,
                                      itemAsString: (Province? p) {
                                        // selectedProvinceStart = p;
                                        return "${p!.nameTH.toString()} (${p.nameEN.toString()})";
                                      },
                                      dropdownDecoratorProps:
                                          const DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "จังหวัดต้นทาง",
                                          // hintText: "country in menu mode",
                                        ),
                                      ),
                                      onChanged: (Province? p) {
                                        selectedProvinceStart = p;
                                        // print(selectingDistrict.nameTH);
                                        stateDistrictsStart.clear();
                                        setState(() {
                                          selectedDistrictStart = allDistrict;
                                          stateDistrictsStart.add(allDistrict);
                                          _isSelectedProvinceStart = true;
                                        });
                                        for (var a in districts) {
                                          if (a!.provinceID == p!.id) {
                                            setState(() {
                                              stateDistrictsStart.add(a);
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                              // Select district start
                              Visibility(
                                visible: _isSelectedProvinceStart,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownSearch<District?>(
                                        popupProps: const PopupProps.menu(
                                          showSearchBox: true,
                                        ),
                                        validator: (p) {
                                          if (p == null) {
                                            return "Please Select District Start";
                                          }
                                          return null;
                                        },
                                        selectedItem: selectedDistrictStart,
                                        items: stateDistrictsStart,
                                        itemAsString: (District? d) {
                                          return "${d!.nameTH.toString()} (${d.nameEN.toString()}) ";
                                        },
                                        dropdownDecoratorProps:
                                            const DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            labelText: "อำเภอต้นทาง",
                                          ),
                                        ),
                                        onChanged: (District? d) {
                                          selectedDistrictStart = d;
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              // Select provin end
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownSearch<Province?>(
                                      popupProps: const PopupProps.menu(
                                        showSearchBox: true,
                                      ),
                                      validator: (p) {
                                        if (p == null) {
                                          return "Please Select Province End";
                                        }
                                        return null;
                                      },
                                      selectedItem: selectedProvinceEnd,
                                      items: stateProvincesEnd,
                                      itemAsString: (Province? p) {
                                        return "${p!.nameTH.toString()} (${p.nameEN.toString()})";
                                      },
                                      dropdownDecoratorProps:
                                          const DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "จังหวัดปลายทาง",
                                          // hintText: "country in menu mode",
                                        ),
                                      ),
                                      onChanged: (Province? p) {
                                        selectedProvinceEnd = p;
                                        stateDistrictsEnd.clear();
                                        if (p!.id != 0) {
                                          // print(selectingDistrict.nameTH);
                                          setState(() {
                                            _isSelectedProvinceEnd = true;
                                            selectedDistrictEnd = allDistrict;
                                            stateDistrictsEnd.add(allDistrict);
                                          });
                                          for (var a in districts) {
                                            if (a!.provinceID == p.id) {
                                              setState(() {
                                                stateDistrictsEnd.add(a);
                                              });
                                            }
                                          }
                                        } else {
                                          selectedDistrictEnd = allDistrict;
                                          setState(() {
                                            _isSelectedProvinceEnd = false;
                                          });
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                              // Select district end
                              Visibility(
                                visible: _isSelectedProvinceEnd,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownSearch<District?>(
                                        popupProps: const PopupProps.menu(
                                          showSearchBox: true,
                                        ),
                                        validator: (p) {
                                          if (p == null) {
                                            return "Please Select District End";
                                          }
                                          return null;
                                        },
                                        selectedItem: selectedDistrictEnd,
                                        items: stateDistrictsEnd,
                                        itemAsString: (District? d) {
                                          return "${d!.nameTH.toString()} (${d.nameEN.toString()})";
                                        },
                                        dropdownDecoratorProps:
                                            const DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            labelText: "อำเภอปลายทาง",
                                          ),
                                        ),
                                        // selectedItem: District(nameTH: "ทุกอำเภอ"),
                                        onChanged: (District? d) {
                                          selectedDistrictEnd = d;
                                        },
                                      ),
                                    )
                                  ],
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
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              _isStartSearch = true;
                              Navigator.pop(context);
                              updateUI();
                            }
                          },
                          child: const Text('Search'),
                        ),
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
          },
          icon: const Icon(Icons.search)),
      // Chat
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          badges.Badge(
            position: badges.BadgePosition.custom(end: -2),
            showBadge: chatNoti != "",
            ignorePointer: false,
            badgeContent: Text(
              chatNoti,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            badgeAnimation: const badges.BadgeAnimation.rotation(
              animationDuration: Duration(seconds: 1),
              colorChangeAnimationDuration: Duration(seconds: 1),
              loopAnimation: false,
              curve: Curves.fastOutSlowIn,
              colorChangeAnimationCurve: Curves.easeInCubic,
            ),
            badgeStyle: const badges.BadgeStyle(
              // shape: badges.BadgeShape.square,
              // badgeColor: Colors.blue,
              // padding: const EdgeInsets.all(5),
              // borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.white, width: 1),
            ),
            child: IconButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                            user: user,
                          )),
                );
              },
              icon: const Icon(Icons.message),
            ),
          ),
        ],
      ),
    ];
    return bt;
  }

  List<ListTile> getListTile() {
    List<ListTile> list = [];
    for (var post in posts) {
      var l = ListTile(
        // tileColor: c.colorListTile(i),
        contentPadding: const EdgeInsets.only(
            top: 5.0, left: 15.0, right: 10.0, bottom: 5.0),
        leading: (post.user!.img != null
            ? GestureDetector(
                onTap: () async {
                  var tempData = await Review.getReviews(post.createdUserID!);
                  setState(() {
                    reviews = tempData![0] ?? [];
                    avgReview = globalData.avgDecimalPointFormat(tempData[1]);
                  });
                  User? u = post.user;
                  u?.id = post.createdUserID;
                  showDetailReview(u!);
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
        // subtitle: Column(
        //   children: [],
        // ),
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
                reportReasons: reportReasons,
              ),
            ),
          );
        },
      );
      // i++;
      list.add(l);
    }

    return list;
  }

  Widget listView() {
    if (posts.isNotEmpty) {
      return Expanded(
          child: RefreshIndicator(
        onRefresh: () async {
          updateUI();
          updateChatNoti();
          updateReviewNoti();
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
    return WillPopScope(
      onWillPop: () async {
        return _isLogout;
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Posts"),
            backgroundColor: Colors.pink,
            actions: appBarBt(),
            leading: Builder(builder: (BuildContext context) {
              // return IconButton(
              //     onPressed: () {
              //       Scaffold.of(context).openDrawer();
              //     },
              //     icon: const Icon(Icons.menu));
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  badges.Badge(
                    position: badges.BadgePosition.custom(top: 3, start: 0),
                    showBadge: reviewNoti != "",
                    // ignorePointer: true,
                    badgeContent: Text(
                      reviewNoti,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    badgeAnimation: const badges.BadgeAnimation.rotation(
                      animationDuration: Duration(seconds: 1),
                      colorChangeAnimationDuration: Duration(seconds: 1),
                      loopAnimation: false,
                      curve: Curves.fastOutSlowIn,
                      colorChangeAnimationCurve: Curves.easeInCubic,
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      borderSide: BorderSide(color: Colors.white, width: 1),
                    ),
                    child: IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: const Icon(
                          Icons.menu,
                          // size: 30,
                        )),
                  ),
                ],
              );
            }),
          ),
          // sidebar
          drawer: sideBar(),
          body: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              (_isLoading ? listLoader() : listView()),
            ],
          )),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PostDetailScreen(
                          isAdd: true,
                          user: user,
                          post: Post(),
                          reportReasons: reportReasons,
                        )),
              );
            },
            backgroundColor: Colors.pink,
            child: const Icon(Icons.add),
          )),
    );
  }

  Drawer sideBar() {
    return Drawer(
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.pink,
            padding: EdgeInsets.only(
              top: 24 + MediaQuery.of(context).padding.top,
              bottom: 24,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  child: ClipOval(
                    child: Image.network(
                      "${globals.protocol}${globals.serverIP}/profiles/${user.img!}",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  "${user.firstName} ${user.lastName}",
                  style: const TextStyle(fontSize: 28, color: Colors.white),
                ),
                Text(
                  "${user.email}",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: Wrap(
              runSpacing: 16,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Profile"),
                  onTap: () async {
                    Navigator.pop(context);
                    User? u = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                                user: user,
                              )),
                    );
                    if (u != null) {
                      setState(() {
                        user = u;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text("My Cars"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CarScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("History"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryScreen(
                                user: user,
                                reportReasons: reportReasons,
                              )),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.reviews),
                  title: const Text("Review"),
                  trailing: reviewNoti != ""
                      ? CircleAvatar(
                          radius: 9.5,
                          backgroundColor: Colors.red,
                          child: Text(
                            reviewNoti,
                            style: const TextStyle(color: Colors.white),
                          ))
                      : null,
                  onTap: () async {
                    Navigator.pop(context);
                    int? reviewLog = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReviewScreen(
                                user: user,
                                reportReasons: reportReasons,
                              )),
                    );
                    if (reviewLog != null && reviewLog != 0) {
                      setState(() {
                        reviewNoti = "$reviewLog";
                      });
                    } else {
                      setState(() {
                        reviewNoti = "";
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("help"),
                  onTap: () {},
                ),
                const Divider(
                  color: Colors.black,
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Logout"),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.clear();
                    setState(() {
                      _isLogout = true;
                    });
                    Navigator.pop(context);
                    Navigator.pop(context);
                    // Navigator.pushReplacement(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => const LoginScreen(),
                    //     ));
                  },
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  void updateChatNoti() async {
    int? tempData = await ChatUserLog.getCountChatUserLog();
    if (tempData != null) {
      setState(() {
        if (tempData > 99) {
          chatNoti = "99+";
        } else if (tempData > 0) {
          chatNoti = "$tempData";
        } else {
          chatNoti = "";
        }
      });
    }
  }

  void updateReviewNoti() async {
    int? tempData = await ReviewUserLog.getCountReviewUserLog();
    if (tempData != null) {
      setState(() {
        if (tempData > 99) {
          reviewNoti = "99+";
        } else if (tempData > 0) {
          reviewNoti = "$tempData";
        } else {
          reviewNoti = "";
        }
      });
    }
  }

  void getProvince() async {
    List<Province>? tempDataProvinces = await Province.getProvinces();
    provinces = tempDataProvinces ?? [];
    stateProvincesEnd
        .add(Province(id: 0, nameTH: "ทุกจังหวัด", nameEN: "All Province"));
    stateProvincesEnd = List.from(stateProvincesEnd)..addAll(provinces);
  }

  void getDistrict() async {
    List<District>? tempDataDistricts = await District.getDistricts();
    districts = tempDataDistricts ?? [];
  }

  void updateUI() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();

    int startProvinceID =
        selectedProvinceStart?.id ?? prefs.getInt("start_province_id") ?? 35;
    int startDistrictID = selectedDistrictStart?.id ?? 0;
    int endProvinceID = selectedProvinceEnd?.id ?? 0;
    int endDistrictID = selectedDistrictEnd?.id ?? 0;
    bool? dataIsback;
    if (_isStartSearch) {
      dataIsback = _isBackSearch;
    }
    postDataSearch = Post(
      startProvinceID: startProvinceID,
      startDistrictID: startDistrictID,
      endProvinceID: endProvinceID,
      endDistrictID: endDistrictID,
      dateTimeStart: datetimeSelected,
      dateTimeBack: datetimeBackSelected,
      isBack: dataIsback,
    );
    List<Post>? tempData = await Post.getPosts(postDataSearch!);

    setState(() {
      posts = tempData ?? [];
      _isLoading = false;
    });
  }

  void getReportReason() async {
    List<ReportReason>? tempData = await ReportReason.getReportReasons();
    if (tempData != null) {
      reportReasons = tempData;
      for (var r in reportReasons) {
        if (r.type == "ALL") {
          reportReasonsPost.add(r);
          reportReasonsUser.add(r);
          reportReasonsReview.add(r);
          reportReasonPost = r;
          reportReasonUser = r;
          reportReasonReview = r;
        } else if (r.type == "POST") {
          reportReasonsPost.add(r);
          reportReasonPost = r;
        } else if (r.type == "USER") {
          reportReasonsUser.add(r);
          reportReasonUser = r;
        } else if (r.type == "REVIEW") {
          reportReasonsReview.add(r);
          reportReasonReview = r;
        }
      }
    }
  }

  void updatePost(data) async {
    try {
      int tempID = int.parse(data);
      if (postIDKey.contains(tempID)) {
        Post? tempData = await Post.getPostByID(tempID);
        for (Post post in posts) {
          if (post.id == tempData!.id) {
            setState(() {
              post = tempData;
            });
            break;
          }
        }
      }
    } catch (err) {
      print(err);
    }
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
                // RatingBar.builder(
                //   initialRating: 1,
                //   minRating: 1,
                //   direction: Axis.horizontal,
                //   allowHalfRating: true,
                //   itemCount: 5,
                //   itemPadding:
                //       EdgeInsets.symmetric(horizontal: 0.3, vertical: 0.2),
                //   itemBuilder: (context, _) => Icon(
                //     Icons.star,
                //     color: Colors.amber,
                //   ),
                //   onRatingUpdate: (rating) {
                //     print(rating);
                //   },
                // ),
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
