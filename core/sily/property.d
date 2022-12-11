module sily.property;

import std.traits;

/**
Generates mixin for automatic property injection
Example:
---
// Generates property for "_data" with name "data"
mixin property!_data;
// Generates only getter for "_data" with name "data"
mixin getter!_data;
// Generates only setter for "_data" with name "data"
mixin setter!_data;

// Prefix manipulation, works with getter! and setter! too
// __data -> data (removes supplied prefix)
mixin property!(__data, "__");
// __data -> gdata (replaces supplied prefix)
mixin property!(__data, "__", "g");
// _data -> c_data (adds new prefix)
mixin property!(_data, "", "c");
// _data -> _data (can't match prefix, keeping as is)
mixin property!(_data, "A");
---
*/
private mixin template property(alias symbol, bool _genSetter, bool _genGetter, 
    string prefixStringRem, string prefixStringAdd) {

    static string genGetter() {
        import std.algorithm.searching: countUntil;
        import std.string: format;
        import std.array: replaceFirst;
        string _symname = __traits(identifier, symbol);
        string _getname = __traits(identifier, symbol);
        string _type = typeof(symbol).stringof;
        if (_symname.countUntil(prefixStringRem) == 0) {
            _getname = _symname.replaceFirst(prefixStringRem, prefixStringAdd);
        }
        if (prefixStringRem == "") _getname = prefixStringAdd ~ _symname;
        return "%s %s() @property { return %s; }".format(
            _type, _getname, _symname
        );
    }

    static string genSetter() {
        import std.algorithm.searching: countUntil;
        import std.string: format;
        import std.array: replaceFirst;
        string _symname = __traits(identifier, symbol);
        string _setname = __traits(identifier, symbol);
        string _type = typeof(symbol).stringof;
        if (_symname.countUntil(prefixStringRem) == 0) {
            _setname = _symname.replaceFirst(prefixStringRem, prefixStringAdd);
        }
        if (prefixStringRem == "") _setname = prefixStringAdd ~ _symname;
        return "%s %s(%s p_val) @property { return (%s = p_val); }".format(
            _type, _setname, _type, _symname
        );
    }

    static if (_genGetter) mixin( genGetter() );
    static if (_genSetter) mixin( genSetter() );
}

/// Ditto
mixin template property(alias symbol, string prefixRem = "_", string prefixAdd = "") {
    mixin property!(symbol, true, true, prefixRem, prefixAdd);
}

/// Ditto
mixin template setter(alias symbol, string prefixRem = "_", string prefixAdd = "") {
    mixin property!(symbol, true, false, prefixRem, prefixAdd);
}

/// Ditto
mixin template getter(alias symbol, string prefixRem = "_", string prefixAdd = "") {
    mixin property!(symbol, false, true, prefixRem, prefixAdd);
}