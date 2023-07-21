import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../models/car.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  @override
  final formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  List<Car>? cars = [];
  Car? carData = Car();

  void initState() {
    super.initState();
    updateUI();
  }

  void dispose() {
    super.dispose();
  }

  List<Widget> appBarBt() {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Stack(alignment: Alignment.center, children: [
          IconButton(
              onPressed: () {
                addCar();
              },
              icon: const Icon(
                Icons.directions_car,
                size: 30,
              )),
          const Positioned(
            top: 4,
            right: -1,
            child: Icon(
              Icons.add,
              size: 22,
            ),
          ),
        ]),
      )
    ];
  }

  Widget listViewCars() {
    print(cars!.length);
    if (cars!.length > 0) {
      List<ListTile> list = [];
      for (var car in cars!) {
        var l = ListTile(
          // contentPadding: const EdgeInsets.only(
          //     top: 15.0, left: 15.0, right: 10.0, bottom: 5.0),
          // tileColor: getColor.colorListTile(i),
          title: Text(car.model!),
          // trailing: Text(dateTimeformat(DateTime.now())),
          onTap: () {},
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
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "No data",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          )
        ],
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Cars"),
          backgroundColor: Colors.pink,
          actions: appBarBt(),
        ),
        body: SafeArea(
          child: _isLoading
              ? listLoader()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(child: listViewCars()),
                  ],
                ),
        ));
  }

  void addCar() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Add Car'),
              // insetPadding: EdgeInsets.zero,
              // insetPadding: const EdgeInsets.only(
              //     left: 20, right: 20, bottom: 30, top: 30),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(
                      onSaved: (newValue) {
                        carData!.brand = newValue;
                      },
                      validator: MultiValidator(
                          [RequiredValidator(errorText: "Please Input Brand")]),
                      decoration: InputDecoration(
                          labelText: "ยี่ห้อ",
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            // borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.car_crash,
                            color: Colors.pink,
                          )),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      onSaved: (newValue) {
                        carData!.model = newValue;
                      },
                      validator: MultiValidator(
                          [RequiredValidator(errorText: "Please Input model")]),
                      decoration: InputDecoration(
                          labelText: "รุ่น",
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            // borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.directions_car,
                            color: Colors.pink,
                          )),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      onSaved: (newValue) {
                        carData!.vehicleRegistration = newValue;
                      },
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: "Please Input Vehicle Registration")
                      ]),
                      decoration: InputDecoration(
                          labelText: "ทะเบียน",
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            // borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.font_download,
                            color: Colors.pink,
                          )),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      onSaved: (newValue) {
                        carData!.color = newValue;
                      },
                      validator: MultiValidator(
                          [RequiredValidator(errorText: "Please Input Color")]),
                      decoration: InputDecoration(
                          labelText: "สี",
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            // borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.palette,
                            color: Colors.pink,
                          )),
                    ),
                  ]),
                );
              }),
              actions: [
                TextButton(
                    child: const Text('Add'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        // print(carData!.brand);
                        // print(carData!.model);
                        // print(carData!.vehicleRegistration);
                        // print(carData!.color);
                        setState(() {
                          _isLoading = true;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        Car? tempData = await Car.addCar(
                            prefs.getString('jwt') ?? "", carData!);
                        if (tempData != null) {
                          updateUI();
                        } else {
                          showAlerAddError();
                        }
                        Navigator.pop(context);
                      }
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
    // await showGeneralDialog(
    //   context: context,
    //   pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
    //       backgroundColor: Colors.black87,
    //       body: Column(
    //         children: [],
    //       )),
    // );
  }

  void updateUI() async {
    final prefs = await SharedPreferences.getInstance();

    // setState(() {
    //   _isLoading = true;
    // });

    List<Car>? tempData = await Car.getCars(prefs.getString('jwt') ?? "");

    setState(() {
      cars = tempData ?? [];
      _isLoading = false;
    });
  }

  void showAlerAddError() {
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
                    child: const Text('Close'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
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
