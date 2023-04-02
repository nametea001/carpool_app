import 'package:car_pool_project/screens/chat_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';

import '../gobal_function/data.dart';

class PostDetailScreen extends StatefulWidget {
  final bool? isAdd;
  const PostDetailScreen({
    super.key,
    this.isAdd,
  });
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  GlobalData globalData = new GlobalData();
  bool _isAdd = false;
  bool _isScroll = true;

  bool _myLocationEnable = false;
  bool _showMarkerStartToEnd = false;
  String location = "Search Location";
  Position? userLocation;
  GoogleMapController? _mapController;
  // final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();
  // LatLng startLocation = LatLng(17.291925, 104.112884);
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(17.291925, 104.112884),
    zoom: 14,
  );

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
  FocusNode _focusNodeDescription = FocusNode();
  FocusNode _focusNodeSeat = FocusNode();
  FocusNode _focusNodePrice = FocusNode();
  FocusNode _focusNodeBrand = FocusNode();
  FocusNode _focusNodemodel = FocusNode();
  FocusNode _focusNodeVRegistration = FocusNode();
  FocusNode _focusNodeColor = FocusNode();
  // datetime control
  TextEditingController dateTimeController = TextEditingController();
  String stateDatetimeSelected = "";
  DateTime? datetimeSelected;
  TextEditingController dateTimeBackController = TextEditingController();
  String stateDatetimeBackSelected = "";
  DateTime? datetimeBackSelected;

  @override
  void initState() {
    super.initState();
    _isAdd = widget.isAdd ?? false;
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
          title: (_isAdd ? Text('Add') : Text('Detail')),
          backgroundColor: Colors.pink,
          actions: [],
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              // padding: EdgeInsets.only(left: 20, right: 20),
              height: (MediaQuery.of(context).size.height / 2) - 90,
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
                  myLocationButtonEnabled: false,
                  myLocationEnabled: _myLocationEnable,
                  zoomControlsEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  mapType: MapType.normal, //map type
                  onMapCreated: _onMapCreated,
                  markers: _showMarkerStartToEnd
                      ? {
                          const Marker(
                            draggable: false,
                            markerId: MarkerId("marker1"),
                            position: LatLng(17.291925, 104.112884),
                          ),
                          const Marker(
                            draggable: false,
                            markerId: MarkerId("marker2"),
                            position: LatLng(17.291925, 105.112884),
                          ),
                        }
                      : {},
                ),

                //search autoconplete input
                Visibility(
                  visible: _isAdd,
                  child: Positioned(
                      //search input bar
                      top: 10,
                      child: InkWell(
                          onTap: () async {
                            Prediction? place = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: globalData.googleApiKey(),
                                mode: Mode.overlay,
                                types: [],
                                strictbounds: false,
                                components: [
                                  Component(Component.country, 'th')
                                ],
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
                              setState(() {
                                location = place.description.toString();
                              });

                              //form google_maps_webservice package
                              final plist = GoogleMapsPlaces(
                                apiKey: globalData.googleApiKey(),
                                apiHeaders:
                                    await const GoogleApiHeaders().getHeaders(),
                                //from google_api_headers package
                              );
                              String placeid = place.placeId ?? "0";
                              final detail =
                                  await plist.getDetailsByPlaceId(placeid);
                              final geometry = detail.result.geometry!;
                              final lat = geometry.location.lat;
                              final lang = geometry.location.lng;
                              var newlatlang = LatLng(lat, lang);

                              //move map camera to selected place with animation
                              _mapController?.animateCamera(
                                  CameraUpdate.newCameraPosition(CameraPosition(
                                      target: newlatlang, zoom: 17)));
                            } else {
                              print(null);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Card(
                              child: Container(
                                  padding: const EdgeInsets.all(0),
                                  width: MediaQuery.of(context).size.width - 40,
                                  child: ListTile(
                                    title: Text(
                                      location,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    trailing: const Icon(Icons.search),
                                    dense: true,
                                  )),
                            ),
                          ))),
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
                          side: const BorderSide(color: Colors.white, width: 1),
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
                                      _mapController?.animateCamera(
                                        CameraUpdate.newLatLngZoom(
                                            LatLng(l.latitude, l.longitude),
                                            14),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.my_location,
                                    size: 30,
                                  )),
                              // Text(
                              //   "Lot",
                              //   style: TextStyle(
                              //     fontSize: 12.0,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.black,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.white, width: 1),
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
                                  },
                                  icon: const Icon(
                                    Icons.pin_drop,
                                    size: 30,
                                  )),
                              // Text(
                              //   "Lot",
                              //   style: TextStyle(
                              //     fontSize: 12.0,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.black,
                              //   ),
                              // ),
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
              padding: const EdgeInsets.only(top: 10, right: 25, left: 25),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: _isAdd,
                      child: Row(
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
                                    dateTimeBackController.text = "";
                                    datetimeBackSelected = null;
                                    stateDatetimeBackSelected = "";
                                  });
                                })),
                          ),
                          const Text("ไปอย่างเดียว"),
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width / 2) - 140,
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
                            enabled: _isAdd,
                            showCursor: false,
                            readOnly: true,
                            focusNode: FocusNode(canRequestFocus: false),
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
                                  int m = int.parse(
                                      DateFormat.M().format(datetimeSelected!));
                                  String dw =
                                      DateFormat.E().format(datetimeSelected!);
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
                                  borderRadius: BorderRadius.circular(10.0),
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
                                  width: MediaQuery.of(context).size.width - 50,
                                  child: TextFormField(
                                    enabled: _isAdd,
                                    showCursor: false,
                                    readOnly: true,
                                    focusNode:
                                        FocusNode(canRequestFocus: false),
                                    keyboardType: TextInputType.none,
                                    controller: dateTimeBackController,
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      DatePicker.showDateTimePicker(
                                        context,
                                        showTitleActions: true,
                                        minTime:
                                            datetimeSelected ?? DateTime.now(),
                                        currentTime:
                                            datetimeSelected ?? DateTime.now(),
                                        locale: LocaleType.th,
                                        onConfirm: (time) {
                                          datetimeBackSelected = time;
                                          int m = int.parse(DateFormat.M()
                                              .format(datetimeBackSelected!));
                                          String dw = DateFormat.E()
                                              .format(datetimeBackSelected!);
                                          stateDatetimeBackSelected =
                                              "${globalData.getDay(dw)} ${datetimeSelected!.day} ${globalData.getMonth(m)} ${datetimeSelected!.year}  ${DateFormat.Hm().format(datetimeSelected!)}";
                                          dateTimeBackController.text =
                                              stateDatetimeSelected;
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
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 30,
                              child: TextFormField(
                                enabled: _isAdd,
                                focusNode: _focusNodeSeat,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: "จำนวนที่นั่ง",
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
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
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 30,
                              child: TextFormField(
                                enabled: _isAdd,
                                focusNode: _focusNodePrice,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: "ราคาต่อที่นั่ง",
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
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
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 30,
                              child: TextFormField(
                                enabled: _isAdd,
                                focusNode: _focusNodeBrand,
                                decoration: InputDecoration(
                                    labelText: "ยี่ห้อ",
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
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
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 30,
                              child: TextFormField(
                                enabled: _isAdd,
                                focusNode: _focusNodemodel,
                                decoration: InputDecoration(
                                    labelText: "รุ่น",
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
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
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 30,
                              child: TextFormField(
                                enabled: _isAdd,
                                focusNode: _focusNodeVRegistration,
                                decoration: InputDecoration(
                                    labelText: "ทะเบียน",
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
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
                              width:
                                  (MediaQuery.of(context).size.width / 2) - 30,
                              child: TextFormField(
                                enabled: _isAdd,
                                focusNode: _focusNodeColor,
                                decoration: InputDecoration(
                                    labelText: "สี",
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
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
                            enabled: _isAdd,
                            focusNode: _focusNodeDescription,
                            maxLines: 3,
                            decoration: InputDecoration(
                                labelText: "รายระเอียดเพิ่มเติม",
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
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
                    Visibility(
                      visible: _isAdd,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                        ),
                        onPressed: () async {
                          showDetailAdd();
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
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
        floatingActionButton: (_isAdd
            ? null
            : SpeedDial(
                icon: Icons.expand_less,
                activeIcon: Icons.expand_more,
                backgroundColor: Colors.green,
                activeBackgroundColor: Colors.red,
                spacing: 12,
                children: [
                  SpeedDialChild(
                    backgroundColor: Colors.greenAccent,
                    label: "Join",
                    child: Icon(Icons.add),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('Join'),
                                // insetPadding: EdgeInsets.zero,
                                insetPadding: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 30, top: 30),
                                content: StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  // return Column(mainAxisSize: MainAxisSize.max, children: []);
                                  return Text(
                                      "คุณต้องการเข้าร่วมการเดินทางนี้หรือไม่");
                                }),
                                actions: [
                                  TextButton(
                                      child: const Text('Join'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
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
                  ),
                  SpeedDialChild(
                    backgroundColor: Colors.blue,
                    label: "Chat",
                    child: Icon(Icons.message),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatDetailScreen()),
                      );
                    },
                  ),
                  SpeedDialChild(
                    backgroundColor: Colors.green,
                    label: "Done",
                    child: Icon(Icons.check_circle_outline),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('Done'),
                                // insetPadding: EdgeInsets.zero,
                                insetPadding: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 30, top: 30),
                                content: StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  // return Column(mainAxisSize: MainAxisSize.max, children: []);
                                  return Text(
                                      "คุณต้องการจะจบการเดินทางหรือไม่");
                                }),
                                actions: [
                                  TextButton(
                                      child: const Text('Done'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                  TextButton(
                                      child: const Text('No'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                ],
                              ));
                    },
                  ),
                  SpeedDialChild(
                    backgroundColor: Colors.red,
                    label: "Cancel",
                    child: Icon(Icons.cancel_outlined),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('Cancel'),
                                // insetPadding: EdgeInsets.zero,
                                insetPadding: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 30, top: 30),
                                content: StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  // return Column(mainAxisSize: MainAxisSize.max, children: []);
                                  return Text(
                                      "คุณต้องการ ยกเลิกการเดินทางนี้หรือไม่");
                                }),
                                actions: [
                                  TextButton(
                                      child: const Text('Cancel'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                  TextButton(
                                      child: const Text('No'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                ],
                              ));
                    },
                  ),
                ],
              )),
      ),
    );
  }

  void showDetailAdd() async {
    // var
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Confirm Add '),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("คุณต้องการเข้าร่วมหรือไม่"),
                  ],
                );
              }),
              actions: [
                TextButton(
                    child: const Text('Add'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
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
  }
}
