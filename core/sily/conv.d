// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/// Type conversion utilities
module sily.conv;

import std.conv: to;

/// Converts array of arguments into type T
T format(T, A...)(A args) {
    T out_ = [];
    foreach (arg; args) {
        out_ ~= arg.to!T;
    }
    return out_;
}
