import 'package:flutter/material.dart';
import 'package:generateqr/model/department_model.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../data/home_data.dart';
import '../model/employee_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final idController = TextEditingController();
  final scrollController = ScrollController();
  var dropdownValue =
      DepartmentModel(departmentId: '666', departmentName: '--Select--');
  final allDepartment =
      DepartmentModel(departmentId: '000', departmentName: 'All');

  @override
  void initState() {
    super.initState();
    var instance = Provider.of<HomeData>(context, listen: false);
    instance.departmentList.add(dropdownValue);
    instance.departmentList.add(allDepartment);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await instance.getDepartment();
    });
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'Generate QR';

    Future<void> showQrDialog({
      required EmployeeModel employee,
    }) async {
      var instance = Provider.of<HomeData>(context, listen: false);
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Download QR'),
            content: SizedBox(
              height: 300.0,
              width: 300.0,
              child: Screenshot(
                controller: instance.screenshotController,
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: QrImageView(
                      data:
                          '{"name":"${instance.nameSingle(employee)}","id":"${employee.employeeId}"}',
                      version: QrVersions.auto,
                      size: 225.0,
                      semanticsLabel: instance.nameSingle(employee),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Download',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  await instance
                      .captureQrImage(fileName: instance.nameSingle(employee))
                      .then((_) => Navigator.of(context).pop());
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(title),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10.0),
                Consumer<HomeData>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const CircularProgressIndicator();
                    }
                    return SizedBox(
                      height: 175.0,
                      width: 800.0,
                      child: Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    'Department: ',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  Container(
                                    width: 500.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.blue,
                                        style: BorderStyle.solid,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<DepartmentModel>(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        borderRadius: BorderRadius.circular(5),
                                        value: dropdownValue,
                                        onChanged:
                                            (DepartmentModel? value) async {
                                          if (value != null) {
                                            setState(() {
                                              dropdownValue = value;
                                            });
                                            await provider.getEmployee(
                                                departmentId:
                                                    dropdownValue.departmentId);
                                            if (provider.isSearching) {
                                              idController.clear();
                                              provider.clearSearchList();
                                            }
                                          }
                                        },
                                        items: provider.departmentList.map<
                                                DropdownMenuItem<
                                                    DepartmentModel>>(
                                            (DepartmentModel value) {
                                          return DropdownMenuItem<
                                              DepartmentModel>(
                                            value: value,
                                            child: Text(value.departmentName),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15.0),
                              SizedBox(
                                width: 690.0,
                                child: TextField(
                                  enabled: true,
                                  style: const TextStyle(fontSize: 20.0),
                                  decoration: const InputDecoration(
                                    label: Text('Search name/id..'),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        12.0, 12.0, 12.0, 12.0),
                                  ),
                                  controller: idController,
                                  onChanged: (String value) async {
                                    if (dropdownValue.departmentId != '666') {
                                      if (idController.text.isEmpty) {
                                        provider.changeStateSearching(false);
                                      } else {
                                        provider.changeStateSearching(true);
                                        await provider.searchEmployee(
                                          departmentId:
                                              dropdownValue.departmentId,
                                          employeeId: value.trim(),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Consumer<HomeData>(
                  builder: (context, provider, child) {
                    if (dropdownValue.departmentId != '666') {
                      return SizedBox(
                        height: 50.0,
                        width: 800.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                child: const Text('ID No.'),
                                onTap: () {
                                  provider.sortId();
                                },
                              ),
                              InkWell(
                                child: const Text('NAME'),
                                onTap: () {
                                  provider.sortName();
                                },
                              ),
                              const SizedBox(width: 60.0),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                Consumer<HomeData>(
                  builder: (context, provider, child) {
                    if (provider.isSearching) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 800.0,
                            child: Column(
                              children: provider.searchEmployeeList.map((item) {
                                return Card(
                                  child: ListTile(
                                    titleAlignment:
                                        ListTileTitleAlignment.center,
                                    leading: Text(item.employeeId),
                                    title: Text(
                                      provider.nameSingle(item),
                                      textAlign: TextAlign.center,
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () async {
                                        await showQrDialog(employee: item);
                                      },
                                      splashRadius: 15.0,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Text(
                            'Showing ${provider.searchEmployeeList.length} search results.',
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 800.0,
                            child: Column(
                              children: provider.employeeList.map((item) {
                                return Card(
                                  child: ListTile(
                                    titleAlignment:
                                        ListTileTitleAlignment.center,
                                    leading: Text(item.employeeId),
                                    title: Text(
                                      provider.nameSingle(item),
                                      textAlign: TextAlign.center,
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () async {
                                        await showQrDialog(employee: item);
                                      },
                                      splashRadius: 15.0,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          if (provider.employeeList.length <
                              provider.rowCount) ...[
                            SizedBox(
                              height: 50.0,
                              width: 200.0,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.green[300],
                                ),
                                onPressed: () async {
                                  await provider.loadMore(
                                    id: provider.employeeList.last.id,
                                    departmentId: dropdownValue.departmentId,
                                  );
                                },
                                child: const Text(
                                  'Load more..',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (dropdownValue.departmentId != '666') ...[
                            const SizedBox(height: 15.0),
                            Text(
                              'Showing ${provider.employeeList.length} out of ${provider.rowCount} results.',
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 50.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
