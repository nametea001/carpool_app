import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

import '../gobal_function/color.dart';
import '../models/car.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  final formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  List<Car>? cars = [];
  Car? carData = Car();

  TextEditingController modelTextController = TextEditingController();
  TextEditingController brandTextController = TextEditingController();
  TextEditingController colorTextController = TextEditingController();
  TextEditingController vehicleRegistrationTextController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    updateUI();
  }

  @override
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
    if (cars!.isNotEmpty) {
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
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Cars"),
          backgroundColor: Colors.pink,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, cars);
            },
            icon: const Icon(Icons.arrow_back),
          ),
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
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        Navigator.pop(context);
                        // print(carData!.brand);
                        // print(carData!.model);
                        // print(carData!.vehicleRegistration);
                        // print(carData!.color);
                        setState(() {
                          _isLoading = true;
                        });
                        Car? tempData = await Car.addCar(carData!);
                        if (tempData != null) {
                          updateUI();
                        } else {
                          showAlerError();
                        }
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
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.amber,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        Navigator.pop(context);
                        // print(carData!.brand);
                        // print(carData!.model);
                        // print(carData!.vehicleRegistration);
                        // print(carData!.color);
                        carData!.id = c.id;
                        setState(() {
                          _isLoading = true;
                        });
                        Car? tempData = await Car.editCar(carData!);
                        if (tempData != null) {
                          updateUI();
                        } else {
                          showAlerError();
                        }
                      }
                    },
                    child: const Text('Edit')),
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
                    // Text("คุณต้องการที่จะลบหรือไม่"),
                    TextFormField(
                      // enabled: false,
                      readOnly: true,
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
                      // enabled: false,
                      readOnly: true,
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
                      // enabled: false,
                      readOnly: true,
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
                      // enabled: false,
                      readOnly: true,
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
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      Navigator.pop(context);
                      setState(() {
                        _isLoading = true;
                      });
                      Car? tempData = await Car.deleteCar(c.id!);
                      if (tempData != null) {
                        updateUI();
                      } else {
                        showAlerError();
                      }
                    },
                    child: const Text('Delete')),
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
              ],
            ));
  }

  void updateUI() async {
    List<Car>? tempData = await Car.getCars();
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
