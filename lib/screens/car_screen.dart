import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../gobal_function/color.dart';
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

  TextEditingController modelTextController = TextEditingController();
  TextEditingController brandTextController = TextEditingController();
  TextEditingController colorTextController = TextEditingController();
  TextEditingController vehicleRegistrationTextController =
      TextEditingController();

  void initState() {
    super.initState();
    updateUI();
  }

  void dispose() {
    super.dispose();
    modelTextController.dispose();
    brandTextController.dispose();
    colorTextController.dispose();
    vehicleRegistrationTextController.dispose();
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
    // print(cars!.length);
    if (cars!.length > 0) {
      var c = GetColor();
      int i = 0;
      List<ListTile> list = [];
      for (var car in cars!) {
        var l = ListTile(
          contentPadding: const EdgeInsets.only(
              top: 15.0, left: 15.0, right: 10.0, bottom: 5.0),
          tileColor: c.colorListTile(i),
          title: Column(
            children: [
              Row(
                children: [
                  // Icon(
                  //   Icons.directions_car_filled,
                  //   color: Colors.amber,
                  // ),
                  Flexible(
                    child: Text(" ${car.model}  ${car.brand}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(" ${car.color}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Text(" ${car.vehicleRegistration}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    editCar(car);
                  },
                  icon: const Icon(Icons.edit, color: Colors.amber)),
              IconButton(
                  onPressed: () {
                    deleteCar(car);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          ),
          // onTap: () {},
        );
        i++;
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
                          showAlerError();
                        }
                        Navigator.pop(context);
                      }
                    }),
                TextButton(
                    child: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
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

  void editCar(Car c) async {
    modelTextController.text = c.model!;
    brandTextController.text = c.brand!;
    vehicleRegistrationTextController.text = c.vehicleRegistration!;
    colorTextController.text = c.color!;

    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Edit Car'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(
                      controller: modelTextController,
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: brandTextController,
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: vehicleRegistrationTextController,
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: colorTextController,
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
                    child: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.amber,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        // print(carData!.brand);
                        // print(carData!.model);
                        // print(carData!.vehicleRegistration);
                        // print(carData!.color);
                        carData!.id = c.id;
                        setState(() {
                          _isLoading = true;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        Car? tempData = await Car.editCar(
                            prefs.getString('jwt') ?? "", carData!);
                        if (tempData != null) {
                          updateUI();
                        } else {
                          showAlerError();
                        }
                        Navigator.pop(context);
                      }
                    }),
                TextButton(
                    child: const Text('Cancel'),
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

  void deleteCar(Car c) async {
    modelTextController.text = c.model!;
    brandTextController.text = c.brand!;
    vehicleRegistrationTextController.text = c.vehicleRegistration!;
    colorTextController.text = c.color!;

    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete Car'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Form(
                  key: formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(
                      enabled: false,
                      controller: modelTextController,
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
                    const SizedBox(height: 10),
                    TextFormField(
                      enabled: false,
                      controller: brandTextController,
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
                    const SizedBox(height: 10),
                    TextFormField(
                      enabled: false,
                      controller: vehicleRegistrationTextController,
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
                    const SizedBox(height: 10),
                    TextFormField(
                      enabled: false,
                      controller: colorTextController,
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
                    child: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      Car? tempData = await Car.deleteCar(
                          prefs.getString('jwt') ?? "", c.id!);
                      Navigator.pop(context);
                      if (tempData != null) {
                        updateUI();
                      } else {
                        showAlerError();
                      }
                    }),
                TextButton(
                    child: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            ));
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

  void showAlerError() {
    setState(() {
      _isLoading = false;
    });
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
