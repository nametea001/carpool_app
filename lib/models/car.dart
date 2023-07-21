import 'dart:convert';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';

class Car {
  int? id;
  int? user_id;
  String? brand;
  String? model;
  String? vehicleRegistration;
  String? color;

  Car({
    this.id,
    this.user_id,
    this.brand,
    this.model,
    this.vehicleRegistration,
    this.color,
  });

  static Future<List<Car>?> getCars(
    String token,
  ) async {
    NetworkHelper networkHelper = NetworkHelper('cars', {});
    List<Car> cars = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['cars']) {
        Car car = Car(
          id: t['id'],
          user_id: t['user_id'],
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

  static Future<Car?> addCar(String token, Car car) async {
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
      ;
      return car;
    }
    return null;
  }
}
