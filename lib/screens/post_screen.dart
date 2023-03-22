import 'dart:convert';
import 'package:car_pool_project/gobal_function/data.dart';
import 'package:car_pool_project/models/aumphure.dart';
import 'package:car_pool_project/models/post.dart';
import 'package:car_pool_project/models/province.dart';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/screens/post_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

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
  GlobalData globalData = new GlobalData();

  bool _isLoading = true;
  List<Post> posts = [];
  bool _isLogout = false;

  String _stateGoBack = "go";
  bool _isBackSearch = false;

  TextEditingController dateTimeController = TextEditingController();
  String stateDatetimeSelected = "";
  DateTime? datetimeSelected;
  TextEditingController dateTimeBackController = TextEditingController();
  String stateDatetimeBackSelected = "";
  DateTime? datetimeBackSelected;

  List<Province?> provinces = [];
  List<Aumphure?> aumphures = [];
  List<Province?> stateProvincesEnd = [];
  List<Aumphure?> stateAumphures = [];

  int? provinceStartID = 0;
  int? aumphureStartID = 0;
  bool _isSelectedProvinceStart = false;
  int? provinceEndtID = 0;
  int? aumphureEndID = 0;
  bool _isSelectedProvinceEnd = false;

  @override
  void initState() {
    super.initState();
    user = (widget.user)!;
    setState(() {
      _isLoading = true;
    });
    getProvince();
    getAumphure();
    updateUI(); //loading posts
  }

  // ListTile posts
  List<ListTile> getListTile() {
    List<ListTile> list = [];
    for (var post in posts) {
      var l = ListTile(
        contentPadding: const EdgeInsets.only(
            top: 15.0, left: 15.0, right: 10.0, bottom: 5.0),
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
                const Icon(
                  Icons.pin_drop,
                  color: Colors.red,
                ),
                Text(
                  "${post.startAmphireName} ${post.startProvinceName}",
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
                Text(
                  "${post.endAmphireName} ${post.endProvinceName}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        subtitle: const Text("sub test"),
        trailing: const Text("test trail"),
        onTap: () {},
      );
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
            stateAumphures = [];
            stateAumphures = [];
            provinceStartID = 0;
            provinceEndtID = 0;
            aumphureStartID = 0;
            aumphureEndID = 0;
            setState(() {
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
                                          datetimeBackSelected = null;
                                          stateDatetimeBackSelected = "";
                                          dateTimeBackController.text =
                                              stateDatetimeBackSelected;
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
                                          int m = int.parse(DateFormat.M()
                                              .format(datetimeSelected!));
                                          String dw = DateFormat.E()
                                              .format(datetimeSelected!);
                                          stateDatetimeSelected =
                                              "${globalData.getDay(dw)} ${datetimeSelected!.day} ${globalData.getMonth(m)} ${datetimeSelected!.year}  ${DateFormat.Hm().format(datetimeSelected!)}";
                                          dateTimeController.text =
                                              stateDatetimeSelected;
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
                                                  int m = int.parse(
                                                      DateFormat.M().format(
                                                          datetimeBackSelected!));
                                                  String dw = DateFormat.E()
                                                      .format(
                                                          datetimeBackSelected!);
                                                  stateDatetimeBackSelected =
                                                      "${globalData.getDay(dw)} ${datetimeSelected!.day} ${globalData.getMonth(m)} ${datetimeSelected!.year}  ${DateFormat.Hm().format(datetimeSelected!)}";
                                                  dateTimeBackController.text =
                                                      stateDatetimeSelected;
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
                                      stateAumphures.clear();
                                      provinceStartID = p!.id;
                                      aumphureStartID = 0;
                                      Aumphure selectingAumphure = Aumphure(
                                          id: 0,
                                          provinceID: 0,
                                          nameTH: "ทุกอำเภอ");
                                      // print(selectingAumphure.nameTH);
                                      setState(() {
                                        stateAumphures.add(selectingAumphure);
                                        _isSelectedProvinceEnd = true;
                                      });
                                      aumphures.forEach((a) {
                                        if (a!.provinceID == p.id) {
                                          setState(() {
                                            stateAumphures.add(a);
                                          });
                                        }
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                            Visibility(
                              visible: _isSelectedProvinceStart,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DropdownSearch<Aumphure?>(
                                      popupProps: const PopupProps.menu(
                                        showSearchBox: true,
                                      ),
                                      items: stateAumphures,
                                      itemAsString: (Aumphure? a) =>
                                          a!.nameTH.toString(),
                                      dropdownDecoratorProps:
                                          const DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "อำเภอต้นทาง",
                                        ),
                                      ),
                                      onChanged: (Aumphure? a) {
                                        aumphureStartID = a?.id;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
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
                                      stateAumphures.clear();
                                      if (p!.id != 0) {
                                        provinceStartID = p.id;
                                        aumphureStartID = 0;
                                      }
                                      Aumphure selectingAumphure = Aumphure(
                                          id: 0,
                                          provinceID: 0,
                                          nameTH: "ทุกอำเภอ");
                                      // print(selectingAumphure.nameTH);
                                      setState(() {
                                        _isSelectedProvinceEnd = true;
                                        stateAumphures.add(selectingAumphure);
                                      });
                                      aumphures.forEach((a) {
                                        if (a!.provinceID == p.id) {
                                          setState(() {
                                            stateAumphures.add(a);
                                          });
                                        }
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                            Visibility(
                              visible: _isSelectedProvinceEnd,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DropdownSearch<Aumphure?>(
                                      popupProps: const PopupProps.menu(
                                        showSearchBox: true,
                                      ),
                                      items: stateAumphures,
                                      itemAsString: (Aumphure? a) =>
                                          a!.nameTH.toString(),
                                      dropdownDecoratorProps:
                                          const DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "อำเภอปลายทาง",
                                        ),
                                      ),
                                      // selectedItem: Aumphure(nameTH: "ทุกอำเภอ"),
                                      onChanged: (Aumphure? a) {
                                        aumphureStartID = a?.id;
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
                          child: const Text('Search'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                            child: const Text('Close'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blueGrey,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    ));
          },
          icon: const Icon(Icons.search)),
    ];
    return bt;
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
          drawer: Drawer(
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
                        child: user.img != null
                            ? ClipOval(
                                child: Image.memory(
                                  base64Decode(user.img!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "${user.firstName} ${user.lastName}",
                        style:
                            const TextStyle(fontSize: 28, color: Colors.white),
                      ),
                      Text(
                        "${user.email}",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
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
                        onTap: () {},
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
                        onTap: () {
                          setState(() {
                            _isLogout = true;
                          });
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )),
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
                          physics: const BouncingScrollPhysics(),
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
                MaterialPageRoute(
                    builder: (context) => const PostDetailScreen()),
              );
            },
            child: const Icon(Icons.add),
            backgroundColor: Colors.pink,
          )),
    );
  }

  getProvince() async {
    List<Province>? tempDataProvinces =
        await Province.getProvince(user.username!);
    provinces = tempDataProvinces ?? [];
    stateProvincesEnd.add(Province(id: 0, nameTH: "ทุกจังหวัด"));
    stateProvincesEnd = new List.from(stateProvincesEnd)..addAll(provinces);
  }

  getAumphure() async {
    List<Aumphure>? tempDataAumphures =
        await Aumphure.getAumphure(user.username!);
    aumphures = tempDataAumphures ?? [];
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
