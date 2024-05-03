// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/// Path manipulation utils
module sily.path;

import std.path : absolutePath, buildNormalizedPath, expandTilde, relativePath;

/**
Normalises path, expands tilde and builds absolute path
Params:
  path = Path
Returns:
 */
string buildAbsolutePath(string p) {
    return p.expandTilde.absolutePath.buildNormalizedPath;
}

/**
Normalises path, expands tilde and builds relative path
Params:
  path = Path
Returns:
 */
string buildRelativePath(string p) {
    return p.expandTilde.relativePath.buildNormalizedPath;
}

/**
Returns array of files/dirs from path
Params:
  pathname = Path to dir
Returns:
 */
string[] listdir(string pathname) {
    import std.algorithm;
    import std.array;
    import std.file;
    import std.path;

    return std.file.dirEntries(pathname, SpanMode.shallow)
        .filter!(a => a.isFile)
        .map!((return a) => baseName(a.name))
        .array;
}
