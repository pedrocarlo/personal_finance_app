import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_finance_app/transaction_panel.dart';

class PanelController extends GetxController {
  // TODO HAVE DICTIONARY CREATED HERE TO PRESERVE MAPPINGS OF NAMES
  static PanelController get to => Get.find<PanelController>();

  var name2ProductMap = HashMap<String, String>();
  var nameLst = <String>[];
  var panelNameLst = <RxString>[];
  var steps = <Panel>[];
  var controllerLst = <List<TextEditingController>>[];

  void addName(String name) {
    nameLst.add(name);
  }

  void addPanelName(RxString name) {
    panelNameLst.add(name);
  }

  void serializeMap() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/map.json');
    await file.writeAsString(jsonEncode(name2ProductMap));
  }

  void decodeMap() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/map.json');
    if (file.existsSync()) {
      String jsonMap = await file.readAsString();
      name2ProductMap = HashMap<String, String>.from(jsonDecode(jsonMap));
    }
  }

  void testHashMap() {
    name2ProductMap[Random().nextInt(100).toString()] = 'test';
  }

  List<TextEditingController> createTextControllers() {
    List<TextEditingController> controllers = [];
    for (var i = 0; i < 2; i++) {
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
