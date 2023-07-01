import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:personal_finance_app/card_utils.dart';
import 'package:personal_finance_app/panel_controller.dart';
import 'package:personal_finance_app/transaction_form.dart';

class Panel {
  Panel(this.tr, [this.isExpanded = false]);
  Transaction tr;
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
    return SingleChildScrollView(
      child: Container(
        child: _renderSteps(),
      ),
    );
  }

  Widget _renderSteps() {
    final panelController = Get.put(PanelController());
    panelController.steps.value = widget.steps;

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          widget.steps[index].isExpanded = !isExpanded;
        });
      },
      children: widget.steps.map<ExpansionPanel>((Panel step) {
        return ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(step.tr.toString()),
            );
          },
          body: ListTile(
            title: TransactionForm(step: step),
          ),
          isExpanded: step.isExpanded,
        );
      }).toList(),
    );
  }
}
