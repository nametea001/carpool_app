import 'dart:convert';
import 'package:car_pool_project/services/networking.dart';
import 'package:prefs/prefs.dart';

class Car {
  int? id;
  int? userID;
  String? brand;
  String? model;
  String? vehicleRegistration;
  String? color;

  Car({
    this.id,
    this.userID,
    this.brand,
    this.model,
    this.vehicleRegistration,
    this.color,
  });

  static Future<List<Car>?> getCars() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('cars', {});
    List<Car> cars = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['cars']) {
        Car car = Car(
          id: t['id'],
          userID: t['user_id'],
          brand: t['brand'],
          model: t['model'],
          vehicleRegistration: t['vehicle_registration'],
          color: t['color'],
        );
        cars.add(car);
      }
      return cars;
    }
    return null;
  }

  static Future<Car?> addCar(Car car) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('cars/add_car', {});
    var json = await networkHelper.postData(
        jsonEncode(<String, dynamic>{
          'brand': car.brand,
          'model': car.model,
          'vehicle_registration': car.vehicleRegistration,
          'color': car.color,
        }),
        token);

    if (json != null && json['error'] == false) {
      Map t = json['car'];
      Car car = Car(
        id: t['id'],
        // user_id: t['user_id'],
        brand: t['brand'],
        model: t['model'],
        vehicleRegistration: t['vehicle_registration'],
        color: t['color'],
      );
      return car;
    }
    return null;
  }

  static Future<Car?> editCar(Car car) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('cars/edit_car', {});
    var json = await networkHelper.postData(
        jsonEncode(<String, dynamic>{
          'id': car.id,
          'brand': car.brand,
          'model': car.model,
          'vehicle_registration': car.vehicleRegistration,
          'color': car.color,
        }),
        token);

    if (json != null && json['error'] == false) {
      Map t = json['car'];
      Car car = Car(
        id: t['id'],
        // user_id: t['user_id'],
        brand: t['brand'],
        model: t['model'],
        vehicleRegistration: t['vehicle_registration'],
        color: t['color'],
      );
      return car;
    }
    return null;
  }

  static Future<Car?> deleteCar(int carID) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('cars/delete_car', {});
    var json = await networkHelper.postData(
        jsonEncode(<String, dynamic>{'id': carID}), token);
    if (json != null && json['error'] == false) {
      Map t = json['car'];
      Car car = Car(
        id: t['id'],
        // user_id: t['user_id'],
        brand: t['brand'],
        model: t['model'],
        vehicleRegistration: t['vehicle_registration'],
        color: t['color'],
      );
      // return true;
      return car;
    }
    return null;
  }
}
