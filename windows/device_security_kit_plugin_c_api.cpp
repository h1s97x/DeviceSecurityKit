#include "include/device_security_kit/device_security_kit_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "device_security_kit_plugin.h"

void DeviceSecurityKitPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  device_security_kit::DeviceSecurityKitPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
