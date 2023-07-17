import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart';
import 'package:personal_finance_app/card_utils.dart';
import 'package:personal_finance_app/model/model.dart';
import 'package:personal_finance_app/panel_controller.dart';
import 'package:personal_finance_app/transaction_form.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

class Panel {
  Panel(this.tr, [this.isExpanded = false]);
  Rx<Transaction> tr;
  bool isExpanded;
}

class Panels extends StatefulWidget {
  final List<Panel> steps;
  const Panels({Key? key, required this.steps}) : super(key: key);
  @override
  State<Panels> createState() => _PanelsState();
}

class _PanelsState extends State<Panels> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedro Seu Extrato"),
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: "Business")
      ]),
      body: _renderSteps(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 26),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: _floatingActionButton(widget)),
      ),
    );
  }

  Widget _renderSteps() {
    final panelController = Get.put(PanelController());
    panelController.steps = widget.steps;
    for (var e in widget.steps) {
      panelController.addName(e.tr.value.name);
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 20.0, crossAxisSpacing: 15.0),
      itemCount: widget.steps.length,
      itemBuilder: (context, index) {
        var hMap = panelController.name2ProductMap;
        var originalName = panelController.nameLst[index];
        final trObs = panelController.steps[index].tr;

        RxString name;
        print('This is the og name: $originalName');
        if (hMap.containsKey(originalName)) {
          String temp = hMap[originalName] ?? '';
          print(temp);
          name = temp.obs;
        } else {
          name = trObs.value.name.obs;
        }
        panelController.addPanelName(name);

        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.deepPurple.shade600.withOpacity(0.6),
                    offset: const Offset(-6, 14),
                    spreadRadius: -6.0)
              ]),
          child: GestureDetector(
            onTap: () => showBarModalBottomSheet(
                expand: true,
                context: context,
                builder: (builder) {
                  final trObs = panelController.steps[index].tr;
                  // ever(trObs, (callback) => print('$callback has changed'));
                  return TransactionForm(
                    trObs: trObs,
                    originalName: panelController.nameLst[index],
                    panelName: panelController.panelNameLst[index],
                  );
                }),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(11.0),
                child: Column(children: [
                  Expanded(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Obx(() => Text(
                              panelController.panelNameLst[index].value,
                              style: const TextStyle(
                                  fontFamily: "Futura",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 17),
                            ))),
                  ),
                  Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: Obx(() => Text(
                              widget.steps[index].tr.value.value,
                              style: const TextStyle(
                                  fontFamily: "Futura",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ))),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Obx(() => Text(
                            DateFormat('dd/MM/yyyy')
                                .format(widget.steps[index].tr.value.date),
                            style: const TextStyle(
                                fontFamily: "Futura",
                                fontWeight: FontWeight.w400,
                                fontSize: 16),
                          )),
                    ),
                  )
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget _floatingActionButton(Panels widget) {
  return FloatingActionButton.extended(
    label: const Text("Submit"),
    onPressed: () async {
      var numberFormat = NumberFormat();

      final List<Cartao> placeholder = [];
      double value;
      for (var e in widget.steps) {
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
            card: "ITAU",
            emission: e.tr.value.emission));
        // TODO CHANGE HERE THE CARD NAME TO BE DYNAMIC
      }
      final results = await Cartao.saveAll(placeholder);

      // TODO remove this after testing
      print(widget.steps[0].tr.value.value);
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
      // TODO add the names here to hashmap
      PanelController.to.serializeMap();
    },
  );
}
