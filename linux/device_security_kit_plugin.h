#ifndef FLUTTER_PLUGIN_DEVICE_SECURITY_KIT_PLUGIN_H_
#define FLUTTER_PLUGIN_DEVICE_SECURITY_KIT_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _DeviceSecurityKitPlugin DeviceSecurityKitPlugin;
G_DECLARE_FINAL_TYPE(DeviceSecurityKitPlugin, device_security_kit_plugin,
                     DEVICE_SECURITY_KIT, PLUGIN, GObject)

/**
 * device_security_kit_plugin_new:
 *
 * Creates a new plugin instance.
 * #DeviceSecurityKitPlugin objects are reference counted, use
 * g_object_unref() to release the reference.
 *
 * Returns: a new #DeviceSecurityKitPlugin
 */
FLUTTER_PLUGIN_EXPORT DeviceSecurityKitPlugin* device_security_kit_plugin_new();

G_END_DECLS

#endif  // FLUTTER_PLUGIN_DEVICE_SECURITY_KIT_PLUGIN_H_
