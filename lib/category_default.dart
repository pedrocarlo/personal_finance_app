import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/cil.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/fluent_emoji_high_contrast.dart';
import 'package:iconify_flutter/icons/mingcute.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:iconify_flutter/icons/ph.dart';

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
      size: 30,
    );
  }
}

void printIcon() {}

// TODO mudar nomes e icones para satisfazer a nossas necessidades
final defaultCategories = [
  Category('Alimentação', Colors.pink.value, Mdi.food_fork_cup),
  Category('Assinatura e Serviços', Colors.purple.shade300.value,
      MaterialSymbols.connected_tv_rounded),
  Category('Bares e Restaurantes', Colors.pink.value, Cil.drink_alcohol),
  Category('Casa', Colors.pink.value, Mdi.home),
  Category('Compras', Colors.pink.value, MaterialSymbols.shopping_bag),
  Category('Cuidados Pessoais', Colors.pink.value, Ic.baseline_person),
  Category('Dívidas e empréstimos', Colors.pink.value, MaterialSymbols.receipt),
  Category(
      'Educação', Colors.pink.value, FluentEmojiHighContrast.graduation_cap),
  Category(
      'Família e filhos', Colors.pink.value, MaterialSymbols.family_restroom),
  Category('Impostos e Taxas', Colors.pink.value, Mingcute.receive_money_fill),
  Category('Investimentos', Colors.pink.value, Bi.file_earmark_bar_graph_fill),
  Category('Lazer e hobbies', Colors.pink.value, Bxs.happy_beaming),
  Category('Mercado', Colors.pink.value, Mdi.cart),
  Category('Outros', Colors.pink.value, Ph.dots_three_outline_fill),
  Category('Pets', Colors.pink.value, Mdi.a_b_c),
  Category('Presentes e doações', Colors.pink.value, Mdi.a_b_c),
  Category('Roupas', Colors.pink.value, Mdi.a_b_c),
  Category('Saúde', Colors.pink.value, Mdi.a_b_c),
  Category('Trabalho', Colors.pink.value, Mdi.a_b_c),
  Category('Transporte', Colors.pink.value, Mdi.a_b_c),
  Category('Viagem', Colors.pink.value, Mdi.a_b_c),
];
