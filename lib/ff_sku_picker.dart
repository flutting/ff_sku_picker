import 'ff_sku_filter.dart';
import 'package:flutter/material.dart';

class FFSkuPicker extends StatefulWidget {
  const FFSkuPicker({
    super.key,
    required this.conditions,
    required this.options,
    required this.titleBuilder,
    required this.itemBuilder,
    required this.onSelectItem,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    this.separatorBuilder,
    this.selectedFirst = false,
    this.padding = EdgeInsets.zero
  });

  // 条件列表
  final List<FFConditionModel> conditions;

  // 选项列表
  final List<FFOptionsModel> options;

  // 默认选中第一个可用的选项
  final bool selectedFirst;

  // 内间距
  final EdgeInsets padding;

  // 选项的行间距 默认0.0.
  final double spacing;

  // 选项的列间距 默认0.0.
  final double runSpacing;

  // 分区标题
  final Widget Function(int index) titleBuilder;

  // 内容
  final Widget Function(FFIndexPath indexPath, bool available, bool selected)
      itemBuilder;

  // 用法同ListView
  final IndexedWidgetBuilder? separatorBuilder;

  final Function (FFOptionsModel? model) onSelectItem;

  @override
  State<FFSkuPicker> createState() => _FFSkuPickerState();
}

class _FFSkuPickerState extends State<FFSkuPicker>
    implements FFSKUDataFilterDataSource {
  late final FFSKUDataFilter _filter = FFSKUDataFilter(
    dataSource: this,
    selectedFirst: widget.selectedFirst,
  );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      for (int i = 0; i < widget.options.length; i ++) {
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
