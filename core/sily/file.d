// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/// File manipulation
module sily.file;

import std.stdio: writefln;
import std.file: readText, isFile, exists, FileException;
import std.conv : octal;
import std.file : getAttributes, setAttributes;

import sily.path: buildAbsolutePath;

/**
Performs chmod +x on file
Params:
  name = Path to file
*/
void chmodpx(string path) {
    path = path.buildAbsolutePath();

    if (!path.exists) {
        return;
    }

    path.setAttributes(path.getAttributes | octal!700);
}

/**
Reads file or throws FileException if file doesnt exists
Params:
  path = Path to file
Returns:
*/
string readFile(string path) {
    path = path.buildAbsolutePath();

    if (!path.isFile) {
        throw new FileException("Unable to find file at '%s'.", path);
    }

    return readText(path);
}
