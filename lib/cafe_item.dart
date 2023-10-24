import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cafe_admin/my_cafe.dart';
import 'my_cafe.dart';
import 'main.dart';

MyCafe myCafe = MyCafe();
String categoryCollectionName = 'cafe_category';
String itemCollectionName = 'cafe-item';

class CafeItem extends StatefulWidget {
  const CafeItem({super.key});

  @override
  State<CafeItem> createState() => _CafeItemState();
}

class _CafeItemState extends State<CafeItem> {
  dynamic body = const Text('Loading . . . .');

  Future<void> getCategory() async {
    setState(() {
      body = FutureBuilder(
        future: myCafe.get(
            collectionName: categoryCollectionName,
            id: null,
            filedName: null,
            filedValue: null),
        builder: (context, snapshot) {
          if (snapshot.hasData == true) {
            var datas = snapshot.data?.docs; // null or datas . . .
            if (datas == null) {
              return const Center(
                child: Text('empty'),
              );
            } else {
              // 진짜 데이터가 있는 곳
              // 데이터가 리스트 형태이기 때문에 리스트뷰를 이용해서 하나씩 뿌려줌
              return ListView.separated(
                  itemBuilder: (context, index) {
                    var data = datas[index];
                    return ListTile(
                      title: Text(data['categoryName']),
                      trailing: PopupMenuButton(
                        onSelected: (value) async {
                          switch (value) {
                            case 'modify':
                              var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CafeCategoryAddForm(id: data.id),
                                  ));
                              if (result == true) {
                                getCategory();
                              }
                              break;
                            case 'delete':
                              var result = await myCafe.delete(
                                  collectionName: categoryCollectionName,
                                  id: data.id);
                              if (result == true) {
                                getCategory();
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'modify',
                            child: Text('수정'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('삭제'),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: datas.length);
            }
          } else {
            // 아직 기다리는 중
            return const Center(
              child: Text('불러오는 중'),
            );
          }
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // result에 true 보관(저장 완료)
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CafeCategoryAddForm(id: null),
              ));

          // 카테고리 목록 출력
          if (result == true) {
            getCategory();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CafeCategoryAddForm extends StatefulWidget {
  String? id;
  CafeCategoryAddForm({super.key, required this.id});

  @override
  State<CafeCategoryAddForm> createState() => _CafeCategoryAddFormState();
}

class _CafeCategoryAddFormState extends State<CafeCategoryAddForm> {
  TextEditingController controller = TextEditingController();
  String? id;
  var isUsed = true;

  Future<void> getData({required String id}) async {
    var data = await myCafe.get(
      collectionName: categoryCollectionName,
      id: id,
    );
    setState(() {
      controller.text = data['categoryName'];
      isUsed = data['isUsed'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.id;
    if (id != null) {
      // update 상황
      var data = getData(id: id!);
    }
  }

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
                  var result = id != null
                      ? await myCafe.update(
                          collectionName: categoryCollectionName,
                          id: id!,
                          data: data)
                      : await myCafe.insert(
                          collectionName: categoryCollectionName, data: data);
                  if (result == true) {
                    Navigator.pop(context, true);
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
