import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app/card_utils.dart';
import 'package:personal_finance_app/panel_controller.dart';
import 'package:personal_finance_app/transaction_panel.dart';
import 'package:get/get.dart';

class TransactionForm extends StatefulWidget {
  final Panel step;
  const TransactionForm({Key? key, required this.step}) : super(key: key);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> controllerLst = [];
  final panelController = Get.find<PanelController>();

  final InputDecoration inputDecor = const InputDecoration(
      border: UnderlineInputBorder(), focusedBorder: InputBorder.none);

  @override
  Widget build(BuildContext context) {
    final controllers = panelController.createTextControllers();
    final dateController = controllers[0];
    final nameController = controllers[1];
    final valueController = controllers[2];
    dateController.text = DateFormat('dd/MM').format(widget.step.tr.date);
    nameController.text = widget.step.tr.name;
    valueController.text = widget.step.tr.value;
    return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(controller: dateController, decoration: inputDecor),
            TextFormField(
              controller: nameController,
              decoration: inputDecor,
            ),
            TextFormField(controller: valueController, decoration: inputDecor),
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
                    widget.step.tr = Transaction(
                        date, nameController.text, valueController.text);
                  }
                },
                child: const Text("Apply"))
          ],
        ));
  }
}
