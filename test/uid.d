#!/usr/bin/env dub
/+ dub.sdl:
name "queuetest"
dependency "sily" path="../"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio;
import std.conv: to;

import sily.uid;

void main() {
    generateUID().writeln();
    generateUID().writeln();
    generateUID().writeln();
    generateUID().writeln();
    writeln();
    generateLongUID().writeln();
    generateLongUID().writeln();
    generateLongUID().writeln();
    generateLongUID().writeln();
    writeln();
    genStringUID().writeln();
    genStringUID().writeln();
    genStringUID().writeln();
    genStringUID().writeln();
    writeln();
    genLongStringUID().writeln();
    genLongStringUID().writeln();
    genLongStringUID().writeln();
    genLongStringUID().writeln();
    seedUID(124);
    writeln();
    genStringUID().writeln();
    genStringUID().writeln();
    genStringUID().writeln();
    genStringUID().writeln();
    writeln();
    genLongStringUID().writeln();
    genLongStringUID().writeln();
    genLongStringUID().writeln();
    genLongStringUID().writeln();


}
