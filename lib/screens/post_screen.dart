import 'package:car_pool_project/gobal_function/color.dart';
import 'package:car_pool_project/gobal_function/data.dart';
import 'package:car_pool_project/models/district.dart';
import 'package:car_pool_project/models/post.dart';
import 'package:car_pool_project/models/province.dart';
import 'package:car_pool_project/models/review.dart';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/screens/car_screen.dart';
import 'package:car_pool_project/screens/chat_screen.dart';
import 'package:car_pool_project/screens/post_detail_screen.dart';
import 'package:car_pool_project/screens/profile_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:car_pool_project/global.dart' as globals;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

import 'chat_detail_screen.dart';

class PostScreen extends StatefulWidget {
  final User? user;
  final Post? posts;

  const PostScreen({
    super.key,
    this.user,
    this.posts,
  });
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  User user = User();
  GlobalData globalData = GlobalData();

  bool _isLoading = true;
  List<Post> posts = [];
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

  int? provinceStartID = 0;
  int? districtStartID = 0;
  bool _isSelectedProvinceStart = false;
  int? provinceEndtID = 0;
  int? districtEndID = 0;
  bool _isSelectedProvinceEnd = false;

  List<Review> reviews = [];
  double avgReview = 0.0;

  String chatNoti = "";
  // bool _isChat = false;

  @override
  void initState() {
    super.initState();
    user = (widget.user)!;
    setState(() {
      _isLoading = true;
    });
    getProvince();
    getDistrict();
    updateUI(); //loading posts
    initSocketIO();
  }

// socket IO
  void initSocketIO() async {
    String pathSocket = "http://${globals.serverIP}/";
    IO.Socket socket = IO.io(
      pathSocket,
      OptionBuilder()
          .setTransports(['websocket'])
          .setPath("/api/socket/socket_io")
          .build(),
    );
    socket.onConnect((_) {
      print('Connected Socket IO');
    });
    socket.onConnectError((data) => print("Connect Error $data"));
    socket.onDisconnect((data) => print("Disconnect"));
    // socket.on('message', (data) => print(data));
  }

  // ListTile posts
  List<ListTile> getListTile() {
    List<ListTile> list = [];
    var c = GetColor();
    int i = 0;
    for (var post in posts) {
      var l = ListTile(
        tileColor: c.colorListTile(i),
        contentPadding: const EdgeInsets.only(
            top: 15.0, left: 15.0, right: 10.0, bottom: 5.0),
        leading: (post.img != null
            ? GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  var tempData = await Review.getReviews(
                      prefs.getString('jwt') ?? "", post.createdUserID!);
                  setState(() {
                    reviews = tempData![0] ?? [];
                    avgReview =
                        tempData[1] != null ? tempData[1].toDouble() : 0.0;
                  });
                  showDetailReview(post);
                },
                child: CircleAvatar(
                  maxRadius: 30,
                  child: ClipOval(
                    child: Image.network(
                        "http://${globals.serverIP}/profiles/${post.img!}",
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
                Text(dateTimeformat(post.dateTimeStart)),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.airline_seat_recline_normal,
                  color:
                      colorSeat(post.postMemberSeat!, post.postDetail!.seat!),
                ),
                Text(
                  "${post.postMemberSeat}/${post.postDetail!.seat}",
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
                userID: user.id,
                isAdd: false,
                isback: post.isBack,
                postID: post.id,
                dateTimeStart: post.dateTimeStart,
                dateTimeEnd: post.dateTimeBack,
                startName: post.startName,
                endName: post.endName,
                postStatus: post.status,
                postCreatedUserID: post.createdUserID,
                postUser: User(
                  id: post.createdUserID,
                  firstName: post.user?.firstName,
                  lastName: post.user?.lastName,
                  img: post.img,
                  sex: post.user?.sex,
                  email: post.user?.email,
                ),
              ),
            ),
          );
        },
      );
      i++;
      list.add(l);
    }

    return list;
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
            provinceStartID = 0;
            provinceEndtID = 0;
            districtStartID = 0;
            districtEndID = 0;
            setState(() {
              dateTimeBackController.text = "";
              dateTimeController.text = "";
              _isSelectedProvinceStart = false;
              _isSelectedProvinceEnd = false;
            });
            await showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                      title: const Text('Search'),
                      content: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Column(
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
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width / 2) +
                                          50,
                                  child: TextFormField(
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
                                        currentTime: DateTime.now(),
                                        locale: LocaleType.th,
                                        onConfirm: (time) {
                                          datetimeSelected = time;
                                          dateTimeController.text =
                                              dateTimeformat(time);
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
                                        SizedBox(
                                          width: (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2) +
                                              50,
                                          child: TextFormField(
                                            showCursor: false,
                                            readOnly: true,
                                            focusNode: FocusNode(
                                                canRequestFocus: false),
                                            keyboardType: TextInputType.none,
                                            controller: dateTimeBackController,
                                            onTap: () {
                                              FocusScope.of(context).unfocus();
                                              DatePicker.showDateTimePicker(
                                                context,
                                                showTitleActions: true,
                                                minTime: datetimeSelected ??
                                                    DateTime.now(),
                                                currentTime: datetimeSelected ??
                                                    DateTime.now(),
                                                locale: LocaleType.th,
                                                onConfirm: (time) {
                                                  datetimeBackSelected = time;
                                                  dateTimeBackController.text =
                                                      dateTimeformat(time);
                                                },
                                              );
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
                                    items: provinces,
                                    itemAsString: (Province? p) =>
                                        p!.nameTH.toString(),
                                    dropdownDecoratorProps:
                                        const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "จังหวัดต้นทาง",
                                        // hintText: "country in menu mode",
                                      ),
                                    ),
                                    onChanged: (Province? p) {
                                      stateDistrictsStart.clear();
                                      provinceStartID = p!.id;
                                      districtStartID = 0;
                                      District selectingDistrict = District(
                                          id: 0,
                                          provinceID: 0,
                                          nameTH: "ทุกอำเภอ");
                                      // print(selectingDistrict.nameTH);
                                      setState(() {
                                        stateDistrictsStart
                                            .add(selectingDistrict);
                                        _isSelectedProvinceStart = true;
                                      });
                                      for (var a in districts) {
                                        if (a!.provinceID == p.id) {
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
                                      items: stateDistrictsStart,
                                      itemAsString: (District? a) =>
                                          a!.nameTH.toString(),
                                      dropdownDecoratorProps:
                                          const DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "อำเภอต้นทาง",
                                        ),
                                      ),
                                      onChanged: (District? a) {
                                        districtStartID = a?.id;
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

                                      // showSelectedItems: true,
                                      // disabledItemFn: (String s) {
                                      //   return s.startsWith('I');
                                      // },
                                    ),
                                    items: stateProvincesEnd,
                                    itemAsString: (Province? p) =>
                                        p!.nameTH.toString(),
                                    dropdownDecoratorProps:
                                        const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "จังหวัดปลายทาง",
                                        // hintText: "country in menu mode",
                                      ),
                                    ),
                                    onChanged: (Province? p) {
                                      stateDistrictsEnd.clear();
                                      if (p!.id != 0) {
                                        provinceStartID = p.id;
                                        districtStartID = 0;

                                        District selectingDistrict = District(
                                            id: 0,
                                            provinceID: 0,
                                            nameTH: "ทุกอำเภอ");
                                        // print(selectingDistrict.nameTH);
                                        setState(() {
                                          _isSelectedProvinceEnd = true;
                                          stateDistrictsEnd
                                              .add(selectingDistrict);
                                        });
                                        for (var a in districts) {
                                          if (a!.provinceID == p.id) {
                                            setState(() {
                                              stateDistrictsEnd.add(a);
                                            });
                                          }
                                        }
                                      } else {
                                        _isSelectedProvinceEnd = true;
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
                                      items: stateDistrictsEnd,
                                      itemAsString: (District? a) =>
                                          a!.nameTH.toString(),
                                      dropdownDecoratorProps:
                                          const DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "อำเภอปลายทาง",
                                        ),
                                      ),
                                      // selectedItem: District(nameTH: "ทุกอำเภอ"),
                                      onChanged: (District? a) {
                                        districtStartID = a?.id;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
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

      Stack(
        children: [
          const Text(
            "",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              icon: const Icon(Icons.message)),
        ],
      ),

      // IconButton(
      //     onPressed: () async {
      //     },
      //     icon: const Icon(Icons.textsms_sharp)),
    ];
    return bt;
  }

  Widget listView() {
    if (posts.isNotEmpty) {
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
    return WillPopScope(
      onWillPop: () async {
        return _isLogout;
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Post"),
            backgroundColor: Colors.pink,
            actions: appBarBt(),
          ),
          // sidebar
          drawer: sideBar(),
          body: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              (_isLoading
                  ? listLoader()
                  : Container(
                      child: listView(),
                    )),
            ],
          )),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PostDetailScreen(
                          isAdd: true,
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
                      "http://${globals.serverIP}/profiles/${user.img!}",
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
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()),
                    );
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
                  onTap: () {},
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

  void getProvince() async {
    final prefs = await SharedPreferences.getInstance();
    List<Province>? tempDataProvinces =
        await Province.getProvinces(prefs.getString('jwt') ?? "");
    provinces = tempDataProvinces ?? [];
    stateProvincesEnd.add(Province(id: 0, nameTH: "ทุกจังหวัด"));
    stateProvincesEnd = List.from(stateProvincesEnd)..addAll(provinces);
  }

  void getDistrict() async {
    final prefs = await SharedPreferences.getInstance();
    List<District>? tempDataDistricts =
        await District.getDistricts(prefs.getString('jwt') ?? "");
    districts = tempDataDistricts ?? [];
  }

  void updateUI() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();

    provinceStartID = provinceStartID == 0
        ? prefs.getInt('start_province_id')
        : provinceStartID;
    String strDatetimeStart = datetimeSelected == null
        ? DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())
        : DateFormat("yyyy-MM-dd HH:mm:ss").format(datetimeSelected!);
    String strDatetimeEnd = datetimeBackSelected == null
        ? ""
        : DateFormat("yyyy-MM-dd HH:mm:ss").format(datetimeBackSelected!);
    bool isBack = datetimeBackSelected == null ? false : true;

    List<Post>? tempData = await Post.getPost(
      prefs.getString('jwt') ?? "", //token
      provinceStartID!,
      districtStartID!,
      provinceEndtID!,
      districtEndID!,
      strDatetimeStart,
      strDatetimeEnd,
      isBack,
    );
    setState(() {
      posts = tempData ?? [];
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

  String dateTimeformat(DateTime? time) {
    int mount = int.parse(DateFormat.M().format(time!));
    String dayWeek = DateFormat.E().format(time);
    // String dateTimeFormat =
    //     "${globalData.getDay(dayWeek)} ${time.day} ${globalData.getMonth(mount)} ${time.year}  ${DateFormat.Hm().format(time)}";
    String dateTimeFormat =
        "${globalData.getDay(dayWeek)} ${time.day} ${globalData.getMonth(mount)} ${DateFormat.Hm().format(time)}";
    return dateTimeFormat;
  }

  List<ListTile> getListTileReviews() {
    List<ListTile> list = [];
    // int i = 0;
    for (var review in reviews) {
      double score = review.score != null ? review.score!.toDouble() : 0.0;
      var l = ListTile(
        // tileColor: getColor.colorListTile(i),
        contentPadding:
            const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0, bottom: 5.0),
        leading: (CircleAvatar(
          maxRadius: 30,
          child: ClipOval(
            child: Image.network(
              "http://${globals.serverIP}/profiles/${review.img!}",
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
                  color: Colors.green,
                ),
                Text(
                  " ${review.user?.firstName} ${review.user?.lastName} ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                    " ${review.endName}",
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
                  " ${dateTimeformat(DateTime.now())}",
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

  void showDetailReview(Post p) async {
    await showDialog(
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
                            child: user.img != null
                                ? ClipOval(
                                    child: Image.network(
                                      "http://${globals.serverIP}/profiles/${p.img!}",
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            "${p.user?.firstName} ${p.user?.lastName}",
                            style: const TextStyle(
                                fontSize: 28,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                          Text(
                            "${p.user?.email}",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black),
                          ),
                          Text(
                            "${p.user?.sex}",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black),
                          ),
                          // const SizedBox(
                          //   height: 10,
                          // ),
                          Visibility(
                            // false ,hide chat if p.userID == userID
                            visible: !(p.createdUserID == user.id),
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
                                                      user: user,
                                                      sendToID: p.createdUserID,
                                                      chatType: "PRIVATE",
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
