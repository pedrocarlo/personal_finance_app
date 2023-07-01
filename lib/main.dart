import 'dart:io';
import 'card_utils.dart';
import 'transaction_panel.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String text = "";
  List<Transaction> _trList = [];

  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Test"),
        ),
        bottomNavigationBar: BottomNavigationBar(items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: "Business")
        ]),
        body: Column(
          children: [
            ElevatedButton(
              child: const Text("Choose PDF"),
              onPressed: () async {
                final FilePickerResult? result =
                    await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null) {
                  File file = File(result.files.single.path ?? "");
                  // This example uses file picker to get the path
                  setState(() {
                    _loading = true;
                  });
                  // Call the function to parse text from pdf
                  getPDFtext(file.path).then((trList) {
                    setState(() {
                      _trList = trList;
                      _loading = false;
                    });
                  });
                }
              },
            ),
            _loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    // Check if returning text page by page or the whole document as one string
                    child: Panels(steps: tr2Step(_trList)),
                  )
          ],
        ),
      ),
    );
  }
}

// Gets all the text from a PDF document, returns it in string.
Future<List<Transaction>> getPDFtext(String path) async {
  // StringBuffer ret = StringBuffer();
  List<Transaction> trs = [];
  try {
    //Load an existing PDF document.
    final PdfDocument document = PdfDocument(
        inputBytes: File(path).readAsBytesSync(), password: "12936");
    PdfSecurity security = document.security;
    security.ownerPassword = '';
    String text = PdfTextExtractor(document)
        .extractText(startPageIndex: 1, endPageIndex: 1);
    // document.save();
    //Dispose the document.
    document.dispose();
    trs = await itauCard(text);
    // for (final tr in trs) {
    //   ret.write('${tr.toString()}\n');
    // }
    // List<RegExpMatch> matches = await portoCard(text);
  } on PlatformException {
    print("Failed to get PDF text.");
  }
  return trs;
}

List<Panel> tr2Step(List<Transaction> trs) {
  return trs.map<Panel>((Transaction tr) => Panel(tr)).toList();
}
