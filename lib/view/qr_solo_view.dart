import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../data/home_data.dart';

class QrSoloView extends StatefulWidget {
  const QrSoloView({super.key, required this.id});
  final String id;

  @override
  State<QrSoloView> createState() => _QrSoloViewState();
}

class _QrSoloViewState extends State<QrSoloView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var instance = Provider.of<HomeData>(context, listen: false);
      await instance.getSoloEmployee(employeeId: widget.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeData>(
        builder: ((context, provider, child) {
          final String name = provider.fullName(provider.soloEmployeeList);
          if (provider.isSoloLoading) {
            return const Center(
                child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Loading..'),
                SizedBox(width: 5.0),
                CircularProgressIndicator(),
              ],
            ));
          } else if (provider.soloEmployeeList.employeeId == '00000') {
            return const Center(
                child: Text('ID not found.', style: TextStyle(fontSize: 18.0)));
          } else if (provider.soloEmployeeList.employeeId.isEmpty) {
            return const Center(
                child: Text('Error getting QR.',
                    style: TextStyle(fontSize: 18.0)));
          } else {
            return Center(
              child: SizedBox(
                height: 300.0,
                width: 300.0,
                child: Screenshot(
                  controller: provider.screenshotController,
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QrImageView(
                            data:
                                '{"name":"${provider.fullName(provider.soloEmployeeList)}","id":"${provider.soloEmployeeList.employeeId}"}',
                            version: QrVersions.auto,
                            size: 225.0,
                            semanticsLabel:
                                provider.fullName(provider.soloEmployeeList),
                            backgroundColor: Colors.white,
                          ),
                          Text(
                            name,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Download',
        child: const Icon(Icons.download),
        onPressed: () async {
          var instance = Provider.of<HomeData>(context, listen: false);
          await instance.captureQrImage(
              fileName: instance.fullName(instance.soloEmployeeList));
        },
      ),
    );
  }
}
