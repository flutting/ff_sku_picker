// 公开的model

// 选项， 如款式， 颜色， 尺寸
// json格式
// {
//   "name": "颜色",
//   "ids": [3, 4, 5],
//   "contentList": ["红色", "黄色", "蓝色"]
// }
/// 条件model(基类, 如需其他属性, 可通过子类添加)
class FFConditionModel {
  /// 显示名称
  late String name;

  /// id列表(条件可能会重名, 所以需要用id去重)
  late List<int> idList;

  /// 条件列表
  late List<String> contentList;

  FFConditionModel(this.name, this.idList, this.contentList);
}

// 具体的选项
// json格式, others放在子类中实现
// {
//   "stock": 10,
//   "ids": [3, 4, 5],
//   "others1": "1",
//   "others2": 2,
//   "others3": [],
//   "others4": {},
// }
/// 选项model(基类, 如需其他属性, 可通过子类添加)
class FFOptionsModel {
  /// 库存
  int stock;

  /// id列表(条件可能会重名, 所以需要用id去重)
  List<int> idList;

  /// 记录当前选项为第几个
  int ffIndex = 0;

  FFOptionsModel(this.stock, this.idList);
}

/// 索引工具, 类似二维数组, section为第一维索引, index为第二维索引, section&index协同命中具体对象.
class FFIndexPath {
  /// 第一维索引
  int section;

  /// 第二维索引
  int index;

  FFIndexPath(this.section, this.index);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FFIndexPath &&
        section == other.section &&
        index == other.index;
  }

  @override
  String toString() {
    return 'FFIndexPath{section: $section, index: $index}';
  }

  @override
  int get hashCode => Object.hash(section, index);
}
