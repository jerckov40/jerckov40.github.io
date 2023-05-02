import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart' as pdfgen;
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';

pw.Widget barcode(
  pw.Barcode barcode,
  String data, {
  double width = 100,
  double height = 40,
  double vertical = 20,
}) =>
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: <pw.Widget>[
        pw.Flexible(
          fit: pw.FlexFit.tight,
          child: pw.Center(
            child: pw.BarcodeWidget(
              barcode: barcode,
              data: data,
              width: width,
              height: height,
              margin: pw.EdgeInsets.symmetric(vertical: vertical),
              textStyle: const pw.TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );

Future<bool> createPdf(
  List<pw.Page> pages,
  String filepath,
) async {
  try {
    final pdf = pw.Document();
    for (final page in pages) {
      pdf.addPage(page);
    }
    final bytes = await pdf.save();
    if (!kIsWeb) {
      final file = File(filepath);
      final test = await file.writeAsBytes(bytes);
      return test.path.isNotEmpty;
    } else {
      final content = base64Encode(bytes);
      html.AnchorElement(
        href: "data:application/octet-stream;charset=utf-16le;base64,$content",
      )
        ..setAttribute("download", filepath)
        ..click();
      return true;
    }
  } catch (err) {
    if (kDebugMode) {
      print(err.toString());
    }
    return false;
  }
}

Future<String> printCode(String code) async {
  try {
    final pw.Page page = pw.Page(
      pageFormat: pdfgen.PdfPageFormat.roll80,
      clip: true,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Test Code $code',
              textScaleFactor: 0.7,
              style: const pw.TextStyle(
                fontSize: 12,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Header(level: 0, child: pw.Container()),
            barcode(
              pw.Barcode.code128(),
              code,
            ),
          ],
        );
      },
    );
    String path = '';
    if (!kIsWeb) {
      path = '${(await getApplicationDocumentsDirectory()).path}/';
    }
    final filepath = '$path$code.pdf';
    return await createPdf([page], filepath) ? filepath : '';
  } catch (err) {
    if (kDebugMode) {
      print(err.toString());
    }
    return '';
  }
}
