/// Utilities to work with C bindings (e.g. OpenGL, SDL)
module sily.clang;

import std.traits: isNumeric, isArray;

import sily.array: deepLength, ArrayBaseType;

import core.stdc.config: c_long, c_ulong;
import core.stdc.stdint: intptr_t, uintptr_t;

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
    return cast(csize_t) (deepLength(var) * (ArrayBaseType!T).sizeof);
}

