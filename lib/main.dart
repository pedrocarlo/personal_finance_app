import 'dart:io';
import 'package:get/get.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app/model/model.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'dart:ui' as ui;

import 'card_utils.dart';
import 'transaction_panel.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'package:path/path.dart';

void main() {
  initializeDateFormatting('pt_BR');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(useMaterial3: true), home: const HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String text = "";
  List<Transaction> _trList = [];
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: "Business")
      ]),
      body: ElevatedButton(
        child: const Text("Choose PDF"),
        onPressed: () async {
          final FilePickerResult? result = await FilePicker.platform.pickFiles(
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Panels(steps: tr2Step(trList)),
                ),
              );
            });
          }
        },
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
    // TODO CHANGE how I access pdf with password and change the way to get password
    final PdfDocument document = PdfDocument(
        inputBytes: File(path).readAsBytesSync(), password: "12936");
    PdfSecurity security = document.security;
    security.ownerPassword = '';
    String text = PdfTextExtractor(document)
        .extractText(startPageIndex: 0, endPageIndex: 1);
    // document.save();
    //Dispose the document.
    document.dispose();
    trs = await itauCard(text);
    // TODO SEE HOW TO IMPLEMENT LIKE AN AUTOCOMPLETE FOR

    // final modelManager = EntityExtractorModelManager();
    // const language = EntityExtractorLanguage.portuguese;

    // // String model = "pt_br";
    // final bool response = await modelManager.isModelDownloaded(language.name);
    // if (!response) {
    //   // TODO try catch error here to catch error when cannot download
    //   final bool response = await modelManager.downloadModel(language.name);
    //   print("HAS downloaded? $response");
    // }
    // final entityExtractor = EntityExtractor(language: language);
    // List<EntityAnnotation> annotations = await entityExtractor.annotateText(tr.value);
    // List<List<String>> mlText = [];
    // for (var tr in trs) {
    //   List<String> temp = [];
    //   annotations = await entityExtractor.annotateText(tr.value);
    //   print("TR.NAME");
    //   print(tr.name);

    //   for (final annotation in annotations) {
    //     temp.add(annotation.text);
    //     // for (final entity in annotation.entities) {
    //     //   entity.type;
    //     //   entity.rawValue;
    //     // }
    //   }
    //   mlText.add(temp);
    // }
    // for (var e in mlText) {
    //   print("VALUE NEXT");
    //   print(e);
    // }

    // entityExtractor.close();
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
  return trs.map<Panel>((Transaction tr) => Panel(tr.obs)).toList();
}

// List<Widget> loadingWidgets(bool loading, List<Transaction> trList) {
//   if (loading) {
//     return [const Center(child: CircularProgressIndicator())];
//   }
//   List<Panel> panelLst = tr2Step(trList);
//   return [
//     Expanded(
//         // Check if returning text page by page or the whole document as one string
//         child: Panels(steps: panelLst)),
//     // TODO render this button only with the panels after loading
//   ];
// }
