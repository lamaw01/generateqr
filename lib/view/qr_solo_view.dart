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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var instance = Provider.of<HomeData>(context, listen: false);
      instance.getSoloEmployee(employeeId: widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeData>(
        builder: ((context, provider, child) {
          if (provider.isSoloLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.soloEmployeeList == null) {
            return const Center(child: Text('Error getting QR'));
          } else {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 300.0,
                    width: 300.0,
                    child: Screenshot(
                      controller: provider.screenshotController,
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: QrImageView(
                            data:
                                '{"name":"${provider.fullName(provider.soloEmployeeList!)}","id":"${provider.soloEmployeeList!.id}"}',
                            version: QrVersions.auto,
                            size: 225.0,
                            semanticsLabel:
                                provider.fullName(provider.soloEmployeeList!),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}
