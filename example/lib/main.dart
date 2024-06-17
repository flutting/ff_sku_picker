import 'package:flutter/material.dart';
import 'package:ff_sku_picker/ff_sku_filter.dart';
import 'package:ff_sku_picker/ff_sku_picker.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SkuTestPage(),
    ),
  );
}

// demo
class SkuTestPage extends StatefulWidget {
  const SkuTestPage({super.key});

  @override
  SkuTestPageState createState() => SkuTestPageState();
}

class SkuTestPageState extends State<SkuTestPage> {
  // 条件列表， 传入FFConditionModel类型对象，可以使用json数据
  List<FFConditionModel> conditions = [
    FFConditionModel('款式', [1, 2], ['男款', '女款']),
    FFConditionModel('颜色', [3, 4, 5], ['红色', '黄色', '蓝色']),
    FFConditionModel('尺寸', [6, 7, 8, 9, 10], ['XXL', 'XL', 'L', 'S', 'M']),
    FFConditionModel('其他', [11, 12, 13], ['A', 'B', 'C']),
  ];

  // 选项列表，数组中的对象必须继承自FFOptionsModel，更多属性使用可子类解析json
  List<TestOptionsModel> options = [
    // '男款,红色,XL,A'
    TestOptionsModel(167, [1, 3, 7, 11], price: '121', goodsId: '1'),
    // '男款,红色,M,B'
    TestOptionsModel(289, [1, 3, 10, 12], price: '102', goodsId: '2'),
    // '男款,黄色,L,A'
    TestOptionsModel(300, [1, 4, 8, 11], price: '123', goodsId: '3'),
    // '男款,黄色,M,B'
    TestOptionsModel(135, [1, 4, 10, 12], price: '134', goodsId: '4'),
    // '女款,红色,XL,A'
    TestOptionsModel(632, [2, 3, 7, 11], price: '105', goodsId: '5'),
    // '女款,蓝色,L,B'
    TestOptionsModel(21, [2, 5, 8, 12], price: '119', goodsId: '6'),
    // '女款,蓝色,XXL,C'
    TestOptionsModel(73, [2, 5, 6, 13], price: '118', goodsId: '7'),
    // '男款,蓝色,L,C'
    TestOptionsModel(235, [1, 5, 8, 13], price: '107', goodsId: '8'),
    // '女款,黄色,M,C'
    TestOptionsModel(5767, [2, 4, 10, 13], price: '116', goodsId: '9'),
    // '男款,蓝色,L,A'
    TestOptionsModel(12346, [2, 5, 8, 11], price: '115', goodsId: '10')
  ];

  TestOptionsModel? currentModel;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('电商项目SKU选择器'),
      ),
      body: FFSkuPicker(
        conditions: conditions,
        options: options,
        selectedFirst: true,
        spacing: 16,
        runSpacing: 16,
        onSelectItem: (FFOptionsModel? model) {
          if (model == null) {
            currentModel = null;
          } else {
            currentModel = model as TestOptionsModel;
            print(
                '当前选中: ffIndex = ${currentModel!.ffIndex}, goodId = ${currentModel!.goodsId}');
          }
          setState(() {});
        },
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        titleBuilder: (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              conditions[index].name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        },
        itemBuilder: (FFIndexPath indexPath, bool available, bool selected) {
          // 背景色, 选中时高亮
          Color bgColor =
              selected ? const Color(0xFFFFEEED) : const Color(0xFFF3F3F3);
          // 文字颜色, 选中时高亮, 不可用时置灰
          Color textColor = selected
              ? const Color(0xFFFF5A4C)
              : available
                  ? const Color(0xFF333333)
                  : const Color(0xFF999999);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              conditions[indexPath.section].contentList[indexPath.index],
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: textColor,
                  ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Text(
          currentModel == null
              ? '当前未完成选中, 所有条件选择完成后可展示结果'
              : '选中: 第${currentModel!.ffIndex}个可选项, price = ${currentModel!.price}, 可自行添加图片',
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 3,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// 非必要
// json格式, 如果没有附加字段，则直接使用FFOptionsModel即可，否则在字类中自由添加
// {
//   "stock": "121",
//   "idList": [1, 5, 8, 13],
//   "price": "888",
//   "goodsId": "8",
//   // "image": "https://"
//   // "detail": "男款,蓝色,L,C",
// }
class TestOptionsModel extends FFOptionsModel {
  TestOptionsModel(
    super.stock,
    super.idList, {
    required this.price,
    required this.goodsId,
  });

  factory TestOptionsModel.fromJson(Map<String, dynamic> json) {
    final List<int>? list = json['idList'] is List ? <int>[] : null;
    if (list != null) {
      for (final dynamic item in json['idList']!) {
        if (item != null) {
          list.add(asT<int>(item)!);
        }
      }
    }
    return TestOptionsModel(
      asT<int>(json['stock']) ?? 0,
      list ?? [],
      price: asT<String>(json['price']) ?? '',
      goodsId: asT<String>(json['goodsId']) ?? '',
    );
  }

  String price;
  String goodsId;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'stock': stock,
        'idList': idList,
        'price': price,
        'goodsId': goodsId,
      };
}

T? asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}
