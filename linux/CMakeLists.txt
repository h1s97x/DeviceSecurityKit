cmake_minimum_required(VERSION 3.10)
project(device_security_kit LANGUAGES CXX)

set(PLUGIN_NAME "device_security_kit")

add_library(${PLUGIN_NAME} SHARED
  "device_security_kit_plugin.cc"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden
  VISIBILITY_INLINES_HIDDEN ON
)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)

set(device_security_kit_bundled_libraries
  ""
  PARENT_SCOPE
)
