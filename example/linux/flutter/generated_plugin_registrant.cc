//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <ff_sku_picker/ff_sku_picker_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) ff_sku_picker_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FfSkuPickerPlugin");
  ff_sku_picker_plugin_register_with_registrar(ff_sku_picker_registrar);
}
