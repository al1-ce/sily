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
  path = Path to dir
Returns:
 */
string[] listdir(string path, bool listDirs = true, bool listFiles = true) {
    import std.algorithm;
    import std.array;
    import std.file;
    import std.path;

    path = buildAbsolutePath(path);
    if (!exists(path) || !isDir(path)) return [];

    return std.file.dirEntries(path, SpanMode.shallow)
        .filter!(a => listFiles ? true : a.isFile || listDirs ? true : a.isDir)
        .map!((return a) => baseName(a.name))
        .array;
}
