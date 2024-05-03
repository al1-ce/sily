// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/// String manipulation
module sily.string;

import std.array: split, popFront;
import sily.uni: isAlphaNumeric;
import std.traits: isSomeString;

import std.stdio: writeln;
import std.conv: to;

/**
Splits string at `max` width while trying not to split words in half
Params:
  str = String to split
  max = Maximum width string allowed to be
Examples:
---
string[] arr = "My work here is not done yet".splitStringWidth(7);
writeln(arr);
// ["My work", " here is ", "not ", "done ", "yet"]
---
*/
T[] splitStringWidth(T)(T str, ulong max) if (isSomeString!T) {
    T[] output;
    int i = 0;
    T[] lines = str.split('\n');

    foreach (line; lines) {
        output ~= "";
        T word = "";
        foreach (c; line) {
            if (c.isAlphaNumeric) {
                word ~= c;
            } else {
                if (output[i].length + word.length > max) {
                    ++i;
                    output ~= "";
                }
                // if it's still problem at newline
                if (output[i].length + word.length > max) {
                    while (word.length > 0) {
                        output[i] ~= word[0];
                        word.popFront();
                        if (output[i].length + 1 >= max) {
                            ++i;
                            output ~= "";
                        }
                    }
                } else {
                    output[i] ~= word;
                    word = "";
                }
                word = [c];
            }
        }
        // fix for words at end of string
        if (output[i].length + word.length > max) {
            ++i;
            output ~= "";
        }
        if (output[i].length + word.length > max) {
            while (word.length > 0) {
                output[i] ~= word[0];
                word.popFront();
                if (output[i].length + 1 >= max) {
                    ++i;
                    output ~= "";
                }
            }
        } else {
            output[i] ~= word;
            word = "";
        }
        ++i;
    }
    i = 0;
    foreach (line; output) {
        if (line.length == 0) { ++i; continue; }
        if (line[0] == ' ' && line.length != 1) output[i] = line[1..$];
        ++i;
    }
    return output;
}
