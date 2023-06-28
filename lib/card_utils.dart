import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:developer';

import 'package:path_provider/path_provider.dart';

/// Print Long String
void printLongString(String text) {
  final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern
      .allMatches(text)
      .forEach((RegExpMatch match) => print(match.group(0)));
}

// Eventually make this become a model in sqluentify
class Transaction {
  DateTime date;
  String name;
  // String city;
  // String country;
  String value;
  Transaction(this.date, this.name, this.value);
}

Future<List<RegExpMatch>> portoCard(String pdfText) async {
  String regex =
      r'TOTAL DE GASTOS.*[\r\n]+([\s\S][^\r\n]+[\s\S]*)(?=\nDESPESAS NO EXTERIOR)|TOTAL DE GASTOS.*[\r\n]+([^\r\n]+[\s\S]*)';
  RegExp exp = RegExp(regex, dotAll: false);
  Iterable<RegExpMatch> matches = exp.allMatches(pdfText);
  regex = r'[\r\n]+([^\r\n]+)';
  exp = RegExp(regex, dotAll: false, multiLine: true);
  List<RegExpMatch> matchList = [];
  // better to splitlines fro despesas exterior por causa da conversao de real pra dolar
  // e ir alternando os indexes para pegar so despesas
  for (final m in matches) {
    matchList.addAll(exp.allMatches(m.group(0)!));
    break; // TODO remove break after para ver pagamanetos no exterior
  }
  print('going to print matches');
  List<Transaction> transactions = [];
  LineSplitter splitter = const LineSplitter();
  String cidades = await rootBundle.loadString('assets/cities/municipios.txt');
  final splitCidade = splitter.convert(cidades);
  String combinacao = splitCidade.join("|");
  combinacao = "(?=\\s($combinacao))";
  String nameRegex =
      r'(?<=^\d\d\/\d\d\s).*' + combinacao; // get name before city
  String nameRegex2 = r'^.+(?=\d\d\/\d\d)'; // get for certain regex
  String dateRegex = r'^(\d\d\/\d\d)'; // Gets first date in line
  String moneyRegex =
      r'[-\d,\.]+(\.\d*)?$'; // Gets Money as well as negative value
  String otherPaymentsRegex = r'(?<=^\d\d\/\d\d\s).*(?=\s)';
  RegExp dateExp = RegExp(dateRegex, dotAll: false, multiLine: true);
  final nameExp = RegExp(nameRegex, multiLine: true, caseSensitive: false);
  final nameExp2 = RegExp(nameRegex2, multiLine: true, caseSensitive: false);
  final otherPayExp = RegExp(otherPaymentsRegex, multiLine: true);
  final moneyExp = RegExp(moneyRegex, multiLine: true);
  for (final m in matchList) {
    String? t = m.group(0);
    print(t);
    // EntityExtractor extractor = EntityExtractor();
    // print(await extractor.extract(t!));
    // Getting Date
    String? strDate = dateExp.firstMatch(t!)!.group(0)!;
    String day = strDate.substring(0, 2);
    String month = strDate.substring(3, 5);
    String year = "2023";

    DateTime date = DateTime.parse('$year-$month-$day').toLocal();

    String? name = nameExp.firstMatch(t)?.group(0);
    if (name != null) {
      RegExpMatch? match2 = nameExp2.firstMatch(name);
      if (match2 != null) {
        // se for parcelado cai aqui
        name = match2.group(0);
      }
    } else {
      // aqui cai pagamentos ou taxas de cartao
      name = otherPayExp.firstMatch(t)?.group(0);
    }
    String? money = moneyExp.firstMatch(t)?.group(0);

    print(date);
    print(name);
    print(money);
  }
  return matchList;
}

Future<List<Transaction>> itauCard(String pdfText) async {
  List<Transaction> transactions = [];
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/itau.txt');
  await file.writeAsString(pdfText);
  String paymentsRegex = r"(?=\d\d\/\d\d).*(?=Programa)";
  RegExp paymentsExp = RegExp(paymentsRegex);
  String listPayRegex = r'\d{2}\/\d{2}[^,\s]+\d{0,3}(?:,\d{2})';
  RegExp listPayExp = RegExp(listPayRegex);
  String? payments = paymentsExp.firstMatch(pdfText)!.group(0);
  String dateRegex = r'^(\d\d\/\d\d)';
  String moneyRegex = r'[-\d,\.]+(\.\d*)?$';
  String nameRegex = r'(?<=^\d\d\/\d\d\s).*(?=\s)';
  Iterable<RegExpMatch>? listPay;
  if (payments != null) {
    listPay = listPayExp.allMatches(payments);
  }
  if (listPay != null) {
    for (final pay in listPay) {
      
    }
  }
  // printLongString(pdfText);
  return transactions;
}
