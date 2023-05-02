import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_barcode_test/pdfprint.dart';
import 'package:better_open_file/better_open_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => printBarcode(),
              child: const Text('Print'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> printBarcode() async {
    final String file = await printCode('1713');
    if (file.isNotEmpty) await openFile(file);
  }

  Future<void> openFile(String filepath) async {
    try {
      var result = await OpenFile.open(filepath);
      if (result.message.toUpperCase().contains('MANAGE_EXTERNAL_STORAGE')) {
        final filename = filepath.split('/').last;
        final String newpath =
            '${(await getTemporaryDirectory()).path}/$filename';
        await File(filepath).copy(newpath);
        result = await OpenFile.open(newpath);
      }
      if (result.toString().isEmpty) {}
    } catch (err) {
      if (kDebugMode) {
        print(err.toString());
      }
    }
  }
}
