#include "include/ff_sku_picker/ff_sku_picker_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "ff_sku_picker_plugin.h"

void FfSkuPickerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ff_sku_picker::FfSkuPickerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
