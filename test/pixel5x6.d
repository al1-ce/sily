#!/usr/bin/env dub
/+ dub.sdl:
name "pixelfont5x6"
dependency "sily:term" path="../"
targetType "executable"
targetPath "../bin/"
+/
import std.stdio: writeln;

import std.array: join;
import std.array: popFront;

import sily.log.pixelfont: get5x6;

void main(string[] args) {
    args.popFront();
    writeln(get5x6(args.join(' ')));
}

