#!/usr/bin/env dub
/+ dub.sdl:
name "imports"
dependency "sily" path="../"
dependency "sily:term" path="../"
dependency "sily:sdl" path="../"
dependency "sily:web" path="../"
targetType "executable"
targetPath "../bin/"
+/
module test.imports;

import std.stdio;

import sily;

void main() {
    printCompilerInfo();
    hr('=', "log", "\033[33m");
    log("Testing normal log");
    writeln("");

    parseHTML("<a>a</a>");
    parseSDL("test 1");

    vec2 v;
}

