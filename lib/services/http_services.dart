import 'dart:convert';

// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/department_model.dart';
import '../model/employee_model.dart';
import '../model/solo_employee_model.dart';

class HttpService {
  static String currentUri = Uri.base.toString();
  static String isSecured = currentUri.substring(4, 5);

  static const String _serverUrlHttp = 'http://103.62.153.74:53000/';
  String get serverUrlHttp => _serverUrlHttp;

  static const String _serverUrlHttps = 'https://konek.parasat.tv:50443/dtr/';
  String get serverUrlHttps => _serverUrlHttps;

  static final String _url =
      isSecured == 's' ? _serverUrlHttps : _serverUrlHttp;

  static final String _serverUrl = '${_url}generate_qr_api';
  static String get serverUrl => _serverUrl;

  // static const String _serverUrl = 'http://103.62.153.74:53000/generate_qr_api';

  static Future<List<DepartmentModel>> getDepartment() async {
    var response = await http.get(
      Uri.parse('$_serverUrl/get_department.php'),
      headers: <String, String>{
        'Accept': '*/*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).timeout(const Duration(seconds: 10));
    // debugPrint('getDepartment ${response.body}');
    return departmentModelFromJson(response.body);
  }

  static Future<List<EmployeeModel>> getEmployee(
      {required String departmentId}) async {
    var response = await http
        .post(
          Uri.parse('$_serverUrl/get_employee.php'),
          headers: <String, String>{
            'Accept': '*/*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(
            <String, dynamic>{
              'department_id': departmentId,
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    // debugPrint('getEmployee ${response.body}');
    return employeeModelFromJson(response.body);
  }

  // static Future<int> getEmployeeCount({
  //   required String departmentId,
  // }) async {
  //   var response = await http
  //       .post(
  //         Uri.parse('$_serverUrl/get_employee_count.php'),
  //         headers: <String, String>{
  //           'Accept': '*/*',
  //           'Content-Type': 'application/json; charset=UTF-8',
  //         },
  //         body: json.encode(
  //           <String, dynamic>{'department_id': departmentId},
  //         ),
  //       )
  //       .timeout(const Duration(seconds: 10));
  //   // debugPrint('getEmployeeCount ${response.body}');
  //   return json.decode(response.body)['count'];
  // }

  static Future<List<EmployeeModel>> searchEmployee(
      {required String departmentId, required String employeeId}) async {
    var response = await http
        .post(
          Uri.parse('$_serverUrl/search_employee.php'),
          headers: <String, String>{
            'Accept': '*/*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(
            <String, dynamic>{
              'department_id': departmentId,
              'employee_id': employeeId,
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    // debugPrint('searchEmployee ${response.body}');
    return employeeModelFromJson(response.body);
  }

  // static Future<List<EmployeeModel>> loadMore(
  //     {required String id, required String departmentId}) async {
  //   var response = await http
  //       .post(
  //         Uri.parse('$_serverUrl/load_more.php'),
  //         headers: <String, String>{
  //           'Accept': '*/*',
  //           'Content-Type': 'application/json; charset=UTF-8',
  //         },
  //         body: json.encode(
  //           <String, dynamic>{
  //             'id': id,
  //             'department_id': departmentId,
  //           },
  //         ),
  //       )
  //       .timeout(const Duration(seconds: 10));
  //   // debugPrint('loadMore ${response.body}');
  //   return employeeModelFromJson(response.body);
  // }

  static Future<SoloEmployeeModel> getSoloEmployee(
      {required String employeeId}) async {
    var response = await http
        .post(
          Uri.parse('$_serverUrl/get_solo_employee.php'),
          headers: <String, String>{
            'Accept': '*/*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(
            <String, dynamic>{
              'employee_id': employeeId,
            },
          ),
        )
        .timeout(const Duration(seconds: 10));
    // debugPrint('getSoloEmployee ${response.body}');
    return soloEmployeeModelFromJson(response.body);
  }
}
