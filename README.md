# ff_sku_picker

SKU picker.

The following is the effect diagram, you can download the code and run it directly.

![img.png](img.png)

## Getting Started

### How to use
~~~
FFSkuPicker(
    // 条件列表
    conditions: conditions,
    // 选项列表
    options: options,
    // 默认选中第一个可选项
    selectedFirst: true,
    // 选项行间距
    spacing: 16,
    // 选项列间距
    runSpacing: 16,
    // 选中某个的条件回调
    onSelectItem: (FFOptionsModel? model) {
      // ...
    },
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    // 分区
    titleBuilder: (index) {
      // ...
      return Text('');
    },
    // 条件
    itemBuilder: (FFIndexPath indexPath, bool available, bool selected) {
      // ...
      return Container(),
    },
  )
)
~~~