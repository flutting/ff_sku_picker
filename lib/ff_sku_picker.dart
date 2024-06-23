import 'ff_sku_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FFSkuPicker extends StatefulWidget {
  const FFSkuPicker(
      {super.key,
      required this.conditions,
      required this.options,
      required this.titleBuilder,
      required this.itemBuilder,
      required this.onSelectItem,
      this.spacing = 0.0,
      this.runSpacing = 0.0,
      this.separatorBuilder,
      this.selectedFirst = false,
      this.padding = EdgeInsets.zero});

  /// 条件列表
  final List<FFConditionModel> conditions;

  /// 选项列表
  final List<FFOptionsModel> options;

  /// 默认选中第一个可用的选项
  final bool selectedFirst;

  /// 内间距
  final EdgeInsets padding;

  /// 选项的行间距 默认0.0.
  final double spacing;

  /// 选项的列间距 默认0.0.
  final double runSpacing;

  /// 分区标题
  final Widget Function(int index) titleBuilder;

  /// 内容
  final Widget Function(FFIndexPath indexPath, bool available, bool selected)
      itemBuilder;

  /// 用法同ListView
  final IndexedWidgetBuilder? separatorBuilder;

  /// 点击任意可用条件后回调, 选择完成, 成功匹配到可选项则返回model, 否则返回空.
  final Function(FFOptionsModel? model) onSelectItem;

  @override
  State<FFSkuPicker> createState() => _FFSkuPickerState();
}

class _FFSkuPickerState extends State<FFSkuPicker>
    implements _FFSKUDataFilterDataSource {
  late final _FFSKUDataFilter _filter = _FFSKUDataFilter(
    dataSource: this,
    selectedFirst: widget.selectedFirst,
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      for (int i = 0; i < widget.options.length; i++) {
        widget.options[i].ffIndex = i;
      }
      if (widget.selectedFirst) {
        widget.onSelectItem(_filter.currentResult);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        return buildSectionWidget(index);
      },
      separatorBuilder: (context, index) {
        return widget.separatorBuilder != null
            ? widget.separatorBuilder!(context, index)
            : const SizedBox(height: 0);
      },
      padding: widget.padding,
      itemCount: widget.conditions.length,
    );
  }

  @override
  List filterConditionForRow(int row) {
    List condition = widget.options[row].idList;
    return condition;
  }

  @override
  List filterPropertiesInSection(int section) {
    return widget.conditions[section].idList;
  }

  @override
  filterResultOfConditionForRow(int row) {
    return widget.options[row];
  }

  @override
  filterStockOfConditionForRow(int row) {
    return widget.options[row].stock;
  }

  @override
  int numberOfConditionsInFilter() {
    return widget.options.length;
  }

  @override
  int numberOfSectionsForPropertiesInFilter() {
    return widget.conditions.length;
  }
}

extension _UI on _FFSkuPickerState {
  Widget buildSectionWidget(int index) {
    FFConditionModel model = widget.conditions[index];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.titleBuilder(index),
        Wrap(
          spacing: widget.spacing,
          runSpacing: widget.runSpacing,
          children: [
            for (int i = 0; i < model.contentList.length; i++)
              buildRowWidget(FFIndexPath(index, i)),
          ],
        ),
      ],
    );
  }

  Widget buildRowWidget(FFIndexPath indexPath) {
    return GestureDetector(
      onTap: () {
        _filter.didSelectedPropertyWithIndexPath(indexPath);
        widget.onSelectItem(_filter.currentResult);
      },
      child: widget.itemBuilder(
        indexPath,
        _filter.availableIndexPathsSet.contains(indexPath),
        _filter.selectedIndexPaths.contains(indexPath),
      ),
    );
  }
}

/// 私有类
abstract class _FFSKUDataFilterDataSource {
  int numberOfSectionsForPropertiesInFilter();

  List filterPropertiesInSection(int section);

  List filterConditionForRow(int row);

  FFOptionsModel filterResultOfConditionForRow(int row);

  int filterStockOfConditionForRow(int row);

  int numberOfConditionsInFilter();
}

class _FFSKUDataFilter {
  _FFSKUCondition? _defaultSku;
  FFOptionsModel? currentResult;
  bool selectedFirst;
  final _FFSKUDataFilterDataSource dataSource;
  Set<_FFSKUCondition> _conditions = {};
  Set<FFIndexPath> selectedIndexPaths = {};
  Set<FFIndexPath> availableIndexPathsSet = {};
  Set<FFIndexPath> allAvailableIndexPaths = {};

  _FFSKUDataFilter({required this.dataSource, required this.selectedFirst}) {
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

      if (selectedIndexPaths.isEmpty && selectedFirst && _defaultSku == null) {
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
