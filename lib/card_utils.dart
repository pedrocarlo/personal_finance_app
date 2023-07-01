import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';

import 'package:path_provider/path_provider.dart';

/// Print Long String
void printLongString(String text) {
  final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern
      .allMatches(text)
      .forEach((RegExpMatch match) => print(match.group(0)));
}

// Eventually make this become a model in sqluentify
class Transaction extends Equatable implements Comparable<Transaction> {
  final DateTime date;
  final String name;
  final String value;
  final String parcela;
  const Transaction(this.date, this.name, this.value, [this.parcela = ""]);

  @override
  String toString() {
    return """${DateFormat('dd/MM').format(date)} $name $value${(parcela != '') ? " $parcela" : ""}""";
  }

  @override
  // Return 0 if equivalent else if parcelado return which is greater in parcelas
  int compareTo(Transaction other) {
    if (date.compareTo(other.date) +
                name.compareTo(other.name) +
                value.compareTo(other.value) ==
            0 &&
        parcela != "" &&
        other.parcela != "") {
      String parcela = this.parcela.substring(0, 2);
      String qnt = this.parcela.substring(3, 5); // quantidade de parcelas
      String otherPar = other.parcela.substring(0, 2);
      String otherQnt = other.parcela.substring(3, 5); // quantidade de parcelas
      if (qnt == otherQnt) {
        return parcela.compareTo(otherPar);
      }
    }
    return date.compareTo(other.date) +
        name.compareTo(other.name) +
        value.compareTo(other.value);
  }

  @override
  List<Object> get props => [name, value, date];
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
  // print('going to print matches');
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

    Transaction tr = Transaction(date, name!, money!);
    // print(date);
    // print(name);
    // print(money);
  }
  return matchList;
}

Future<List<Transaction>> itauCard(String pdfText) async {
  List<Transaction> transactions = [];
  HashMap<Transaction, List<Transaction>> trsParcelas =
      HashMap(); // needs to be a dict

  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/itau.txt');
  await file.writeAsString(pdfText);
  String paymentsRegex = r"(?=\d\d\/\d\d).*(?=Programa)";
  RegExp paymentsExp = RegExp(paymentsRegex);
  String listPayRegex = r'\d{2}\/\d{2}[^,\s]+\d{0,3}(?:,\d{2})';
  RegExp listPayExp = RegExp(listPayRegex);
  String? payments = paymentsExp.firstMatch(pdfText)!.group(0);
  String dateRegex = r'^(\d\d\/\d\d)';
  String moneyRegex = r'(?:\d\d\/\d\d)?(-?[\d,\.]+(\.\d*)?$)';
  String nameRegex = r'(?<=^\d\d\/\d\d)\D*(?=\d)';
  String parcelaRegex =
      r'(?!^\d\d\/\d\d)\d\d\/\d\d'; // Pegar se é parcelado a compra
  Iterable<RegExpMatch>? listPay;
  if (payments != null) {
    listPay = listPayExp.allMatches(payments);
  }
  if (listPay != null) {
    for (final pay in listPay) {
      String? strDate = RegExp(dateRegex).firstMatch(pay[0]!)!.group(0)!;
      String day = strDate.substring(0, 2);
      String month = strDate.substring(3, 5);
      String year = "2023";
      DateTime date = DateTime.parse('$year-$month-$day').toLocal();

      String? money = RegExp(moneyRegex).firstMatch(pay[0]!)!.group(1);
      String? name = RegExp(nameRegex).firstMatch(pay[0]!)!.group(0);
      String parcela = RegExp(parcelaRegex).firstMatch(pay[0]!)?.group(0) ?? "";
      Transaction tr = Transaction(date, name!, money!, parcela);
      if (parcela != "") {
        final lst = trsParcelas.putIfAbsent(tr, () => []);
        lst.add(tr);
      } else {
        transactions.add(tr);
      }
    }
  }
  for (List<Transaction> trLst in trsParcelas.values) {
    trLst = [
      trLst.reduce((curr, next) => curr.compareTo(next) < 0 ? curr : next)
    ];
    transactions.addAll(trLst);
  }
  transactions.sort(((a, b) => a.date.compareTo(b.date)));
  return transactions;
}
