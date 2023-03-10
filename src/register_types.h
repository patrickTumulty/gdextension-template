/* godot-cpp integration testing project.
 *
 * This is free and unencumbered software released into the public domain.
 */

#ifndef EXAMPLE_REGISTER_TYPES_H
#define EXAMPLE_REGISTER_TYPES_H

#include "godot_cpp/core/class_db.hpp"

void initialize_test_module(godot::ModuleInitializationLevel p_level);
void uninitialize_test_module(godot::ModuleInitializationLevel p_level);

#endif // EXAMPLE_REGISTER_TYPES_H
