import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
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
                backgroundColor: const Color(0xff121212),
                expand: true,
                context: context,
                builder: (builder) {
                  final trObs = panelController.steps[index].tr;
                  // ever(trObs, (callback) => print('$callback has changed'));
                  return TransactionForm(trObs: trObs);
                }),
            child: Card(
              // TODO SEE A WAY TO HAVE THIS SINGLE CHILD SCROLLVIEW VANISH AND HAVE NO TEXT OVERFLOW
              child: Padding(
                padding: const EdgeInsets.all(11.0),
                child: Column(children: [
                  Expanded(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Obx(() => Text(
                              widget.steps[index].tr.value.name,
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

// GridView.builder(
//       scrollDirection: Axis.horizontal,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      
//     );
