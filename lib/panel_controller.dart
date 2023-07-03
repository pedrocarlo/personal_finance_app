import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:personal_finance_app/transaction_panel.dart';

class PanelController extends GetxController {
  var steps = <Panel>[];
  var controllerLst = <List<TextEditingController>>[];

  List<TextEditingController> createTextControllers() {
    List<TextEditingController> controllers = [];
    for (var i = 0; i < 3; i++) {
      controllers.add(TextEditingController());
    }
    controllerLst.add(controllers);
    return controllers;
  }

  @override
  void dispose() {
    // TODO not exactly memory efficient to create and just dispose at the end
    controllerLst.map((var controllers) => controllers.map((e) => e.dispose()));
    super.dispose();
  }
}
