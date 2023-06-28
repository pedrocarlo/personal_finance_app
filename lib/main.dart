import 'dart:io';
import 'card_utils.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
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
  String _pdfText = '';
  List<String> _pdfList = [];
  int _pdfLength = 0;

  bool _loading = false;
  bool _paginated = false;
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
                  getPDFtextPaginated(file.path).then((pdfList) {
                    List<String> list = <String>[];
                    // Remove new lines
                    pdfList.forEach((element) {
                      list.add(element.replaceAll("\n", " "));
                    });

                    getPDFtext(file.path).then((pdfText) {
                      text = pdfText;
                    });

                    setState(() {
                      _pdfText = text;
                      _pdfList = list;
                      _paginated = false;
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
                    child: _paginated
                        ? ListView.builder(
                            itemCount: _pdfList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      _pdfList[index],
                                    ),
                                  ),
                                ),
                              );
                            })
                        : SingleChildScrollView(
                            child: Text(_pdfText),
                          ),
                  )
          ],
        ),
      ),
    );
  }
}

// Gets all the text from a PDF document, returns it in string.
Future<String> getPDFtext(String path) async {
  String text = "";
  try {
    //Load an existing PDF document.
    final PdfDocument document = PdfDocument(
        inputBytes: File(path).readAsBytesSync(), password: "12936");
    //Extract the text from all the pages.
    //Get the document security.
    PdfSecurity security = document.security;
    //Set owner and user passwords to empty.
    security.ownerPassword = '';
    String text = PdfTextExtractor(document)
        .extractText(startPageIndex: 1, endPageIndex: 1);
    //Dispose the document.
    document.dispose();
    // text = await ReadPdfText.getPDFtext(path);
    await itauCard(text);
    // List<RegExpMatch> matches = await portoCard(text);
  } on PlatformException {
    print("Failed to get PDF text.");
  }
  return text;
}

// Gets all the text from PDF document, returns it in array where each element is a page of the document.
Future<List<String>> getPDFtextPaginated(String path) async {
  return ["teste"];
  List<String> textList = <String>[];
  try {
    textList = await ReadPdfText.getPDFtextPaginated(path);
  } on PlatformException {
    print("Failed to get PDF text.");
  }
  return textList;
}
