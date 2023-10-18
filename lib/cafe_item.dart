import 'package:flutter/material.dart';
import 'package:flutter_cafe_admin/my_cafe.dart';
import 'my_cafe.dart';
import 'main.dart';

MyCafe myCafe = MyCafe();
String categoryName = 'cafe_category';
String itemCollectionName = 'cafe-item';

class CafeItem extends StatefulWidget {
  const CafeItem({super.key});

  @override
  State<CafeItem> createState() => _CafeItemState();
}

class _CafeItemState extends State<CafeItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Text('asdf'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CafeCategoryAddForm(),
              ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CafeCategoryAddForm extends StatefulWidget {
  const CafeCategoryAddForm({super.key});

  @override
  State<CafeCategoryAddForm> createState() => _CafeCategoryAddFormState();
}

class _CafeCategoryAddFormState extends State<CafeCategoryAddForm> {
  TextEditingController controller = TextEditingController();

  var isUsed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('add form'),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  var data = {
                    'categoryName': controller.text,
                    'isUsed': isUsed
                  };
                  var result = await myCafe.insert(
                      collectionName: itemCollectionName, data: data);
                  if (result == true) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  )),
            )
          ],
        ),
        body: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                label: Text('qwer'),
                border: OutlineInputBorder(),
              ),
              controller: controller,
            ),
            SwitchListTile(
              title: const Text('Used ?'),
              value: isUsed,
              onChanged: (value) {
                setState(() {
                  isUsed = value;
                });
              },
            )
          ],
        ));
  }
}
