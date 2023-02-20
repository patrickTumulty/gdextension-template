
#ifndef GDEXTENSIONPLAYGROUND_TEST_H
#define GDEXTENSIONPLAYGROUND_TEST_H

#include "godot_cpp/classes/node3d.hpp"


class Test : public godot::Node3D
{
    GDCLASS(Test, Node3D);
public:
    void _ready() override;

protected:
    static void _bind_methods() {}

};

#endif //GDEXTENSIONPLAYGROUND_TEST_H
