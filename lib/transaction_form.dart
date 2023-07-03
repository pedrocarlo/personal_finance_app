import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:personal_finance_app/card_utils.dart';
import 'package:personal_finance_app/panel_controller.dart';
import 'package:personal_finance_app/transaction_panel.dart';

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

  @override
  void initState() {
    controllers.addAll(panelController.createTextControllers());
    final dateController = controllers[0];
    final nameController = controllers[1];
    final valueController = controllers[2];
    dateController.text = DateFormat('dd/MM').format(widget.trObs.value.date);
    nameController.text = widget.trObs.value.name;
    valueController.text = widget.trObs.value.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dateController = controllers[0];
    final nameController = controllers[1];
    final valueController = controllers[2];
    const decoration = InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0));
    return Form(
        key: _formKey,
        child: ListView(
          children: [
            Container(
              height: 15,
              alignment: Alignment.center,
            ),
            Container(
              child: TextFormField(
                decoration: decoration,
                // style: const TextStyle(color: Colors.teal),
                textAlign: TextAlign.end,
                controller: valueController,
              ),
            ),
            Divider(),
            // TODO add dividers to make it cleaner
            Container(
              child: Column(
                children: [
                  TextFormField(
                    decoration: decoration,
                    controller: nameController,
                  ),
                  TextFormField(
                    decoration: decoration,
                    controller: dateController,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          String strDate = dateController.text;
                          String day = strDate.substring(0, 2);
                          String month = strDate.substring(3, 5);
                          String year = "2023";
                          DateTime date =
                              DateTime.parse('$year-$month-$day').toLocal();
                          Transaction tr = Transaction(
                              date, nameController.text, valueController.text);
                          widget.trObs.value = tr;
                          // print(widget.step.tr);
                        }
                      },
                      child: Text('Submit'))
                ],
              ),
            ),
          ],
        ));
  }
}
