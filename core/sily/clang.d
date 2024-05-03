// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/// Utilities to work with C bindings (e.g. OpenGL, SDL)
module sily.clang;

import std.traits: isNumeric, isArray;

// import core.stdc.config: c_long, c_ulong;
// import core.stdc.stdint: intptr_t, uintptr_t;

/// C types (in form of cDTYPE, i.e clang size_t -> csize_t)
alias csize_t = uint;

// version (X86_64) {
// } else {
// }

/// Returns C style size
csize_t csizeof(T)(T var) if (isNumeric!T) {
    return cast(csize_t) (var * T.sizeof);
}

/// Ditto
csize_t csizeof(T)(T var) if (isArray!T) {
    import sily.array: deepLength, ArrayBaseType;
    return cast(csize_t) (deepLength(var) * (ArrayBaseType!T).sizeof);
}

// Returns C style pointer array
const (char*)[] cstringList(string[] list) {
    import std.string : toStringz; // toStringz() - adds null terminator, allocates using GC if necessary
    import std.array : array; // array() - eagerly converts range to array, allocates using GC
    import std.algorithm : map; // map() - apply function to range
    return list.map!(toStringz).array();
}
