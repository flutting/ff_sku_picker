// 过滤工具
import 'package:flutter/foundation.dart';

// 选项， 如款式， 颜色， 尺寸
// json格式
// {
//   "name": "颜色",
//   "ids": [3, 4, 5],
//   "contentList": ["红色", "黄色", "蓝色"]
// }
class FFConditionModel {
  late String name;
  late List<int> idList;
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
class FFOptionsModel {
  int stock;
  List<int> idList;

  // 记录当前选项为第几个
  int ffIndex = 0;

  FFOptionsModel(this.stock, this.idList);
}

// 索引工具
class FFIndexPath {
  int section;
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

abstract class FFSKUDataFilterDataSource {
  int numberOfSectionsForPropertiesInFilter();

  List filterPropertiesInSection(int section);

  List filterConditionForRow(int row);

  FFOptionsModel filterResultOfConditionForRow(int row);

  int filterStockOfConditionForRow(int row);

  int numberOfConditionsInFilter();
}

class FFSKUDataFilter {
  _FFSKUCondition? _defaultSku;
  FFOptionsModel? currentResult;
  bool selectedFirst;
  final FFSKUDataFilterDataSource dataSource;
  Set<_FFSKUCondition> _conditions = {};
  Set<FFIndexPath> selectedIndexPaths = {};
  Set<FFIndexPath> availableIndexPathsSet = {};
  Set<FFIndexPath> allAvailableIndexPaths = {};

  FFSKUDataFilter({required this.dataSource, required this.selectedFirst}) {
    selectedIndexPaths = {};
    initPropertiesSkuListData();
  }

  void reloadData() {
    selectedIndexPaths.clear();
    _defaultSku = null;
    initPropertiesSkuListData();
    updateCurrentResult();
  }

  void didSelectedPropertyWithIndexPath(FFIndexPath indexPath) {
    if (!availableIndexPathsSet.contains(indexPath)) {
      // Log.e('不可用');
      return; // 不可用
    }

    if (indexPath.section >
            dataSource.numberOfSectionsForPropertiesInFilter() ||
        indexPath.index >=
            dataSource.filterPropertiesInSection(indexPath.section).length) {
      return; // 越界
    }

    if (selectedIndexPaths.contains(indexPath)) {
      selectedIndexPaths.remove(indexPath);
      updateAvailableIndexPaths();
      updateCurrentResult();
      return;
    }

    FFIndexPath? lastIndexPath;

    for (var selectedIndexPath in selectedIndexPaths) {
      if (indexPath.section == selectedIndexPath.section) {
        lastIndexPath = selectedIndexPath;
      }
    }

    if (lastIndexPath == null) {
      selectedIndexPaths.add(indexPath);
      availableIndexPathsSet = availableIndexPathsFromSelectedIndexPath(
        indexPath,
        selectedIndexPaths,
      );
      updateAvailableIndexPaths();
      updateCurrentResult();
      return;
    }

    if (lastIndexPath.index != indexPath.index) {
      selectedIndexPaths.add(indexPath);
      selectedIndexPaths.remove(lastIndexPath);
      updateAvailableIndexPaths();
      updateCurrentResult();
    }
  }

  void initPropertiesSkuListData() {
    final modelSet = <_FFSKUCondition>{};

    for (var i = 0; i < dataSource.numberOfConditionsInFilter(); i++) {
      final model = _FFSKUCondition();
      final conditions = dataSource.filterConditionForRow(i);
      // Log.e('conditions === $conditions');
      if (!checkConformToSkuConditions(conditions)) {
        if (kDebugMode) {
          print('第 $i 个 condition 不完整');
        }
        continue;
      }

      model.properties = _propertiesWithConditionRawData(conditions);
      model.result = dataSource.filterResultOfConditionForRow(i);

      if (dataSource.filterStockOfConditionForRow(i) < 1) {
        if (kDebugMode) {
          print('第 $i 个 无库存');
        }
        continue;
      }

      if (selectedIndexPaths.isEmpty &&
          selectedFirst &&
          _defaultSku == null) {
        _defaultSku = model;
      }

      modelSet.add(model);
    }

    _conditions = modelSet;
    getAllAvailableIndexPaths();

    if (_defaultSku != null && _defaultSku!.properties.isNotEmpty) {
      for (var obj in _defaultSku!.properties) {
        didSelectedPropertyWithIndexPath(obj.indexPath);
      }
    }
  }

  bool checkConformToSkuConditions(List? conditions) {
    if (conditions == null ||
        conditions.length !=
            dataSource.numberOfSectionsForPropertiesInFilter()) {
      return false;
    }

    var flag = true;
    for (var obj in conditions) {
      final properties =
          dataSource.filterPropertiesInSection(conditions.indexOf(obj));
      if (!properties.contains(obj)) {
        flag = false;
      }
    }
    return flag;
  }

  List<_FFSKUProperty> _propertiesWithConditionRawData(List? data) {
    final array = <_FFSKUProperty>[];
    data?.forEach((obj) {
      array.add(_propertyOfValue(obj, data.indexOf(obj)));
    });
    // print('array === $array');
    return array;
  }

  _FFSKUProperty _propertyOfValue(dynamic value, int section) {
    final properties = dataSource.filterPropertiesInSection(section);
    if (!properties.contains(value)) {
      throw 'Properties for $section dose not exist $value';
    }
    final indexPath = FFIndexPath(section, properties.indexOf(value));
    return _FFSKUProperty(value, indexPath);
  }

  Set<FFIndexPath> getAllAvailableIndexPaths() {
    final set = <FFIndexPath>{};
    for (var obj in _conditions) {
      for (var obj1 in obj.indexPaths) {
        set.add(obj1);
      }
    }
    availableIndexPathsSet = set;
    allAvailableIndexPaths = Set.from(set);
    return availableIndexPathsSet;
  }

  Set<FFIndexPath> availableIndexPathsFromSelectedIndexPath(
      FFIndexPath selectedIndexPath, Set<FFIndexPath> indexPaths) {
    final set = <FFIndexPath>{};
    for (var obj in _conditions) {
      if (obj.indexes[selectedIndexPath.section] == selectedIndexPath.index) {
        for (var property in obj.properties) {
          if (property.indexPath.section != selectedIndexPath.section) {
            var flag = true;
            for (var obj1 in indexPaths) {
              flag = (obj.indexes[obj1.section] == obj1.index ||
                      obj1.section == property.indexPath.section) &&
                  flag;
            }
            if (flag) {
              set.add(property.indexPath);
            }
          } else {
            set.add(property.indexPath);
          }
        }
      }
    }

    for (var obj in allAvailableIndexPaths) {
      if (obj.section == selectedIndexPath.section) {
        set.add(obj);
      }
    }

    return set;
  }

  void updateAvailableIndexPaths() {
    if (selectedIndexPaths.isEmpty) {
      availableIndexPathsSet = Set.from(allAvailableIndexPaths);
      return;
    }

    var set = <FFIndexPath>{};

    final selected = Set.of(selectedIndexPaths);
    for (var obj in selectedIndexPaths) {
      selected.add(obj);
      var tempSet = availableIndexPathsFromSelectedIndexPath(obj, selected);

      if (set.isEmpty) {
        set = Set.of(tempSet);
      } else {
        set.retainAll(tempSet);
      }
    }

    availableIndexPathsSet = Set.of(set);
  }

  void updateCurrentResult() {
    if (selectedIndexPaths.length !=
        dataSource.numberOfSectionsForPropertiesInFilter()) {
      currentResult = null;
      return;
    }
    for (var obj in _conditions) {
      if (obj.indexPaths
          .every((element) => selectedIndexPaths.contains(element))) {
        currentResult = obj.result;
        break;
      }
    }
  }

  List<dynamic> currentAvailableResults() {
    if (selectedIndexPaths.length ==
        dataSource.numberOfSectionsForPropertiesInFilter()) {
      return [currentResult];
    }

    final results = <dynamic>[];
    for (var obj in _conditions) {
      if (obj.indexPaths.containsAll(selectedIndexPaths)) {
        results.add(obj.result);
      }
    }
    return results;
  }
}

class _FFSKUCondition {
  late FFOptionsModel result;
  List<int> indexes = [];
  Set<FFIndexPath> indexPaths = {};

  List<_FFSKUProperty> _properties = [];

  List<_FFSKUProperty> get properties {
    return _properties;
  }

  set properties(List<_FFSKUProperty> properties) {
    _properties = properties;
    List<int> indexes = [];
    Set<FFIndexPath> indexPaths = {};
    for (_FFSKUProperty obj in properties) {
      indexes.add(obj.indexPath.index);
      indexPaths.add(obj.indexPath);
    }
    this.indexes = indexes;
    this.indexPaths = indexPaths;
  }

  @override
  bool operator ==(Object other) {
    return other is _FFSKUCondition &&
        properties == other.properties &&
        indexes == other.indexes;
  }

  @override
  String toString() {
    return 'FFSKUProperty{indexes: $indexes, indexPaths: $indexPaths, properties: $properties}';
  }

  @override
  int get hashCode => properties.hashCode ^ indexes.hashCode;
}

class _FFSKUProperty {
  dynamic value;
  FFIndexPath indexPath;

  _FFSKUProperty(this.value, this.indexPath);

  @override
  String toString() {
    return 'FFSKUProperty{value: $value, indexPath: $indexPath}';
  }
}
