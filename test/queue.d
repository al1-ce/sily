#!/usr/bin/env dub
/+ dub.sdl:
name "queuetest"
dependency "sily" path="../"
dependency "sily:term" path="../"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio;
import std.conv: to;

import sily.queue;
import sily.stack;

import sily.bash;
import sily.log;

void eq(T, S, int line = __LINE__, string file = "test.d")(T t1, S t2, string message) {
    bool cond = t1 == t2;
    hr('─', message.to!dstring, cond ? FRESET.FULL : FG.LT_RED,
                cond ? FRESET.FULL : FG.LT_RED);
    if (!cond) writeln(FG.DK_GRAY, "Expected: ", FG.LT_RED);
    if (!cond) {
        write(t2.to!string);
    }
    if (!cond) writeln();
    if (!cond) writeln(FG.DK_GRAY, "Got: ", FG.LT_RED);
    write(t1.to!string);
    if (!cond) write(FRESET.FULL);
    writeln();
}


void main() {
    Queue!int ique = Queue!int(1, 2, 3, 4);
    ique.toString.eq("[1, 2, 3, 4]", "toString()");
    ique.front.eq(1, "front");
    ique.pop.eq(1, "pop");
    ique.pop();
    ique.front.eq(3, "front");
    ique.pop.eq(3, "pop");
    ique.pop.eq(4, "pop");
    ique.empty.eq(true, "pop");
    ique.toString.eq("[]", "toString()");
    ique.pop.eq(0, "pop");
    ique.push(4);
    ique.pop.eq(4, "pop");
    ique.push(4, 5, 6);
    ique.toString.eq("[4, 5, 6]", "toString()");
    ique.length.eq(3, "length");
    ique.clear();
    ique.toString.eq("[]", "toString()");
    ique.push();
    ique.toString.eq("[]", "toString()");
    ique ~= 3;
    ique.front.eq(3, "front");
    ique.push(4, 5, 6, 7, 8, 9, 10);
    ique.limitLength(5);
    ique.toString.eq("[3, 4, 5, 6, 7]", "limitLength()");

    writeln();
    hr('=', "Stack");
    writeln();

    Stack!int istk = Stack!int(1, 2, 3, 4);
    istk.toString.eq("[4, 3, 2, 1]", "toString()");
    istk.front.eq(4, "front");
    istk.pop.eq(4, "pop");
    istk.pop();
    istk.front.eq(2, "front");
    istk.pop.eq(2, "pop");
    istk.pop.eq(1, "pop");
    istk.empty.eq(true, "pop");
    istk.toString.eq("[]", "toString()");
    istk.pop.eq(0, "pop");
    istk.push(4);
    istk.pop.eq(4, "pop");
    istk.push(4, 5, 6);
    istk.toString.eq("[6, 5, 4]", "toString()");
    istk.length.eq(3, "length");
    istk.clear();
    istk.toString.eq("[]", "toString()");
    istk.push();
    istk.toString.eq("[]", "toString()");
    istk ~= 3;
    istk.front.eq(3, "front");
    istk.push(4, 5, 6, 7, 8, 9, 10);
    istk.limitLength(5);
    istk.toString.eq("[10, 9, 8, 7, 6]", "limitLength()");
}
