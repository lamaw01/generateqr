import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

import '../model/department_model.dart';
import '../model/employee_model.dart';
import '../services/http_services.dart';

class HomeData with ChangeNotifier {
  final screenshotController = ScreenshotController();
  final _departmentList = <DepartmentModel>[];
  List<DepartmentModel> get departmentList => _departmentList;
  var _isLoading = true;
  bool get isLoading => _isLoading;
  final _employeeList = <EmployeeModel>[];
  List<EmployeeModel> get employeeList => _employeeList;
  var _rowCount = 0;
  int get rowCount => _rowCount;

  void sortId() {
    _employeeList.replaceRange(0, _employeeList.length, _employeeList.reversed);
    notifyListeners();
    debugPrint(_employeeList.first.name);
  }

  void sortName() {
    _employeeList.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    notifyListeners();
    debugPrint(_employeeList.first.name);
  }

  Future<void> captureQrImage({required String fileName}) async {
    await screenshotController
        .capture(delay: const Duration(seconds: 1))
        .then((Uint8List? result) async {
      debugPrint(result.toString());
      if (result != null) {
        downloadQrImage(
          bytes: result,
          downloadName: '$fileName.png',
        );
      }
    }).catchError((Object err) {
      debugPrint(err.toString());
    });
  }

  void downloadQrImage({
    required List<int> bytes,
    required String downloadName,
  }) {
    // Encode our file in base64
    final base64 = base64Encode(bytes);
    // Create the link with the file
    final anchor =
        AnchorElement(href: 'data:application/octet-stream;base64,$base64')
          ..target = 'blank';
    // add the name
    anchor.download = downloadName;
    // trigger download
    document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    return;
  }

  Future<void> getDepartment() async {
    try {
      final result = await HttpService.getDepartment();
      _departmentList.addAll(result);
    } catch (e) {
      debugPrint('$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getEmployee({required String departmentId}) async {
    try {
      final result = await HttpService.getEmployee(departmentId: departmentId);
      _employeeList.replaceRange(0, _employeeList.length, result);
      _rowCount =
          await HttpService.getEmployeeCount(departmentId: departmentId);
      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> searchEmployee({
    required String departmentId,
    required String employeeId,
  }) async {
    try {
      final result = await HttpService.searchEmployee(
        departmentId: departmentId,
        employeeId: employeeId,
      );
      _employeeList.replaceRange(0, _employeeList.length, result);
      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> loadMore({
    required String id,
    required String departmentId,
    required String employeeId,
  }) async {
    try {
      final result = await HttpService.loadMore(
        id: id,
        departmentId: departmentId,
        employeeId: employeeId,
      );
      _employeeList.addAll(result);
      notifyListeners();
    } catch (e) {
      debugPrint('$e');
    }
  }
}
