// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/// std.getopt.defaultPrinter alternative
module sily.getopt;

import std.algorithm : max;
import std.getopt : Option;
import std.stdio : writefln;

/**
Helper function to get std.getopt.Option
Params:
    _long = Option name
    _help = Option help
Returns: std.getopt.Option
*/
Option customOption(string _long, string _help) { return Option("", _long, _help, false); }

private enum bool isOptionArray(T) = is(T == Option[]);
private enum bool isOption(T) = is(T == Option);
private enum bool isString(T) = is(T == string);

/**
Prints passed **Option**s and text in aligned manner on stdout, i.e:
```
A simple cli tool
Usage:
  scli [options] [script] \
  scli run [script]
Options:
  -h, --help   This help information. \
  -c, --check  Check syntax without running. \
  --quiet      Run silently (no output).
Commands:
  run          Runs script. \
  compile      Compiles script.
```
Can be used like:
---------
printGetopt("Usage", "Options", help.options, "CustomOptions", customArray, customOption("opt", "-h"));
---------
Params:
  S = Can be either std.getopt.Option[], std.getopt.Option or string
*/
void printGetopt(S...)(S args) { // string text, string usage, Option[] opt,
    size_t maxLen = 0;
    bool[] isNextOpt = [];

    foreach (arg; args) {
        alias A = typeof(arg);

        static if(isOptionArray!A) {
            foreach (it; arg) {
                int sep = it.optShort == "" ? 0 : 2;
                maxLen = max(maxLen, it.optShort.length + it.optLong.length + sep);
            }
            isNextOpt ~= true;
            continue;
        } else
        static if(isOption!A) {
            int sep = arg.optShort == "" ? 0 : 2;
            maxLen = max(maxLen, arg.optShort.length + arg.optLong.length + sep);
            isNextOpt ~= true;
            continue;
        } else
        static if(isString!A) {
            isNextOpt ~= false;
            continue;
        }
    }

    int i = 0;
    foreach (arg; args) {
        alias A = typeof(arg);
        static if(isOptionArray!A) {
            foreach (it; arg) {
                string opts = it.optShort ~ (it.optShort == "" ? "" : ", ") ~ it.optLong;
                writefln("  %-*s  %s", maxLen, opts, it.help);
            }
        } else
        static if(isOption!A) {
            string opts = arg.optShort ~ (arg.optShort == "" ? "" : ", ") ~ arg.optLong;
            writefln("  %-*s  %s", maxLen, opts, arg.help);
        } else
        static if(isString!A) {
            bool nopt = i + 1 < isNextOpt.length ? (isNextOpt[ i + 1 ]) : (false);
            bool popt = i - 1 > 0 ? (isNextOpt[ i - 1 ]) : (false);
            writefln((popt ? "\n" : "") ~ arg ~ (nopt ? ":" : "\n"));
        }

        ++i;
    }
}
