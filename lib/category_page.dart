import 'package:flutter/material.dart';
import 'package:personal_finance_app/category_default.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    var baseCategories = defaultCategories;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, mainAxisSpacing: 20.0),
        itemCount: baseCategories.length,
        itemBuilder: (BuildContext context, int index) {
          var currCategory = baseCategories[index];
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color.fromARGB(255, 10, 10, 10)),
                    child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: IconButton(
                          icon: currCategory.toIcon(),
                          onPressed: () {},
                        ))),
                Expanded(
                  child: Text(
                    currCategory.name,
                    textAlign: TextAlign.center,
                  ),
                )
              ]);
        },
      ),
    );
  }
}
