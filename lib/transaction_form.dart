import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:personal_finance_app/card_utils.dart';
import 'package:personal_finance_app/category_page.dart';
import 'package:personal_finance_app/model/model.dart';
import 'package:personal_finance_app/category_default.dart';
import 'package:personal_finance_app/panel_controller.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class TransactionForm extends StatefulWidget {
  final Rx<Transaction> trObs;
  final String originalName;
  final RxString panelName;
  const TransactionForm(
      {super.key,
      required this.trObs,
      required this.originalName,
      required this.panelName});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final panelController = Get.put(PanelController());
  final controllers = <TextEditingController>[];
  final String initialDate = '';

  @override
  void initState() {
    var hMap = panelController.name2ProductMap;
    controllers.addAll(panelController.createTextControllers());
    final nameController = controllers[0];
    final valueController = controllers[1];

    nameController.text = hMap.containsKey(widget.originalName)
        ? hMap[widget.originalName] ?? ""
        : widget.trObs.value.name;
    valueController.text = widget.trObs.value.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    printIcon();
    // panelController.testHashMap();
    print(panelController.name2ProductMap);
    Rx<String> initialDate =
        DateFormat('dd/MM/yyyy').format(widget.trObs.value.date).obs;
    TextEditingController nameController = controllers[0];
    TextEditingController valueController = controllers[1];
    const decoration = InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 30));
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 10.0, vertical: 8),
          child: Column(
            children: [
              nameTile(nameController),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  // height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                          colors: <Color>[
                            Colors.green,
                            Colors.green.shade300,
                            Colors.greenAccent
                          ])),
                  child: Column(
                    children: [
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: valueField(valueController),
                      ),
                      dateTile(context, initialDate),
                      const Text(
                          "Change Categoria probably to bottom sheet that can select icons"),
                      categoriaTile(context),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: submitButton(context, _formKey, initialDate,
                            nameController, valueController, widget),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// Write functions here

InputDecoration description(String text, double fontSize) {
  return InputDecoration(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 25));
}

ListTile nameTile(TextEditingController nameController) {
  return ListTile(
    contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 10.0),
    trailing: const Icon(Icons.draw_rounded),
    title: TextFormField(
      decoration: const InputDecoration(border: InputBorder.none),
      controller: nameController,
      style: const TextStyle(fontSize: 32.0),
    ),
  );
}

TextFormField valueField(TextEditingController valueController) {
  return TextFormField(
    decoration: description("Valor", 25.0),
    inputFormatters: [
      CurrencyTextInputFormatter(decimalDigits: 2, locale: "pt-BR", name: "")
    ],
    keyboardType: TextInputType.number,
    textAlign: TextAlign.right,
    controller: valueController,
    style: const TextStyle(
        inherit: true, fontSize: 46, fontWeight: FontWeight.bold),
  );
}

ListTile categoriaTile(BuildContext context) {
  return ListTile(
    contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 10.0),
    // TODO have it that clicking anywhere on the listtile can edit the text field
    leading: const Icon(
      Icons.draw_rounded,
      size: 25.0,
    ),
    title: const Text('Escolha a sua Categoria'),
    // title: TextFormField(
    //   style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
    //   decoration: const InputDecoration(border: InputBorder.none),
    //   // controller: nameController,
    //   initialValue: "TESTE CATEGORIA",
    // ),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(),
      ),
    ),
  );
}

ListTile dateTile(BuildContext context, Rx<String> initialDate) {
  return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 10.0),
      leading: const Icon(
        Icons.calendar_month_rounded,
        size: 25.0,
      ),
      title: Obx(() => Text(
            initialDate.value,
            style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
          )),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100));
        if (pickedDate != null) {
          initialDate.value = DateFormat('dd/MM/yyyy').format(pickedDate);
        }
      });
}

IconButton submitButton(
    BuildContext context,
    GlobalKey<FormState> formKey,
    Rx<String> initialDate,
    TextEditingController nameController,
    TextEditingController valueController,
    TransactionForm widget) {
  return IconButton(
    onPressed: () {
      // TODO add Validation
      // Validate returns true if the form is valid, or false otherwise.
      if (formKey.currentState!.validate()) {
        String strDate = initialDate.value;
        String day = strDate.substring(0, 2);
        String month = strDate.substring(3, 5);
        String year = widget.trObs.value.due_date.year.toString();
        DateTime date = DateTime.parse('$year-$month-$day').toLocal();
        PanelController.to.name2ProductMap.update(
            widget.originalName, (value) => nameController.text,
            ifAbsent: () => nameController.text);
        widget.panelName.value = nameController.text;
        Transaction tr = Transaction(
            date,
            nameController.text,
            valueController.text,
            widget.trObs.value.fatura,
            widget.trObs.value.parcela,
            widget.trObs.value.due_date);
        widget.trObs.value = tr;
        // print(widget.step.tr);
      }
    },
    icon: const Icon(Icons.check_circle),
    iconSize: 60,
  );
}
