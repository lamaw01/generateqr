import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/department_model.dart';
import '../model/employee_model.dart';

class HttpService {
  static const String _serverUrl =
      'http://uc-1.dnsalias.net:55083/generate_qr_api';

  static Future<List<DepartmentModel>> getDepartment() async {
    var response = await http.get(
      Uri.parse('$_serverUrl/get_department.php'),
      headers: <String, String>{
        'Accept': '*/*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).timeout(const Duration(seconds: 10));
    debugPrint('getDepartment ${response.body}');
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
    debugPrint('getEmployee ${response.body}');
    return employeeModelFromJson(response.body);
  }

  static Future<int> getEmployeeCount({
    required String departmentId,
  }) async {
    var response = await http
        .post(
          Uri.parse('$_serverUrl/get_employee_count.php'),
          headers: <String, String>{
            'Accept': '*/*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(
            <String, dynamic>{'department_id': departmentId},
          ),
        )
        .timeout(const Duration(seconds: 10));

    debugPrint('getEmployeeCount ${response.body}');
    return json.decode(response.body)['count'];
  }

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

    debugPrint('searchEmployee ${response.body}');
    return employeeModelFromJson(response.body);
  }

  static Future<List<EmployeeModel>> loadMore({
    required String id,
    required String departmentId,
    required String employeeId,
  }) async {
    var response = await http
        .post(
          Uri.parse('$_serverUrl/search_employee.php'),
          headers: <String, String>{
            'Accept': '*/*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode(
            <String, dynamic>{
              'id': id,
              'department_id': departmentId,
              'employee_id': employeeId,
            },
          ),
        )
        .timeout(const Duration(seconds: 10));

    debugPrint('loadMore ${response.body}');
    return employeeModelFromJson(response.body);
  }
}
