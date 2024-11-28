import 'package:flutter/material.dart';
import 'package:generateqr/model/department_model.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:math' as math;

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
  late DepartmentModel dropdownValue;

  @override
  void initState() {
    super.initState();
    var instance = Provider.of<HomeData>(context, listen: false);
    dropdownValue = instance.departmentList.first;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await instance.getDepartment();
      await instance.getPackageInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QrImageView(
                          data: '{"name":"${instance.nameSingle(employee)}","id":"${employee.employeeId}"}',
                          version: QrVersions.auto,
                          size: 225.0,
                          semanticsLabel: instance.fullName(instance.soloEmployeeList),
                          backgroundColor: Colors.white,
                        ),
                        Text(
                          instance.nameSingle(employee),
                          maxLines: 1,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ],
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

    const String title = 'Generate QR';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Consumer<HomeData>(
          builder: (context, provider, child) {
            var version = 'v${provider.appVersion}';
            return Row(
              children: [
                const Text(title),
                const SizedBox(
                  width: 2.5,
                ),
                Text(
                  version,
                  style: const TextStyle(fontSize: 12.0),
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<HomeData>(
        builder: (context, provider, widget) {
          return Center(
            child: SizedBox(
              width: 500.0,
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverAppBarDelegate(
                      minHeight: 175.0,
                      maxHeight: 175.0,
                      child: SizedBox(
                        height: 175.0,
                        width: 500.0,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Department: ',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    const SizedBox(width: 50.0),
                                    Container(
                                      width: 300.0,
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
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          borderRadius: BorderRadius.circular(5.0),
                                          value: dropdownValue,
                                          onChanged: (DepartmentModel? value) async {
                                            if (value != null) {
                                              setState(() {
                                                dropdownValue = value;
                                              });
                                              await provider.getEmployee(departmentId: dropdownValue.departmentId);
                                              if (provider.isSearching) {
                                                idController.clear();
                                                provider.clearSearchList();
                                              }
                                            }
                                          },
                                          items: provider.departmentList
                                              .map<DropdownMenuItem<DepartmentModel>>((DepartmentModel value) {
                                            return DropdownMenuItem<DepartmentModel>(
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
                                  width: 500.0,
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
                                      contentPadding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                                    ),
                                    controller: idController,
                                    onChanged: (String value) async {
                                      if (dropdownValue.departmentId != '666') {
                                        if (idController.text.isEmpty) {
                                          provider.changeStateSearching(false);
                                        } else {
                                          provider.changeStateSearching(true);
                                          await provider.searchEmployee(
                                            departmentId: dropdownValue.departmentId,
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
                      ),
                    ),
                  ),
                  if (provider.isSearching) ...[
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              titleAlignment: ListTileTitleAlignment.center,
                              leading: Text(provider.searchEmployeeList[index].employeeId),
                              title: Text(
                                provider.nameSingle(provider.searchEmployeeList[index]),
                                textAlign: TextAlign.center,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () async {
                                  await showQrDialog(employee: provider.searchEmployeeList[index]);
                                },
                                splashRadius: 15.0,
                              ),
                            ),
                          );
                        },
                        childCount: provider.searchEmployeeList.length,
                      ),
                    )
                  ] else ...[
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              titleAlignment: ListTileTitleAlignment.center,
                              leading: Text(provider.employeeList[index].employeeId),
                              title: Text(
                                provider.nameSingle(provider.employeeList[index]),
                                textAlign: TextAlign.center,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () async {
                                  await showQrDialog(employee: provider.employeeList[index]);
                                },
                                splashRadius: 15.0,
                              ),
                            ),
                          );
                        },
                        childCount: provider.employeeList.length,
                      ),
                    )
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }
}
