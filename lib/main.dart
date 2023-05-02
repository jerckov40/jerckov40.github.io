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
  final TextEditingController _tfc = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tfc.text = '1713';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _tfc,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  enabled: true,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => printBarcode(),
                child: const Text('Print'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> printBarcode() async {
    final String file = await printCode(_tfc.text);
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
