import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:personal_finance_app/card_utils.dart';
import 'package:personal_finance_app/model/model.dart';
import 'package:personal_finance_app/panel_controller.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class TransactionForm extends StatefulWidget {
  final Rx<Transaction> trObs;
  const TransactionForm({super.key, required this.trObs});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final panelController = Get.put(PanelController());
  final controllers = [];
  final String initialDate = '';

  @override
  void initState() {
    controllers.addAll(panelController.createTextControllers());
    final nameController = controllers[0];
    final valueController = controllers[1];
    nameController.text = widget.trObs.value.name;
    valueController.text = widget.trObs.value.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              ListTile(
                contentPadding:
                    const EdgeInsetsDirectional.symmetric(horizontal: 10.0),
                // TODO have it that clicking anywhere on the listtile can edit the text field
                trailing: const Icon(Icons.draw_rounded),
                title: TextFormField(
                  decoration: const InputDecoration(border: InputBorder.none),
                  controller: nameController,
                  style: const TextStyle(fontSize: 32.0),
                ),
              ),
              // Container(
              //   height: 15,
              //   alignment: Alignment.center,
              // ),
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

InputDecoration description(String text) {
  return InputDecoration(
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 25));
  // return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //     child: Align(alignment: Alignment.centerLeft, child: Text(text)));
}

TextFormField valueField(TextEditingController valueController) {
  return TextFormField(
    decoration: description("Valor"),
    inputFormatters: [
      CurrencyTextInputFormatter(decimalDigits: 2, locale: "pt-BR", name: "")
    ],
    keyboardType: TextInputType.number,
    textAlign: TextAlign.right,
    controller: valueController,
    style: const TextStyle(
        inherit: true, fontSize: 30, fontWeight: FontWeight.bold),
  );
}

ListTile categoriaTile(BuildContext context) {
  return ListTile(
    contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 10.0),
    // TODO have it that clicking anywhere on the listtile can edit the text field
    leading: const Icon(Icons.draw_rounded),
    title: TextFormField(
      decoration: const InputDecoration(border: InputBorder.none),
      // controller: nameController,
      initialValue: "TESTE CATEGORIA",
    ),
  );
}

ListTile dateTile(BuildContext context, Rx<String> initialDate) {
  return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 10.0),
      leading: const Icon(Icons.calendar_month_rounded),
      title: Obx(() => Text(initialDate.value)),
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
        String year = "2023";
        DateTime date = DateTime.parse('$year-$month-$day').toLocal();
        Transaction tr = Transaction(
            date,
            nameController.text,
            valueController.text,
            widget.trObs.value.fatura,
            widget.trObs.value.parcela);
        widget.trObs.value = tr;
        // print(widget.step.tr);
      }
    },
    icon: const Icon(Icons.check_circle),
    iconSize: 60,
  );
}
