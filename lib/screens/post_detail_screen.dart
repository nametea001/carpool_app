import 'dart:convert';

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
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import '../gobal_function/data.dart';
import '../models/car.dart';
import '../models/user.dart';

class PostDetailScreen extends StatefulWidget {
  final bool? isAdd;
  final bool? isback;
  final int? postID;
  final DateTime? dateTimeStart;
  final DateTime? dateTimeEnd;
  final String? startName;
  final String? endName;
  final int? postCreatedUserID;
  final String? postStatus;
  final int? userID;
  final User? postUser;

  const PostDetailScreen(
      {super.key,
      this.isAdd,
      this.isback,
      this.postID,
      this.dateTimeStart,
      this.dateTimeEnd,
      this.startName,
      this.endName,
      this.postCreatedUserID,
      this.postStatus,
      this.userID,
      this.postUser});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  GlobalData globalData = new GlobalData();
  bool _isAdd = false;
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
  LatLng marker1 = LatLng(17.291925, 104.112884);
  LatLng marker2 = LatLng(17.291925, 104.112884);

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
  TextEditingController _dateTimeController = TextEditingController();
  TextEditingController _dateTimeBackController = TextEditingController();
  TextEditingController _seatController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _brandController = TextEditingController();
  TextEditingController _modelController = TextEditingController();
  TextEditingController _vehicleRegistrationController =
      TextEditingController();
  TextEditingController _colorController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  int postCreatedUserID = 0;

  PostDetail? postDetailData = PostDetail();
  Post? postData = Post(startDistrictID: 0, endDistrictID: 0);
  // PostDetail? postDetailTemp = PostDetail();
  bool _isLoading = false;
  bool _isJoin = false;

  DateTime? dateTimeStart;
  DateTime? dateTimeEnd;
  int? postID = 0;
  String? postStatus = "";

  MapsRoutes route = MapsRoutes();
  DistanceCalculator distanceCalculator = DistanceCalculator();
  String totalDistance = 'No route';

  int userID = 0;

  User postUser = User();

  List<Car>? cars = [];
  Car? car = Car();

  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    postUser = widget.postUser ?? User();
    userID = widget.userID ?? 0;
    _isAdd = widget.isAdd ?? false;
    stateGoBack = _isBack == false ? "go" : "back";
    dateTimeStart = widget.dateTimeStart ?? null;
    dateTimeEnd = widget.dateTimeEnd ?? null;
    location1 = widget.startName ?? location1;
    location2 = widget.endName ?? location2;
    postID = widget.postID ?? 0;
    postStatus = widget.postStatus ?? null;
    postCreatedUserID = widget.postCreatedUserID ?? 0;
    getCar();
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
          title: (_isAdd ? const Text('Add') : const Text('Detail')),
          backgroundColor: Colors.pink,
          // actions: [
          //   IconButton(
          //       onPressed: () async {
          //         setState(() {
          //           _isJoin = !_isJoin;
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
                  Container(
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
                        markers: _showMarkerStartToEnd
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
                              },
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
                                          Position? l = await _getLocation();
                                          if (l != null) {
                                            LatLng latLngTemp =
                                                LatLng(l.latitude, l.longitude);
                                            await _mapController?.animateCamera(
                                              CameraUpdate.newLatLngZoom(
                                                  latLngTemp, 15),
                                            );
                                            route.routes.clear();
                                            await Future.delayed(
                                                const Duration(seconds: 2));
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
                                          await Future.delayed(
                                              const Duration(seconds: 2));
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
                                  enabled: _isAdd,
                                  showCursor: false,
                                  readOnly: true,
                                  focusNode: FocusNode(canRequestFocus: false),
                                  keyboardType: TextInputType.none,
                                  controller: _dateTimeController,
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    DatePicker.showDateTimePicker(
                                      context,
                                      showTitleActions: true,
                                      minTime: DateTime.now(),
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.th,
                                      onConfirm: (time) {
                                        postData!.dateTimeStart = time;
                                        _dateTimeController.text =
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
                                          enabled: _isAdd,
                                          showCursor: false,
                                          readOnly: true,
                                          focusNode:
                                              FocusNode(canRequestFocus: false),
                                          keyboardType: TextInputType.none,
                                          controller: _dateTimeBackController,
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
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
                                                    dateTimeformat(time);
                                              },
                                            );
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
                                      validator: MultiValidator([
                                        RequiredValidator(
                                            errorText: "Please Input Seat")
                                      ]),
                                      enabled: _isAdd,
                                      focusNode: _focusNodeSeat,
                                      controller: _seatController,
                                      keyboardType: TextInputType.number,
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
                                          return "Please Input Price";
                                        }
                                        if (int.parse(str) < 0) {
                                          return "Please Input Price more";
                                        }
                                        return null;
                                      },
                                      enabled: _isAdd,
                                      focusNode: _focusNodePrice,
                                      controller: _priceController,
                                      keyboardType: TextInputType.number,
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
                                            errorText: "Please Input model")
                                      ]),
                                      onTap: () {
                                        if (_isAdd) {
                                          selectCar();
                                        }
                                      },
                                      // enabled: false,
                                      readOnly: true,
                                      showCursor: false,
                                      enabled: _isAdd,
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
                                            errorText: "Please Input Brand")
                                      ]),
                                      onTap: () {
                                        if (_isAdd) {
                                          selectCar();
                                        }
                                      },
                                      readOnly: true,
                                      showCursor: false,
                                      // enabled: false,
                                      enabled: _isAdd,
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
                                        }
                                      },
                                      readOnly: true,
                                      showCursor: false,
                                      // enabled: false,
                                      enabled: _isAdd,
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
                                        }
                                      },
                                      readOnly: true,
                                      showCursor: false,
                                      // enabled: false,
                                      enabled: _isAdd,
                                      // focusNode: _focusNodeColor,
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
                                  enabled: _isAdd,
                                  focusNode: _focusNodeDescription,
                                  controller: _descriptionController,
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
                                            showDetailAdd();
                                          }
                                        }
                                        // showDetailAdd();
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
                          Visibility(
                            visible: !_isAdd,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                // decoration: BoxDecoration(color: Colors.red),
                                // width: MediaQuery.of(context).size.width,

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      child: postUser.img != null
                                          ? ClipOval(
                                              child: Image.memory(
                                                base64Decode(postUser.img!),
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 15),
                                    Column(
                                      children: [
                                        Text(
                                          "${postUser.firstName} ${postUser.lastName}",
                                          style: const TextStyle(
                                              fontSize: 30,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${postUser.email}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          "${postUser.sex}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
      {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
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
                            icon: Icon(Icons.add),
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
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

  void showDetailAdd() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Confirm Add'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
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
                        showAlerSuccess();
                      } else {
                        Navigator.pop(context);
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
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
                          prefs.getString('jwt') ?? "", postID!);
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
                          prefs.getString('jwt') ?? "", postID!, "CANCEL");
                      if (tempData != null) {
                        showAlerSuccess();
                        setState(() {
                          postStatus = tempData.status;
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
                          prefs.getString('jwt') ?? "", postID!, "DONE");
                      if (tempData != null) {
                        showAlerSuccess();
                        setState(() {
                          postStatus = tempData.status;
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

  String dateTimeformat(DateTime? time) {
    int mount = int.parse(DateFormat.M().format(time!));
    String dayWeek = DateFormat.E().format(time);
    // String dateTimeFormat =
    //     "${globalData.getDay(dayWeek)} ${time.day} ${globalData.getMonth(mount)} ${time.year}  ${DateFormat.Hm().format(time)}";
    String dateTimeFormat =
        "${globalData.getDay(dayWeek)} ${time.day} ${globalData.getMonth(mount)} ${DateFormat.Hm().format(time)}";
    return dateTimeFormat;
  }

  SpeedDial flotButton() {
    if (postCreatedUserID != userID && postStatus == "NEW" && _isJoin == true) {
      return SpeedDial(
        icon: Icons.expand_less,
        activeIcon: Icons.expand_more,
        backgroundColor: Colors.green,
        activeBackgroundColor: Colors.red,
        spacing: 12,
        children: [
          SpeedDialChild(
            backgroundColor: Colors.greenAccent,
            label: "Join",
            child: const Icon(Icons.add),
            onTap: () {
              showJoinPost();
            },
          )
        ],
      );
    } else if ((postCreatedUserID != userID && _isJoin == false) ||
        (postCreatedUserID == userID &&
            (postStatus == "DONE" || postStatus == "CANCEL"))) {
      return SpeedDial(
        icon: Icons.expand_less,
        activeIcon: Icons.expand_more,
        backgroundColor: Colors.green,
        activeBackgroundColor: Colors.red,
        spacing: 12,
        children: [
          SpeedDialChild(
            backgroundColor: Colors.blue,
            label: "Chat",
            child: const Icon(Icons.message),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChatDetailScreen()),
              );
            },
          ),
        ],
      );
    } else if (postCreatedUserID == userID && postStatus == "NEW") {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChatDetailScreen()),
              );
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
    } else if (postCreatedUserID == userID && (postStatus == "IN_PROGRESS")) {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChatDetailScreen()),
              );
            },
          ),
          // done
          SpeedDialChild(
            backgroundColor: Colors.green,
            label: "Done",
            child: const Icon(Icons.check_circle_outline),
            onTap: () {
              showDonePost();
            },
          ),
          // cancel
          SpeedDialChild(
            backgroundColor: Colors.red,
            label: "Cancel",
            child: const Icon(Icons.cancel_outlined),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: const Text('Cancel'),
                        // insetPadding: EdgeInsets.zero,
                        insetPadding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 30, top: 30),
                        content: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          // return Column(mainAxisSize: MainAxisSize.max, children: []);
                          return const Text(
                              "คุณต้องการ ยกเลิกการเดินทางนี้หรือไม่");
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
            },
          ),
        ],
      );
    }
    return const SpeedDial(
      icon: Icons.expand_less,
      activeIcon: Icons.expand_more,
      backgroundColor: Colors.green,
      activeBackgroundColor: Colors.red,
      spacing: 12,
      children: [],
    );
  }

  void updateUI() async {
    final prefs = await SharedPreferences.getInstance();
    // userID = prefs.getInt("user_id") ?? 0;
    if (!_isAdd) {
      setState(() {
        _isLoading = true;
      });
      PostDetail? tempData = await PostDetail.getPostDetailByPostID(
          prefs.getString('jwt') ?? "", postID!);
      if (tempData != null) {
        // postDetailTemp = tempData;
        _dateTimeController.text = dateTimeformat(dateTimeStart);
        // _seatController.text = tempData.seat.toString();
        _priceController.text = tempData.price.toString();
        _brandController.text = tempData.brand!;
        _modelController.text = tempData.model!;
        _vehicleRegistrationController.text = tempData.vehicleRegistration!;
        _colorController.text = tempData.color!;
        _descriptionController.text =
            tempData.description ?? "ไม่มีรายระเอียดเพิ่มเติม";
        if (_isBack) {
          _dateTimeBackController.text = dateTimeformat(dateTimeEnd);
        }
        marker1 = tempData.startLatLng!;
        marker2 = tempData.endLatLng!;

        int countMember = 0;
        bool _isMember = false;

        if (postCreatedUserID != userID) {
          List<PostMember>? tempDataPostmember =
              await PostMember.getPostMembersForCheckJoin(
                  prefs.getString('jwt') ?? "", postID!);

          if (tempDataPostmember == null) {
            setState(() {
              _isJoin = true;
            });
          } else {
            for (var i in tempDataPostmember) {
              countMember++;
              if (i.userID == userID) {
                _isMember = true;
                break;
              }
            }
            if (_isMember == false && countMember < tempData.seat!) {
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
        _seatController.text = "${countMember}/${tempData.seat}";
      }
      setState(() {
        _isLoading = false;
        postStatus = tempData?.posts!.status;
      });

      await Future.delayed(const Duration(seconds: 2));
      await routeDraw(marker1, marker2);
      await updateCameraLocation(marker1, marker2, _mapController!);
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

  Future routeDraw(LatLng l1, LatLng l2) async {
    route.routes.clear();
    var points = [l1, l2];
    var color = const Color.fromRGBO(53, 237, 59, 1);
    // var color = Colors.green;
    try {
      await route.drawRoute(
          points, 'Test routes', color, GlobalData().googleApiKey(),
          travelMode: TravelModes.walking);
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
