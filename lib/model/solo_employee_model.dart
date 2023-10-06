// To parse this JSON data, do
//
//     final soloEmployeeModel = soloEmployeeModelFromJson(jsonString);

import 'dart:convert';

SoloEmployeeModel soloEmployeeModelFromJson(String str) =>
    SoloEmployeeModel.fromJson(json.decode(str));

String soloEmployeeModelToJson(SoloEmployeeModel data) =>
    json.encode(data.toJson());

class SoloEmployeeModel {
  int id;
  String employeeId;
  String firstName;
  String lastName;
  String middleName;

  SoloEmployeeModel({
    required this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
  });

  factory SoloEmployeeModel.fromJson(Map<String, dynamic> json) =>
      SoloEmployeeModel(
        id: json["id"],
        employeeId: json["employee_id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        middleName: json["middle_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "employee_id": employeeId,
        "first_name": firstName,
        "last_name": lastName,
        "middle_name": middleName,
      };
}
