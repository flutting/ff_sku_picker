#ifndef FLUTTER_PLUGIN_FF_SKU_PICKER_PLUGIN_H_
#define FLUTTER_PLUGIN_FF_SKU_PICKER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace ff_sku_picker {

class FfSkuPickerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FfSkuPickerPlugin();

  virtual ~FfSkuPickerPlugin();

  // Disallow copy and assign.
  FfSkuPickerPlugin(const FfSkuPickerPlugin&) = delete;
  FfSkuPickerPlugin& operator=(const FfSkuPickerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace ff_sku_picker

#endif  // FLUTTER_PLUGIN_FF_SKU_PICKER_PLUGIN_H_
