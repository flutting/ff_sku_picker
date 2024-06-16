import 'ff_sku_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FFSkuPicker extends StatefulWidget {
  const FFSkuPicker({
    super.key,
    required this.conditions,
    required this.options,
  });

  final List<FFConditionModel> conditions;

  final List<FFOptionsModel> options;

  @override
  State<FFSkuPicker> createState() => _FFSkuPickerState();
}

class _FFSkuPickerState extends State<FFSkuPicker>
    implements FFSKUDataFilterDataSource {
  List<FFIndexPath> selectedIndexPaths = [];
  late final FFSKUDataFilter _filter = FFSKUDataFilter(dataSource: this);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        return buildSectionWidget(index);
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
      itemCount: widget.conditions.length,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        const SizedBox(height: 16),
        Text(model.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (int i = 0; i < model.contentList.length; i++)
              buildRowWidget(FFIndexPath(index, i)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildRowWidget(FFIndexPath indexPath) {
    FFConditionModel model = widget.conditions[indexPath.section];
    Color bgColor = const Color(0xFFF3F3F3);
    Color textColor = const Color(0xFF666666);

    if (_filter.availableIndexPathsSet.contains(indexPath)) {
      textColor = const Color(0xFF333333);
    } else {
      textColor = const Color(0xFF999999);
    }

    if (_filter.selectedIndexPaths.contains(indexPath)) {
      textColor = const Color(0xFFFF5A4C);
      bgColor = const Color(0xFFFFEEED);
    } else {
      bgColor = const Color(0xFFF3F3F3);
    }

    return GestureDetector(
      onTap: () {
        _filter.didSelectedPropertyWithIndexPath(indexPath);
        setState(() {});
        if (kDebugMode) {
          print('当前选中：${_filter.currentResult}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          model.contentList[indexPath.index],
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: textColor,
              ),
        ),
      ),
    );
  }
}
