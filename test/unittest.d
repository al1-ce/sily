#!/usr/bin/env dub

/+ dub.sdl:
name "tui-test"
description "A minimal D application."
authors "Alisa Lain"
copyright "Copyright © 2022, Alisa Lain"
license "proprietary"
dependency "sily:unit" path="../"
// targetType "executable"
targetType "executable"
targetPath "../bin/"
+/

module tester;

import sily.unit;

void main() {
    false.assertEquals(true);
    true.assertFalse();
    false.assertFalse();
    false.assertTrue();
    true.assertTrue();
    writeReport();
}
