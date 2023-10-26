import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cafe_admin/my_cafe.dart';
import 'my_cafe.dart';

MyCafe myCafe = MyCafe();
String categoryCollectionName = 'cafe_category';
String itemCollectionName = 'cafe_item';

// 카테고리 목록보기
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
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CafeItemList(
                                id: data.id,
                              ),
                            ));
                      },
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

// 카테고리 추가 / 수정 폼
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

// 아이템 목록보기
class CafeItemList extends StatefulWidget {
  String id;
  CafeItemList({super.key, required this.id});

  @override
  State<CafeItemList> createState() => _CafeItemListState();
}

class _CafeItemListState extends State<CafeItemList> {
  late String id;
  dynamic dropdownMenu = const Text('loading  . . . . ');
  dynamic itemList = const Text('itemList');

  @override
  void initState() {
    super.initState();
    id = widget.id;
    getCategory(id);
  }

  Future<void> getCategory(String id) async {
    var datas = myCafe.get(collectionName: categoryCollectionName);
    List<DropdownMenuEntry> entries = [];
    setState(() {
      dropdownMenu = FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var datas = snapshot.data.docs;
            for (var data in datas) {
              entries.add(
                DropdownMenuEntry(value: data.id, label: data['categoryName']),
              );
            }
            return DropdownMenu(
              dropdownMenuEntries: entries,
              initialSelection: id,
              onSelected: (value) {
                print('$value item list');
              },
            );
          } else {
            return const Text('loading . . . . . . . . . ');
          }
        },
        future: datas,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CafeItemAddForm(
                      itemId: id,
                      categoryId: '',
                    ),
                  ));
            },
            child: const Text(
              '+item',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          dropdownMenu,
          const Text('List'),
        ],
      ),
    );
  }
}

// 아이템 추가 / 수정 폼
// 이름, 가격, 옵션, 매진여부, 설명
class CafeItemAddForm extends StatefulWidget {
  String categoryId;
  String? itemId;
  CafeItemAddForm({super.key, required this.categoryId, this.itemId});

  @override
  State<CafeItemAddForm> createState() => _CafeStateItemAddForm();
}

class _CafeStateItemAddForm extends State<CafeItemAddForm> {
  late String categoryId;
  String? itemId;
  TextEditingController controllerTitle = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();
  TextEditingController controllerDesc = TextEditingController();
  TextEditingController controllerOptionName = TextEditingController();
  TextEditingController controllerOptionValue = TextEditingController();

  bool isSoldOut = false;

  var options = [];
  dynamic optionView = const Text('No Option');

  void showOptionList() {
    setState(() {
      optionView = ListView.separated(
          itemBuilder: (context, index) {
            var title = options[index]['optionName'];
            var subTitle =
                options[index]['optionValue'].toString().replaceAll('\n', '/');
            return ListTile(
              title: Text(title),
              subtitle: Text(subTitle),
              trailing: IconButton(
                  onPressed: () {
                    options.removeAt(index);
                    showOptionList();
                  },
                  icon: const Icon(Icons.close)),
            );
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: options.length);
    });
    controllerOptionName.clear();
    controllerOptionValue.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoryId = widget.categoryId;
    itemId = widget.itemId;
    // item == null => new, !null => 'modify'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('item add form'),
        actions: [
          TextButton(
            onPressed: () async {
              var data = {
                'itemName': controllerTitle.text,
                'itemPrice': int.parse(controllerPrice.text),
                'itemDesc': controllerDesc.text,
                'itemIsSoldOut': isSoldOut,
                'categoryId': categoryId,
                'options': options,
              };
              var result = await myCafe.insert(
                  collectionName: itemCollectionName, data: data);
              if (result == true) {
                Navigator.pop(context, true);
              }
            },
            child: const Text(
              '저장함',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              label: Text('이름'),
            ),
            controller: controllerTitle,
          ),
          TextFormField(
            decoration: const InputDecoration(
              label: Text('가격'),
            ),
            controller: controllerPrice,
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            decoration: const InputDecoration(
              label: Text('설명'),
            ),
            controller: controllerDesc,
          ),
          SwitchListTile(
            value: isSoldOut,
            onChanged: (value) {
              setState(() {
                isSoldOut = value;
              });
            },
            title: const Text('sold out ?'),
          ),
          Expanded(child: optionView),
          IconButton(
            onPressed: () {
              var optionName = controllerOptionName.text;
              var optionValue = controllerOptionValue.text;

              if (optionName != '' || optionValue != '') {
                var data = {
                  'optionName': optionName,
                  'optionValue': optionValue
                };

                options.add(data);
                showOptionList();
              }
            },
            icon: const Icon(Icons.arrow_circle_up),
          ),
          TextFormField(
            controller: controllerOptionName,
          ),
          TextFormField(
            controller: controllerOptionValue,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
