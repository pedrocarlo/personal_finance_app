import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

// Consider just having an emoji for icon
class Category {
  String name;
  int colorHex;
  String svgData;
  Category(this.name, this.colorHex, this.svgData);

  Category.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        colorHex = json['colorHex'],
        svgData = json['svgData'];

  Map<String, dynamic> toJson() =>
      {'name': name, 'colorHex': colorHex, 'svgData': svgData};

  Iconify toIcon() {
    return Iconify(
      svgData,
      color: Color(colorHex),
      size: 40,
    );
  }
}

void printIcon() {}

final defaultCategories = [
  Category('Alimentação', Colors.pink.value, Mdi.food_fork_cup),
  Category('Assinatura e Serviços', Colors.purple.shade300.value, Mdi.a_b_c),
  Category('Assinatura e ServiçosAssinatura e Serviços', Colors.pink.value,
      Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
  Category('Alimentação', Colors.pink.value, Mdi.a_b_c),
];
