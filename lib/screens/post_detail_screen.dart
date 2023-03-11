import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import '../gobal_function/data.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  GlobalData globalData = new GlobalData();

  bool _myLocationEnable = false;
  String location = "Search Location";
  Position? userLocation;
  GoogleMapController? mapController;
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
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
        backgroundColor: Colors.pink,
        actions: [],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Container(
            height: (MediaQuery.of(context).size.height / 2) - 90,
            child: Stack(children: [
              GoogleMap(
                //Map widget from google_maps_flutter package
                // zoomGesturesEnabled: false, //enable Zoom in, out on map
                myLocationButtonEnabled: false,
                myLocationEnabled: _myLocationEnable,
                zoomControlsEnabled: true,
                initialCameraPosition: _kGooglePlex,
                mapType: MapType.normal, //map type
                onMapCreated: _onMapCreated,
              ),

              //search autoconplete input
              Positioned(
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
                            components: [Component(Component.country, 'th')],
                            decoration: InputDecoration(
                              hintText: 'Search',
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
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
                            apiHeaders: await GoogleApiHeaders().getHeaders(),
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
                          mapController?.animateCamera(
                              CameraUpdate.newCameraPosition(CameraPosition(
                                  target: newlatlang, zoom: 17)));
                        } else {
                          print(null);
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Card(
                          child: Container(
                              padding: EdgeInsets.all(0),
                              width: MediaQuery.of(context).size.width - 40,
                              child: ListTile(
                                title: Text(
                                  location,
                                  style: TextStyle(fontSize: 18),
                                ),
                                trailing: Icon(Icons.search),
                                dense: true,
                              )),
                        ),
                      ))),
            ]),
          ),
          Padding(
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
                      side: BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        children: [
                          IconButton(
                              onPressed: () async {
                                setState(() {
                                  _myLocationEnable = true;
                                });
                                Position? l = await _getLocation();
                                if (l != null) {
                                  mapController?.animateCamera(
                                      CameraUpdate.newLatLngZoom(
                                          LatLng(l.latitude, l.longitude), 14));
                                }
                              },
                              icon: Icon(
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
                ],
              ),
            ),
          )
        ],
      )),
      floatingActionButton: SpeedDial(
        icon: Icons.expand_less,
        activeIcon: Icons.expand_more,
        backgroundColor: Colors.green,
        activeBackgroundColor: Colors.red,
        spacing: 12,
        children: [
          SpeedDialChild(
            // backgroundColor: Colors.lime,
            child: Icon(Icons.mail),
            onTap: () {},
          ),
          SpeedDialChild(
            // backgroundColor: Colors.lime,
            child: Icon(Icons.add),
            onTap: () {},
          ),
          SpeedDialChild(
            // backgroundColor: Colors.lime,
            child: Icon(Icons.abc),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
