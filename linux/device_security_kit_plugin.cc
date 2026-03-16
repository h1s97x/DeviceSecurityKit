#include "device_security_kit_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <iostream>

#define DEVICE_SECURITY_KIT_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), device_security_kit_plugin_get_type(), \
                              DeviceSecurityKitPlugin))

struct _DeviceSecurityKitPlugin {
  GObject parent_instance;
  FlMethodChannel* channel;
};

G_DEFINE_TYPE(DeviceSecurityKitPlugin, device_security_kit_plugin, G_TYPE_OBJECT)

// Called when a method call is received from Flutter.
static void device_security_kit_plugin_handle_method_call(
    DeviceSecurityKitPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar* version = g_strdup_printf("Linux %s", uname_data.release);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void device_security_kit_plugin_dispose(GObject* object) {
  DeviceSecurityKitPlugin* self = DEVICE_SECURITY_KIT_PLUGIN(object);
  g_clear_object(&self->channel);
  G_OBJECT_CLASS(device_security_kit_plugin_parent_class)->dispose(object);
}

static void device_security_kit_plugin_class_init(
    DeviceSecurityKitPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = device_security_kit_plugin_dispose;
}

static void device_security_kit_plugin_init(DeviceSecurityKitPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  DeviceSecurityKitPlugin* plugin = DEVICE_SECURITY_KIT_PLUGIN(user_data);
  device_security_kit_plugin_handle_method_call(plugin, method_call);
}

void fl_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  DeviceSecurityKitPlugin* plugin = DEVICE_SECURITY_KIT_PLUGIN(
      g_object_new(device_security_kit_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), "device_security_kit",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(plugin->channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}

DeviceSecurityKitPlugin* device_security_kit_plugin_new() {
  return DEVICE_SECURITY_KIT_PLUGIN(
      g_object_new(device_security_kit_plugin_get_type(), nullptr));
}
