import 'package:flutter/material.dart';
import 'package:ff_sku_picker/ff_sku_filter.dart';
import 'package:ff_sku_picker/ff_sku_picker.dart';

void main() {
  runApp(const MaterialApp(
    home: SkuTestPage(),
  ));
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
    TestOptionsModel(167, [1, 3, 7, 11], price: '1121', goodsId: '1'), //'男款,红色,XL,A'
    TestOptionsModel(289, [1, 3, 10, 12], price: '1202', goodsId: '2'), // '男款,红色,M,B'
    TestOptionsModel(300, [1, 4, 8, 11], price: '1123', goodsId: '3'), // '男款,黄色,L,A'
    TestOptionsModel(135, [1, 4, 10, 12], price: '1124', goodsId: '4'), // '男款,黄色,M,B'
    TestOptionsModel(632, [2, 3, 7, 11], price: '1125', goodsId: '5'), // '女款,红色,XL,A'
    TestOptionsModel(21, [2, 5, 8, 12], price: '1121', goodsId: '6'), // '女款,蓝色,L,B'
    TestOptionsModel(73, [2, 5, 6, 13], price: '1122', goodsId: '7'), // '女款,蓝色,XXL,C'
    TestOptionsModel(235, [1, 5, 8, 13], price: '1123', goodsId: '8'), // '男款,蓝色,L,C'
    TestOptionsModel(5767, [2, 4, 10, 13], price: '1124', goodsId: '9'), // '女款,黄色,M,C'
    TestOptionsModel(12346, [2, 5, 8, 11], price: '1125', goodsId: '10') //'男款,蓝色,L,A'
  ];

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
      body: FFSkuPicker(conditions: conditions, options: options),
    );
  }
}

// 非必要
// json格式, 如果没有附加字段，则直接使用FFOptionsModel即可，否则在字类中逐一添加
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
