import 'dart:io';
import 'package:get/get.dart';
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
      theme: ThemeData.dark(useMaterial3: true),
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
            ...loadingWidgets(_loading, _trList),
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

List<Widget> loadingWidgets(bool loading, List<Transaction> trList) {
  if (loading) {
    return [const Center(child: CircularProgressIndicator())];
  }
  List<Panel> panelLst = tr2Step(trList);
  return [
    Expanded(
        // Check if returning text page by page or the whole document as one string
        child: Panels(steps: panelLst)),
    // TODO render this button only with the panels after loading
    ElevatedButton(
        onPressed: () async {
          var numberFormat = NumberFormat();

          final List<Cartao> placeholder = [];
          double value;
          for (var e in panelLst) {
            try {
              value = numberFormat.parse(e.tr.value.value) as double;
            } catch (e) {
              value = 0.0;
            }
            placeholder.add(Cartao(
                date: e.tr.value.date,
                name: e.tr.value.name,
                value: value,
                parcela: e.tr.value.parcela,
                fatura: e.tr.value.fatura,
                card: "ITAU"));
            // TODO CHANGE HERE THE CARD NAME TO BE DYNAMIC
          }
          final results = await Cartao.saveAll(placeholder);

          // TODO remove this after testing
          print(panelLst[0].tr.value.value);
          final productList = await Cartao().select().toList();

          for (int i = 0; i < productList.length; i++) {
            print(productList[i].toMap());
          }

          // LEAVE DATABASE OPEN FOR DEBUGGING
          WidgetsFlutterBinding.ensureInitialized();
          final database = await openDatabase(
            // Set the path to the database. Note: Using the `join` function from the
            // `path` package is best practice to ensure the path is correctly
            // constructed for each platform.
            join(await getDatabasesPath(), 'account.db'),
          );
          database.close();
        },
        child: const Text("Submit"))
  ];
}
