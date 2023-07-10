import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:personal_finance_app/card_utils.dart';
import 'package:personal_finance_app/panel_controller.dart';
import 'package:personal_finance_app/transaction_form.dart';
import 'package:collection_ext/ranges.dart';

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

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 20.0, crossAxisSpacing: 15.0),
      itemCount: widget.steps.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.deepPurple.shade600,
                offset: const Offset(-10, -1))
          ]),
          child: const Card(
            child: Center(
              child: Text("TEST"),
            ),
          ),
        );
      },
    );
  }
}

// GridView.builder(
//       scrollDirection: Axis.horizontal,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      
//     );
