import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:personal_finance_app/card_utils.dart';
import 'package:personal_finance_app/panel_controller.dart';
import 'package:personal_finance_app/transaction_form.dart';

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
    return _renderSteps();
  }

  Widget _renderSteps() {
    final panelController = Get.put(PanelController());
    panelController.steps = widget.steps;
    // return Text("");
    return ListView.builder(
        prototypeItem: ElevatedButton(
            child: const Text(''),
            onPressed: () => showBarModalBottomSheet(
                backgroundColor: Colors.black45,
                context: context,
                builder: (builder) {
                  return Container();
                })),
        itemCount: widget.steps.length,
        itemBuilder: (context, index) {
          return Obx(() => ElevatedButton(
              // TODO if needed use the library for modal bottom sheet
              onPressed: () => showBarModalBottomSheet(
                  backgroundColor: const Color(0xff121212),
                  expand: true,
                  context: context,
                  builder: (builder) {
                    final trObs = panelController.steps[index].tr;
                    // ever(trObs, (callback) => print('$callback has changed'));
                    return TransactionForm(trObs: trObs);
                  }),
              child: Text(panelController.steps[index].tr.value.toString())));
        });
  }
}
