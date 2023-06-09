import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../data/home_data.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  bool validName = false;
  bool validID = false;

  @override
  Widget build(BuildContext context) {
    var instance = Provider.of<HomeData>(context, listen: false);
    const String title = 'Generate QR';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            SizedBox(
              height: 265.0,
              width: 500.0,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        style: const TextStyle(fontSize: 20.0),
                        decoration: InputDecoration(
                          label: const Text('Name'),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          errorText: validName ? 'Name Can\'t Be Empty' : null,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextField(
                        controller: idController,
                        style: const TextStyle(fontSize: 20.0),
                        decoration: InputDecoration(
                          label: const Text('ID number'),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                          errorText: validID ? 'ID Can\'t Be Empty' : null,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Container(
                        color: Colors.green[300],
                        width: double.infinity,
                        height: 50.0,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              nameController.text.isEmpty
                                  ? validName = true
                                  : validName = false;
                              idController.text.isEmpty
                                  ? validID = true
                                  : validID = false;
                            });
                          },
                          child: const Text(
                            'Generate',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (nameController.text.isNotEmpty &&
                idController.text.isNotEmpty) ...[
              const SizedBox(height: 25.0),
              Screenshot(
                controller: instance.screenshotController,
                child: QrImageView(
                  data:
                      '{"name": "${nameController.text.trim()}","id":"${idController.text.trim()}"}',
                  version: QrVersions.auto,
                  size: 300.0,
                  semanticsLabel: nameController.text.trim(),
                ),
              ),
              const SizedBox(height: 15.0),
              Container(
                color: Colors.green[300],
                height: 50.0,
                width: 300.0,
                child: TextButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        idController.text.isNotEmpty) {
                      await instance.captureQrImage(
                        fileName: nameController.text.trim(),
                      );
                    }
                  },
                  child: const Text(
                    'Download',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
