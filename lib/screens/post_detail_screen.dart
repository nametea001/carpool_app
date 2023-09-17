// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:car_pool_project/models/district.dart';
import 'package:car_pool_project/models/post.dart';
import 'package:car_pool_project/models/post_detail.dart';
import 'package:car_pool_project/models/post_member.dart';
import 'package:car_pool_project/screens/car_screen.dart';
// import 'package:car_pool_project/models/province.dart';
// import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/screens/chat_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../gobal_function/data.dart';
import '../models/car.dart';
import '../models/chat.dart';
import '../models/user.dart';
import 'package:car_pool_project/global.dart' as globals;
import 'package:car_pool_project/models/review.dart' as re;
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PostDetailScreen extends StatefulWidget {
  final User user;
  final bool? isAdd;
  final bool? isView;
  final bool? isback;
  final Post post;

  const PostDetailScreen({
    super.key,
    required this.user,
    this.isAdd,
    this.isback,
    this.isView,
    required this.post,
  });
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  GlobalData globalData = GlobalData();
  bool _isAdd = false;
  bool _isView = false;
  bool _isLoadingAdd = false;
  bool _myLocationEnable = false;
  bool _showMarkerStartToEnd = true;
  String location1 = "Search Start";
  String location2 = "Search End";
  bool _isShowMoreLine = false;
  Position? userLocation;
  GoogleMapController? _mapController;
  // final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();
  // LatLng startLocation = LatLng(17.291925, 104.112884);
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(17.291925, 104.112884),
    zoom: 15,
  );

  // final bool _isShowmarker1 = false;
  // final bool _isShowmarker2 = false;
  LatLng marker1 = const LatLng(17.291925, 104.112884);
  LatLng marker2 = const LatLng(17.291925, 104.112884);

  Future<Position?> _getLocation() async {
    bool serviceEnabled = false;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions are permanently denied, we cannot request permissions.");
    }

    userLocation = await Geolocator.getCurrentPosition();
    return userLocation;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // selec back
  bool _isBack = false;
  String stateGoBack = "go";
  // input
  final formKey = GlobalKey<FormState>();
  // focuscontroll
  final FocusNode _focusNodeDescription = FocusNode();
  final FocusNode _focusNodeSeat = FocusNode();
  final FocusNode _focusNodePrice = FocusNode();
  final FocusNode _focusNodeBrand = FocusNode();
  final FocusNode _focusNodemodel = FocusNode();
  final FocusNode _focusNodeVRegistration = FocusNode();
  final FocusNode _focusNodeColor = FocusNode();
  // datetime control
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _dateTimeBackController = TextEditingController();
  final TextEditingController _seatController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _vehicleRegistrationController =
      TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  PostDetail? postDetailData = PostDetail();
  Post? postData = Post(startDistrictID: 0, endDistrictID: 0);
  // PostDetail? postDetailTemp = PostDetail();
  bool _isLoading = false;
  bool _isJoin = false;

  MapsRoutes route = MapsRoutes();
  DistanceCalculator distanceCalculator = DistanceCalculator();
  String totalDistance = 'No route';
  Post? post = Post();
  User user = User();
  User? postUser;

  List<Car>? cars = [];
  Car? car = Car();

  List<re.Review> reviews = [];
  double avgReview = 0.0;

  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    // postUser = widget.postUser ?? User();
    user = widget.user;
    _isAdd = widget.isAdd ?? false;
    _isView = widget.isView ?? false;
    stateGoBack = _isBack == false ? "go" : "back";
    post = widget.post;
    location1 = widget.post.startName ?? "Search Start";
    location2 = widget.post.endName ?? "Search End";
    if (_isAdd) {
      getCar();
    }
    updateUI();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNodeDescription.dispose();
    _focusNodeSeat.dispose();
    _focusNodePrice.dispose();
    _focusNodeBrand.dispose();
    _focusNodemodel.dispose();
    _focusNodeVRegistration.dispose();
    _focusNodeColor.dispose();
    _mapController?.dispose();
    _dateTimeBackController.dispose();
    _dateTimeController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    // route.routes.clear();
  }

// socket IO
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
      print('Connected Socket IO Chat Detail');
    });

    socket.on('server_post', (data) async {
      updatePostDettail(data);
    });
    socket.onConnectError((data) => print("Connect Error $data"));
    socket.onDisconnect((data) => print("Disconnect Chat Detail"));
    // socket.on('message', (data) => print(data));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNodeDescription.unfocus();
        _focusNodeSeat.unfocus();
        _focusNodePrice.unfocus();
        _focusNodeBrand.unfocus();
        _focusNodemodel.unfocus();
        _focusNodeVRegistration.unfocus();
        _focusNodeColor.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: (_isAdd ? const Text('Add ') : const Text('Detail')),
          backgroundColor: Colors.pink,
          // actions: [
          //   IconButton(
          //       onPressed: () async {
          //         print(_isLoadingAdd);
          //         setState(() {
          //           _isLoadingAdd = !_isLoadingAdd;
          //         });
          //       },
          //       icon: Icon(Icons.abc))
          // ],
        ),
        body: _isLoading
            ? _loadingDetail()
            : SingleChildScrollView(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // padding: EdgeInsets.only(left: 20, right: 20),
                    height: (MediaQuery.of(context).size.height / 2) - 30,
                    child: Stack(children: [
                      GoogleMap(
                        //Map widget from google_maps_flutter package
                        // zoomGesturesEnabled: false, //enable Zoom in, out on map
                        // gestureRecognizers: Set()
                        //   ..add(Factory<PanGestureRecognizer>(
                        //       () => PanGestureRecognizer())),
                        gestureRecognizers: {
                          Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer())
                        },
                        polylines: route.routes,
                        myLocationButtonEnabled: false,
                        myLocationEnabled: _myLocationEnable,
                        zoomControlsEnabled: true,
                        initialCameraPosition: _kGooglePlex,
                        mapType: MapType.normal, //map type
                        onMapCreated: _onMapCreated,
                        markers: (_showMarkerStartToEnd
                            ? {
                                Marker(
                                    draggable: false,
                                    markerId: const MarkerId("marker1"),
                                    position: marker1),
                                Marker(
                                    draggable: false,
                                    markerId: const MarkerId("marker2"),
                                    position: marker2),
                              }
                            : {
                                Marker(
                                    draggable: false,
                                    markerId: const MarkerId("marker2"),
                                    position: marker2),
                              }),
                      ),

                      //search autoconplete input
                      Column(
                        children: [
                          Row(
                            children: searchMapButton(),
                          ),
                        ],
                      ),
                    ]),
                  ),
                  Visibility(
                    visible: !_isAdd,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // button under map
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: InkWell(
                                onTap: () {},
                                child: Column(
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            _showMarkerStartToEnd = false;
                                            _myLocationEnable = true;
                                          });
                                          route.routes.clear();
                                          Position? l = await _getLocation();
                                          if (l != null) {
                                            LatLng latLngTemp =
                                                LatLng(l.latitude, l.longitude);
                                            // await _mapController?.animateCamera(
                                            //   CameraUpdate.newLatLngZoom(
                                            //       latLngTemp, 15),
                                            // );
                                            // await Future.delayed(
                                            //     const Duration(seconds: 2));
                                            await routeDraw(
                                                latLngTemp, marker2);
                                            updateCameraLocation(latLngTemp,
                                                marker2, _mapController!);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.my_location,
                                          size: 30,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: InkWell(
                                onTap: () {},
                                child: Column(
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            _showMarkerStartToEnd = true;
                                            _myLocationEnable = false;
                                          });
                                          route.routes.clear();
                                          // await Future.delayed(
                                          //     const Duration(seconds: 2));
                                          await routeDraw(marker1, marker2);
                                          await updateCameraLocation(marker1,
                                              marker2, _mapController!);
                                        },
                                        icon: const Icon(
                                          Icons.pin_drop,
                                          size: 30,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 25, left: 25),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: _isAdd,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: RadioListTile(
                                      value: "go",
                                      groupValue: stateGoBack,
                                      onChanged: ((value) {
                                        setState(() {
                                          stateGoBack = value.toString();
                                          _isBack = false;
                                          _dateTimeBackController.text = "";
                                          postData!.dateTimeBack = null;
                                        });
                                      })),
                                ),
                                const Text("ไปอย่างเดียว"),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width / 2) -
                                          140,
                                ),
                                SizedBox(
                                  width: 30,
                                  child: RadioListTile(
                                      value: "back",
                                      groupValue: stateGoBack,
                                      onChanged: ((value) {
                                        setState(() {
                                          stateGoBack = value.toString();
                                          _isBack = true;
                                        });
                                      })),
                                ),
                                const Text("ไปและกลับ"),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 50,
                                child: TextFormField(
                                  validator: MultiValidator([
                                    RequiredValidator(
                                        errorText: "Please Slect DateTime")
                                  ]),
                                  showCursor: false,
                                  readOnly: true,
                                  focusNode: FocusNode(canRequestFocus: false),
                                  keyboardType: TextInputType.none,
                                  controller: _dateTimeController,
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    if (_isAdd) {
                                      DatePicker.showDateTimePicker(
                                        context,
                                        showTitleActions: true,
                                        minTime: DateTime.now(),
                                        currentTime: DateTime.now(),
                                        locale: LocaleType.th,
                                        onConfirm: (time) {
                                          postData!.dateTimeStart = time;
                                          _dateTimeController.text = globalData
                                              .dateTimeFormatForPost(time);
                                        },
                                      );
                                    }
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
                          // time back
                          Visibility(
                              visible: _isBack,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                50,
                                        child: TextFormField(
                                          validator: (String? str) {
                                            if (str!.isEmpty && _isBack) {
                                              return "Please Select DateTime Back";
                                            }
                                            return null;
                                          },
                                          showCursor: false,
                                          readOnly: true,
                                          focusNode:
                                              FocusNode(canRequestFocus: false),
                                          keyboardType: TextInputType.none,
                                          controller: _dateTimeBackController,
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            if (_isAdd) {
                                              DatePicker.showDateTimePicker(
                                                context,
                                                showTitleActions: true,
                                                minTime:
                                                    postData!.dateTimeStart ??
                                                        DateTime.now(),
                                                currentTime:
                                                    postData!.dateTimeStart ??
                                                        DateTime.now(),
                                                locale: LocaleType.th,
                                                onConfirm: (time) {
                                                  postData!.dateTimeBack = time;
                                                  _dateTimeBackController.text =
                                                      globalData
                                                          .dateTimeFormatForPost(
                                                              time);
                                                },
                                              );
                                            }
                                          },
                                          decoration: InputDecoration(
                                              labelText: "เวลาเดินทางกลับ",
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
                                ],
                              )),

                          // seat and price
                          Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        30,
                                    child: TextFormField(
                                      onSaved: (newValue) {
                                        postDetailData!.seat =
                                            int.parse(newValue!);
                                      },
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return "Please input seat";
                                        }
                                        try {
                                          int.parse(value);
                                        } catch (err) {
                                          return "Please specify the correct";
                                        }
                                        return null;
                                      },
                                      // enabled: _isAdd,
                                      readOnly: !_isAdd,
                                      // showCursor: _isAdd,
                                      focusNode: _focusNodeSeat,
                                      controller: _seatController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {},
                                      onTap: () {
                                        if (!_isAdd) {
                                          _focusNodeSeat.unfocus();
                                        }
                                      },
                                      decoration: InputDecoration(
                                          labelText: "จำนวนที่นั่ง",
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            // borderSide: BorderSide.none,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.airline_seat_recline_normal,
                                            color: Colors.pink,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        30,
                                    child: TextFormField(
                                      onSaved: (newValue) {
                                        postDetailData!.price =
                                            double.parse(newValue!);
                                      },
                                      validator: (String? str) {
                                        if (str!.isEmpty) {
                                          return "Please input price";
                                        }
                                        if (int.parse(str) < 0) {
                                          return "Please input price more";
                                        }
                                        return null;
                                      },
                                      focusNode: _focusNodePrice,
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
                                      onTap: () {
                                        if (!_isAdd) {
                                          _focusNodePrice.unfocus();
                                        }
                                      },
                                      decoration: InputDecoration(
                                          labelText: "ราคาต่อที่นั่ง",
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            // borderSide: BorderSide.none,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.payment,
                                            color: Colors.pink,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // brand and model
                          Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        30,
                                    child: TextFormField(
                                      onSaved: (newValue) {
                                        postDetailData!.model = newValue;
                                      },
                                      validator: MultiValidator([
                                        RequiredValidator(
                                            errorText: "Please input model")
                                      ]),
                                      onTap: () {
                                        if (_isAdd) {
                                          selectCar();
                                        } else {
                                          _focusNodemodel.unfocus();
                                        }
                                      },
                                      // enabled: false,
                                      readOnly: true,
                                      showCursor: false,
                                      focusNode: _focusNodemodel,
                                      controller: _modelController,
                                      decoration: InputDecoration(
                                          labelText: "รุ่น",
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            // borderSide: BorderSide.none,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.directions_car,
                                            color: Colors.pink,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        30,
                                    child: TextFormField(
                                      onSaved: (newValue) {
                                        postDetailData!.brand = newValue;
                                      },
                                      validator: MultiValidator([
                                        RequiredValidator(
                                            errorText: "Please input brand")
                                      ]),
                                      onTap: () {
                                        if (_isAdd) {
                                          selectCar();
                                        } else {
                                          _focusNodeBrand.unfocus();
                                        }
                                      },
                                      readOnly: true,
                                      showCursor: false,
                                      focusNode: _focusNodeBrand,
                                      controller: _brandController,
                                      decoration: InputDecoration(
                                          labelText: "ยี่ห้อ",
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            // borderSide: BorderSide.none,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.car_crash,
                                            color: Colors.pink,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // brand and model
                          Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        30,
                                    child: TextFormField(
                                      onSaved: (newValue) {
                                        postDetailData!.vehicleRegistration =
                                            newValue;
                                      },
                                      validator: MultiValidator([
                                        RequiredValidator(
                                            errorText:
                                                "Please Input Vehicle Registration")
                                      ]),
                                      onTap: () {
                                        if (_isAdd) {
                                          selectCar();
                                        } else {
                                          _focusNodeVRegistration.unfocus();
                                        }
                                      },
                                      readOnly: true,
                                      showCursor: false,
                                      focusNode: _focusNodeVRegistration,
                                      controller:
                                          _vehicleRegistrationController,
                                      decoration: InputDecoration(
                                          labelText: "ทะเบียน",
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            // borderSide: BorderSide.none,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.font_download,
                                            color: Colors.pink,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        30,
                                    child: TextFormField(
                                      onSaved: (newValue) {
                                        postDetailData!.color = newValue;
                                      },
                                      validator: MultiValidator([
                                        RequiredValidator(
                                            errorText: "Please Input Color")
                                      ]),
                                      onTap: () {
                                        if (_isAdd) {
                                          selectCar();
                                        } else {
                                          _focusNodeColor.unfocus();
                                        }
                                      },
                                      readOnly: true,
                                      showCursor: false,
                                      focusNode: _focusNodeColor,
                                      controller: _colorController,
                                      decoration: InputDecoration(
                                          labelText: "สี",
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            // borderSide: BorderSide.none,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.palette,
                                            color: Colors.pink,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // description
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 50,
                                child: TextFormField(
                                  onSaved: (newValue) {
                                    if (newValue!.isEmpty) {
                                      postDetailData!.description = null;
                                    } else {
                                      postDetailData!.description = newValue;
                                    }
                                  },
                                  focusNode: _focusNodeDescription,
                                  controller: _descriptionController,
                                  onTap: () {
                                    if (!_isAdd) {
                                      _focusNodeDescription.unfocus();
                                    }
                                  },
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                      labelText: "รายระเอียดเพิ่มเติม",
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
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _isLoadingAdd
                              ? _loadingAddPost()
                              : Visibility(
                                  visible: _isAdd,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 70, right: 70),
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.pink,
                                      ),
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          if (postData!.startDistrictID == 0 ||
                                              postData!.endDistrictID == 0 ||
                                              postData!.endDistrictID == null ||
                                              postData!.startDistrictID ==
                                                  null) {
                                            showAlertSelecLocation();
                                          } else {
                                            formKey.currentState!.save();
                                            postData!.isBack = _isBack;
                                            // postData!.status = "NEW";
                                            showAlertAdd();
                                          }
                                        }
                                      },
                                      child: const Text(
                                        "ยืนยัน",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              var tempData = await re.Review.getReviews(
                                  prefs.getString('jwt') ?? "",
                                  post!.createdUserID!);
                              setState(() {
                                reviews = tempData![0] ?? [];
                                avgReview = tempData[1] != null
                                    ? tempData[1].toDouble()
                                    : 0.0;
                              });
                              showDetailReview(post!);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              // crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _isAdd
                                  ? []
                                  : [
                                      CircleAvatar(
                                        radius: 40,
                                        child: ClipOval(
                                          child: postUser != null
                                              ? Image.network(
                                                  "http://${globals.serverIP}/profiles/${postUser?.img}",
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        children: [
                                          Text(
                                            "${postUser?.firstName} ${postUser?.lastName}",
                                            style: const TextStyle(
                                                fontSize: 30,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "${postUser?.email}",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                          Text(
                                            "${postUser?.sex}",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        floatingActionButton: (_isAdd ? null : flotButton()),
      ),
    );
  }

  List<Widget> searchMapButton() {
    void searchMap(int searchNumber) async {
      Prediction? place = await PlacesAutocomplete.show(
          context: context,
          apiKey: globalData.googleApiKey(),
          mode: Mode.overlay,
          types: [],
          strictbounds: false,
          components: [Component(Component.country, 'th')],
          decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.white,
              ),
            ),
          ),
          //google_map_webservice package
          onError: (err) {
            print(err);
          });

      if (place != null) {
        //form google_maps_webservice package
        final plist = GoogleMapsPlaces(
          apiKey: globalData.googleApiKey(),
          apiHeaders: await const GoogleApiHeaders().getHeaders(),
          //from google_api_headers package
        );
        String placeid = place.placeId ?? "0";
        final detail = await plist.getDetailsByPlaceId(placeid);
        final geometry = detail.result.geometry!;
        final lat = geometry.location.lat;
        final lang = geometry.location.lng;
        var newlatlang = LatLng(lat, lang);
        // split address for district
        String name = detail.result.name;
        String district = detail.result.formattedAddress!;
        bool searchProvin = false;
        if (district.contains("District")) {
          district = district.split(" District")[0].split(", ")[1];
        } else if (district.contains("Amphoe")) {
          district = district.split("Amphoe ")[1].split(", ")[0];
        } else {
          searchProvin = true;
          district = name;
        }
        final prefs = await SharedPreferences.getInstance();
        int? tempDistrictID = 0;
        if (searchProvin == false) {
          District? tempDistrict = await District.getDistrictByNameEN(
              prefs.getString('jwt') ?? "", district);

          if (tempDistrict != null) {
            tempDistrictID = tempDistrict.id;
          }
        } else {
          District? tempDistrict = await District.getDistrictByProvinceNameEN(
              prefs.getString('jwt') ?? "", district);
          if (tempDistrict != null) {
            tempDistrictID = tempDistrict.id;
          }
        }

        if (searchNumber == 1) {
          postData!.startDistrictID = tempDistrictID;
          postData!.startName = name;
          postDetailData!.startLatLng = newlatlang;
          setState(() {
            location1 = place.description.toString();
            marker1 = newlatlang;
          });
        } else if (searchNumber == 2) {
          postData!.endDistrictID = tempDistrictID;
          postData!.endName = name;
          postDetailData!.endLatLng = newlatlang;
          setState(() {
            location2 = place.description.toString();
            marker2 = newlatlang;
          });
        }
        //move map camera to selected place with animation
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: newlatlang, zoom: 15)));
        if (postData!.startDistrictID != 0 &&
            postData!.endDistrictID != 0 &&
            postData!.endDistrictID != null &&
            postData!.startDistrictID != null) {
          await Future.delayed(const Duration(seconds: 2));
          await routeDraw(marker1, marker2);
          await updateCameraLocation(marker1, marker2, _mapController!);
        }
      } else {
        print(null);
      }
    }

    void setStateShowMoreLine() {
      setState(() {
        _isShowMoreLine = !_isShowMoreLine;
      });
    }

    double widthSearbar = MediaQuery.of(context).size.width / 2 - 40;
    return [
      InkWell(
          onDoubleTap: _isAdd ? setStateShowMoreLine : null,
          onTap: _isAdd
              ? () async {
                  searchMap(1);
                }
              : setStateShowMoreLine,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 5, 0),
            child: Card(
              // color: Colors.white54.withOpacity(0.5),
              child: SizedBox(
                  // padding: const EdgeInsets.all(0),
                  width: widthSearbar,
                  child: ListTile(
                    title: Text(
                      location1,
                      style: const TextStyle(
                        fontSize: 18,
                        // color: Colors.grey,
                      ),
                      maxLines: _isShowMoreLine ? 5 : 1,
                    ),
                    // trailing: const Icon(Icons.search),
                    dense: true,
                  )),
            ),
          )),
      const Padding(
          padding: EdgeInsets.only(top: 15, left: 0, right: 0),
          child: Icon(
            Icons.arrow_forward,
            color: Colors.green,
          )),
      InkWell(
          onDoubleTap: _isAdd ? setStateShowMoreLine : null,
          onTap: _isAdd
              ? () async {
                  searchMap(2);
                }
              : setStateShowMoreLine,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 15, 15, 0),
            child: Card(
              // color: Colors.white54.withOpacity(0.5),
              child: SizedBox(
                  // padding: const EdgeInsets.all(0),
                  width: widthSearbar,
                  child: ListTile(
                    title: Text(
                      location2,
                      style: const TextStyle(
                        fontSize: 18,
                        // color: Colors.grey,
                      ),
                      maxLines: _isShowMoreLine ? 5 : 1,
                    ),
                    // trailing: const Icon(Icons.search),
                    dense: true,
                  )),
            ),
          )),
    ];
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController mapController,
  ) async {
    // ignore: unnecessary_null_comparison
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 110);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  void selectCar() async {
    _focusNodePrice.unfocus();
    _focusNodeBrand.unfocus();
    _focusNodemodel.unfocus();
    _focusNodeVRegistration.unfocus();
    _focusNodeColor.unfocus();

    if (cars != null && cars!.isNotEmpty) {
      await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Select Car'),
                content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  // return Column(mainAxisSize: MainAxisSize.max, children: []);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("เลือกรถของคุณ"),
                          const SizedBox(width: 15),
                          DropdownButton<Car>(
                              value: car,
                              items: cars!.map((Car car) {
                                return DropdownMenuItem<Car>(
                                    value: car, child: Text("${car.model}"));
                              }).toList(),
                              onChanged: (Car? c) {
                                // print(c!.model);
                                setState(() {
                                  car = c;
                                });
                              }),
                        ],
                      )
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
                        _modelController.text = car?.model ?? "";
                        _brandController.text = car?.brand ?? "";
                        _vehicleRegistrationController.text =
                            car?.vehicleRegistration ?? "";
                        _colorController.text = car?.color ?? "";
                        Navigator.pop(context);
                      },
                      child: const Text('Select')),
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
              ));
    } else {
      await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Select Car'),
                content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  // return Column(mainAxisSize: MainAxisSize.max, children: []);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("ไม่รถที่บันทึกไว้ "),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const CarScreen()));
                            },
                            icon: const Icon(Icons.add),
                            color: Colors.green,
                          )
                        ],
                      ),
                    ],
                  );
                }),
                actions: [
                  TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close')),
                ],
              ));
    }
  }

  void showAlertSelecLocation() async {
    // var
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Error'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("กรุณาเลือกสถานที่ใน Map"),
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

  void showAlertAdd() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Confirm Add'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("คุณต้องการเพิ่มโพสต์นี้หรือไม่"),
                  ],
                );
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      setState(() {
                        _isLoadingAdd = true;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      Post? post = await Post.addPostAndPostDetail(
                          prefs.getString('jwt') ?? "",
                          postData!,
                          postDetailData!);
                      Navigator.pop(context);
                      setState(() {
                        _isAdd = false;
                        _isLoadingAdd = false;
                      });
                      if (post != null) {
                        postUser = post.user;
                        showAlerSuccess();
                      } else {
                        showAlerError();
                      }
                    },
                    child: const Text('Add')),
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
            ));
  }

  void showAlerError() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Error'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("เกิดข้อผิดพลาดโปรดลองใหม่อีกครั้ง"),
                  ],
                );
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close')),
              ],
            ));
  }

  void showAlerSuccess() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Success'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("ดำเดินการสำเร็จ"),
                  ],
                );
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close')),
              ],
            ));
  }

  void showJoinPost() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Join'),
              // insetPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 30, top: 30),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return const Text("คุณต้องการเข้าร่วมการเดินทางนี้หรือไม่");
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();

                      PostMember? postMemberJoin = await PostMember.joinPost(
                          prefs.getString('jwt') ?? "", post!.id!);
                      if (postMemberJoin != null) {
                        setState(() {
                          _isJoin = false;
                        });
                        updateUI();
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Join')),
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

  void showCancelPost() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Cancel'),
              // insetPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 30, top: 30),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return const Text("คุณต้องการ ยกเลิกการเดินทางนี้หรือไม่");
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      Post? tempData = await Post.updateStatusPost(
                          prefs.getString('jwt') ?? "", post!.id!, "CANCEL");
                      if (tempData != null) {
                        showAlerSuccess();
                        setState(() {
                          post!.status = tempData.status;
                        });
                        updateUI();
                      } else {
                        showAlerError();
                      }
                    },
                    child: const Text('Yes')),
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('No')),
              ],
            ));
  }

  void showDonePost() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Done'),
              // insetPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 30, top: 30),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return const Text("คุณต้องการจะจบการเดินทางหรือไม่");
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      Post? tempData = await Post.updateStatusPost(
                          prefs.getString('jwt') ?? "", post!.id!, "DONE");
                      if (tempData != null) {
                        showAlerSuccess();
                        setState(() {
                          post!.status = tempData.status;
                        });
                        updateUI();
                      } else {
                        showAlerError();
                      }
                    },
                    child: const Text('Done')),
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('No')),
              ],
            ));
  }

  void pushChatDetailScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
                showBackbt: false,
                user: user,
                chatDB: Chat(
                  chatType: "GROUP",
                  sendPostID: post!.id,
                ),
              )),
    );
  }

  dynamic flotButton() {
    if (!_isView) {
      if (post!.createdUserID != user.id && post!.status == "NEW" && _isJoin) {
        return FloatingActionButton(
          onPressed: () {
            showJoinPost();
          },
          child: const Icon(Icons.add),
        );
      } else if ((post!.createdUserID != user.id && _isJoin == false) ||
          (post!.createdUserID == user.id &&
              (post!.status == "DONE" || post!.status == "CANCEL"))) {
        return FloatingActionButton(
          onPressed: () {
            pushChatDetailScreen();
          },
          child: const Icon(Icons.message),
        );
      } else if (post!.createdUserID == user.id &&
          (post!.status == "NEW" || post!.status == "IN_PROGRESS")) {
        return SpeedDial(
          icon: Icons.expand_less,
          activeIcon: Icons.expand_more,
          backgroundColor: Colors.green,
          activeBackgroundColor: Colors.red,
          spacing: 12,
          children: [
            // chat
            SpeedDialChild(
              backgroundColor: Colors.blue,
              label: "Chat",
              child: const Icon(Icons.message),
              onTap: () {
                pushChatDetailScreen();
              },
            ),
            // cancel
            SpeedDialChild(
              backgroundColor: Colors.red,
              label: "Cancel",
              child: const Icon(Icons.cancel_outlined),
              onTap: () {
                showCancelPost();
              },
            ),
          ],
        );
      }
    }
    return null;
  }

  void checkJoin(int seat) async {
    final prefs = await SharedPreferences.getInstance();
    int countMember = 0;
    bool isMember = false;

    List<PostMember>? tempDataPostmember =
        await PostMember.getPostMembersForCheckJoin(
            prefs.getString('jwt') ?? "", post!.id!);

    if (tempDataPostmember == null) {
      setState(() {
        _isJoin = true;
      });
    } else {
      for (var i in tempDataPostmember) {
        countMember++;
        if (i.userID == user.id) {
          countMember--;
          isMember = true;
          break;
        }
      }
      if (isMember == false && countMember < seat) {
        setState(() {
          _isJoin = true;
        });
      } else {
        setState(() {
          _isJoin = false;
        });
      }
    }
  }

  void updateUI() async {
    final prefs = await SharedPreferences.getInstance();
    if (!_isAdd) {
      setState(() {
        _isLoading = true;
      });
      PostDetail? tempData = await PostDetail.getPostDetailByPostID(
          prefs.getString('jwt') ?? "", post!.id!);
      if (tempData != null) {
        setState(() {
          postUser = tempData.post!.user!;
        });
        // postDetailTemp = tempData;
        _dateTimeController.text =
            globalData.dateTimeFormatForPost(post!.dateTimeStart);
        // _seatController.text = tempData.seat.toString();
        _priceController.text = tempData.price.toString();
        _brandController.text = tempData.brand!;
        _modelController.text = tempData.model!;
        _vehicleRegistrationController.text = tempData.vehicleRegistration!;
        _colorController.text = tempData.color!;
        _descriptionController.text =
            tempData.description ?? "ไม่มีรายระเอียดเพิ่มเติม";
        if (_isBack) {
          _dateTimeBackController.text =
              globalData.dateTimeFormatForPost(post!.dateTimeBack);
        }
        marker1 = tempData.startLatLng!;
        marker2 = tempData.endLatLng!;
        _seatController.text =
            "${tempData.post!.countPostMember}/${tempData.seat}";
        checkJoin(tempData.seat!);
      }
      checkJoin(tempData!.seat!);
      setState(() {
        _isLoading = false;
        post!.status = tempData.post!.status;
      });

      // await Future.delayed(const Duration(seconds: 2));
      await routeDraw(marker1, marker2);
      await updateCameraLocation(marker1, marker2, _mapController!);
    }
  }

  void updatePostDettail(data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int tempID = int.parse(data);
      if (tempID == post!.id) {
        PostDetail? tempData = await PostDetail.getPostDetailByPostID(
            prefs.getString('jwt') ?? "", tempID);
        if (tempData != null) {
          setState(() {
            postUser = tempData.post!.user!;
          });
          _dateTimeController.text =
              globalData.dateTimeFormatForPost(post!.dateTimeStart);
          _priceController.text = tempData.price.toString();
          _brandController.text = tempData.brand!;
          _modelController.text = tempData.model!;
          _vehicleRegistrationController.text = tempData.vehicleRegistration!;
          _colorController.text = tempData.color!;
          _descriptionController.text =
              tempData.description ?? "ไม่มีรายระเอียดเพิ่มเติม";
          if (_isBack) {
            _dateTimeBackController.text =
                globalData.dateTimeFormatForPost(post!.dateTimeBack);
          }
          _seatController.text =
              "${tempData.post!.countPostMember}/${tempData.seat}";
          checkJoin(tempData.seat!);
        }
      }
    } catch (err) {
      print(err);
    }
  }

  void getCar() async {
    final prefs = await SharedPreferences.getInstance();
    List<Car>? tempData = await Car.getCars(prefs.getString('jwt') ?? "");
    if (tempData != null && tempData.isNotEmpty) {
      car = tempData[0];
      setState(() {
        cars = tempData;
      });
    } else {
      setState(() {
        cars = [];
      });
    }
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
              "${globals.protocol}${globals.serverIP}/profiles/${review.img!}",
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
                                      "${globals.protocol}${globals.serverIP}/profiles/${p.img!}",
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
                                                      showBackbt: false,
                                                      user: user,
                                                      chatDB: Chat(
                                                        chatType: "PRIVATE",
                                                        sendUserID:
                                                            p.createdUserID,
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

  Future routeDraw(LatLng l1, LatLng l2) async {
    route.routes.clear();
    var points = [l1, l2];
    // const color = Color.fromARGB(255, 0, 0, 255);
    var color = Colors.blue.shade800;
    try {
      await route.drawRoute(
        points,
        'Test routes',
        color,
        GlobalData().googleApiKey(),
        travelMode: TravelModes.driving,
      );
      setState(() {
        totalDistance =
            distanceCalculator.calculateRouteDistance(points, decimals: 1);
      });
    } catch (err) {
      print(err);
    }
  }

  Widget _loadingAddPost() {
    return SkeletonLoader(
      builder: Padding(
        padding: const EdgeInsets.only(right: 70, left: 70),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 3, color: Colors.white),
            ),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
              ),
              onPressed: null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  "Please wait",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
              ),
            )),
      ),
      items: 1,
      period: const Duration(seconds: 2),
      highlightColor: Colors.pink,
      // baseColor: Colors.pink,
      direction: SkeletonDirection.ltr,
    );
  }

  Widget _loadingDetail() {
    return SkeletonLoader(
      builder: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 3, color: Colors.white),
            ),
            height: (MediaQuery.of(context).size.height / 2) - 30,
            width: MediaQuery.of(context).size.height,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.only(top: 50),
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.white),
              ),
              width: MediaQuery.of(context).size.height,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 1, 20, 20),
            child: Container(
              padding: const EdgeInsets.only(top: 50),
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.white),
              ),
              width: MediaQuery.of(context).size.height,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 1, 20, 20),
            child: Container(
              padding: const EdgeInsets.only(top: 50),
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.white),
              ),
              width: MediaQuery.of(context).size.height,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 1, 20, 20),
            child: Container(
              padding: const EdgeInsets.only(top: 50),
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.white),
              ),
              width: MediaQuery.of(context).size.height,
            ),
          ),
        ],
      ),
      items: 1,
      period: const Duration(seconds: 2),
      highlightColor: Colors.pink,
      // baseColor: Colors.pink,
      direction: SkeletonDirection.ltr,
    );
  }
}
