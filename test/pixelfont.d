#!/usr/bin/env dub
/+ dub.sdl:
name "pixelfont"
dependency "sily:term" path="../"
targetType "executable"
targetPath "../bin/"
+/
import std.stdio: writeln;

import std.array: join;
import std.array: popFront;

import sily.log.pixelfont: get3x4;

void main(string[] args) {
    args.popFront();
    writeln(get3x4("Testing testing"));
}

