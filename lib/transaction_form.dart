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
        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0));
    return Form(
        key: _formKey,
        child: ListView(
          children: [
            Container(
              height: 15,
              alignment: Alignment.center,
            ),
            TextFormField(
              decoration: decoration,
              // style: const TextStyle(color: Colors.teal),
              textAlign: TextAlign.end,
              controller: valueController,
              style: const TextStyle(
                  inherit: true, fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            // TODO add dividers to make it cleaner
            Column(
              children: [
                const Text('Nome da Transação'),
                ListTile(
                  // TODO have it that clicking anywhere on the listtile can edit the text field
                  leading: const Icon(Icons.draw_rounded),
                  title: TextFormField(
                    decoration: const InputDecoration(border: InputBorder.none),
                    controller: nameController,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                ),
                const Divider(),
                ListTile(
                    leading: const Icon(Icons.calendar_month_rounded),
                    title: Obx(() => Text(initialDate.value)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          //DateTime.now() - not to allow to choose before today.
                          lastDate: DateTime(2100));
                      if (pickedDate != null) {
                        initialDate.value =
                            DateFormat('dd/MM/yyyy').format(pickedDate);
                      }
                    }),
                const Divider(),
                IconButton(
                  onPressed: () {
                    // TODO add Validation
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      String strDate = initialDate.value;
                      String day = strDate.substring(0, 2);
                      String month = strDate.substring(3, 5);
                      String year = "2023";
                      DateTime date =
                          DateTime.parse('$year-$month-$day').toLocal();
                      Transaction tr = Transaction(date, nameController.text,
                          valueController.text, widget.trObs.value.parcela);
                      widget.trObs.value = tr;
                      // print(widget.step.tr);
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  iconSize: 60,
                )
              ],
            ),
          ],
        ));
  }
}
