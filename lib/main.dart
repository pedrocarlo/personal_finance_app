import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app/model/model.dart';
import 'package:personal_finance_app/panel_controller.dart';
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
    final panelController = Get.put(PanelController());

    PanelController.to.decodeMap();

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
  // final PanelController _controller = PanelController.to;

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
            TextEditingController controller = TextEditingController(text: "");
            PdfDocument? document;
            RxBool finish = false.obs;
            RxBool cont = true.obs;
            const snackBar = SnackBar(
              content: Text('Senha Invalida'), // TODO ver gramatica
            );
            while (!finish.value && cont.value) {
              document = await getPdf(file.path, controller);
              // TODO change code to see where to put these functions because of context
              if (document == null) {
                await _displayTextInputDialog(
                    context, controller, cont, finish);
              } else {
                finish.value = true;
              }
              if (!finish.value && cont.value) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Senha Inválida'),
                ));
              }
            }
            if (document != null) {
              getPdftext(document).then((trList) {
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
          }
        },
      ),
    );
  }
}

// Gets all the text from a PDF document, returns it in string.
Future<List<Transaction>> getPdftext(PdfDocument document) async {
  // StringBuffer ret = StringBuffer();
  List<Transaction> trs = [];
  try {
    //Load an existing PDF document.
    // TODO CHANGE how I access pdf with password and change the way to get password

    PdfSecurity security = document.security;
    security.ownerPassword = '';
    String text = PdfTextExtractor(document)
        .extractText(startPageIndex: 0, endPageIndex: 1);
    // document.save();
    //Dispose the document.
    document.dispose();
    trs = await itauCard(text);
    // TODO SEE HOW TO IMPLEMENT LIKE AN AUTOCOMPLETE FOR
  } on PlatformException {
    print("Failed to get PDF text.");
  }
  return trs;
}

List<Panel> tr2Step(List<Transaction> trs) {
  return trs.map<Panel>((Transaction tr) => Panel(tr.obs)).toList();
}

Future<PdfDocument?> getPdf(
    String path, TextEditingController controller) async {
  PdfDocument document;
  try {
    document = PdfDocument(
        inputBytes: File(path).readAsBytesSync(), password: controller.text);
  } catch (e) {
    return null;
  }
  return document;
}

Future<void> _displayTextInputDialog(BuildContext context,
    TextEditingController controller, RxBool cont, RxBool finish) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Senha do PDF'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Senha"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('CANCELAR'),
            onPressed: () {
              Navigator.pop(context);
              cont.value = false;
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              // print(_textFieldController.text);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
