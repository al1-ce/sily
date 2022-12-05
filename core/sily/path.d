/// Path manipulation utils
module sily.path;

import std.path : absolutePath, buildNormalizedPath, expandTilde;

/** 
Normalises path, expands tilde and builds absolute path
Params:
  path = Path
Returns: 
 */
string fixPath(string path) { 
    return path.buildNormalizedPath.expandTilde.absolutePath; 
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
