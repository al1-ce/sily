/// Simple mixin property getter/setter generator
module sily.property;

import std.traits;

/**
Generates mixin for automatic property injection. All properties
are created as `public final @property`.

Important! If symbol with same name, as property going to be, is present
then D will completely override property with that symbol

Example:
---
// Generates property for "_data" with name "data"
mixin property!_data;
// Generates only getter for "_data" with name "data"
mixin getter!_data;
// Generates only setter for "_data" with name "data"
mixin setter!_data;

// Prefix manipulation, works with getter! and setter! too
// _data -> data (removes "_" prefix, default behaviour)
mixin property!_data;
// __data -> data (removes supplied prefix)
mixin property!(__data, "__");
// __data -> gdata (replaces supplied prefix)
mixin property!(__data, "__", "g");
// _data -> c_data (adds new prefix)
mixin property!(_data, "", "c");
// _data -> _data (can't match prefix, keeping as is)
mixin property!(_data, "A");
mixin property!(_data, "A", "B");
// _data -> propertyData (replaces entire name)
mixin property!(_data, "propertyData", true);
---
*/
mixin template property(alias symbol, string prefixRem = "_", string prefixAdd = "") {
    mixin( ___silyPropertyGenGetter!(symbol, prefixRem, prefixAdd, false) );
    mixin( ___silyPropertyGenSetter!(symbol, prefixRem, prefixAdd, false) );
}

/// Ditto
mixin template setter(alias symbol, string prefixRem = "_", string prefixAdd = "") {
    mixin( ___silyPropertyGenSetter!(symbol, prefixRem, prefixAdd, false) );
}

/// Ditto
mixin template getter(alias symbol, string prefixRem = "_", string prefixAdd = "") {
    mixin( ___silyPropertyGenGetter!(symbol, prefixRem, prefixAdd, false) );
}

/// Ditto
mixin template property(alias symbol, string symbolRename, bool B) if (B == true) {
    mixin( ___silyPropertyGenGetter!(symbol, "", symbolRename, true) );
    mixin( ___silyPropertyGenSetter!(symbol, "", symbolRename, true) );
}

/// Ditto
mixin template setter(alias symbol, string symbolRename, bool B) if (B == true) {
    mixin( ___silyPropertyGenSetter!(symbol, "", symbolRename, true) );
}

/// Ditto
mixin template getter(alias symbol, string symbolRename, bool B) if (B == true) {
    mixin( ___silyPropertyGenGetter!(symbol, "", symbolRename, true) );
}

static string ___silyPropertyGenGetter(alias symbol, string prefixStringRem,
                        string prefixStringAdd, bool prefixAsRename = false)() {
    import std.algorithm.searching: countUntil;
    import std.string: format;
    import std.array: replaceFirst;
    string _symname = __traits(identifier, symbol);
    string _getname = __traits(identifier, symbol);
    string _type = typeof(symbol).stringof;
    if (prefixAsRename) {
        _getname = prefixStringAdd;
    } else {
        if (_symname.countUntil(prefixStringRem) == 0) {
            _getname = _symname.replaceFirst(prefixStringRem, prefixStringAdd);
        }
        if (prefixStringRem == "") _getname = prefixStringAdd ~ _symname;
    }
    return "public final %s %s() @property { return %s; }".format(
        _type, _getname, _symname
    );
}

static string ___silyPropertyGenSetter(alias symbol, string prefixStringRem,
                        string prefixStringAdd, bool prefixAsRename = false)() {
    import std.algorithm.searching: countUntil;
    import std.string: format;
    import std.array: replaceFirst;
    string _symname = __traits(identifier, symbol);
    string _setname = __traits(identifier, symbol);
    string _type = typeof(symbol).stringof;
    if (prefixAsRename) {
        _setname = prefixStringAdd;
    } else {
        if (_symname.countUntil(prefixStringRem) == 0) {
            _setname = _symname.replaceFirst(prefixStringRem, prefixStringAdd);
        }
        if (prefixStringRem == "") _setname = prefixStringAdd ~ _symname;
    }
    return "public final %s %s(%s p_val) @property { return (%s = p_val); }".format(
        _type, _setname, _type, _symname
    );
}

/* -------------------------- String mixin version -------------------------- */

/**
Generates string for automatic property injection with string mixin.
All properties are created as `public final @property`
Example:
---
// Generates property for "_data" with name "data"
mixin(property!_data);
// Generates only getter for "_data" with name "data"
mixin(getter!_data);
// Generates only setter for "_data" with name "data"
mixin(setter!_data);

// Prefix manipulation, works with getter! and setter! too
// _data -> data (removes "_" prefix, default behaviour)
mixin(property!_data);
// __data -> data (removes supplied prefix)
mixin(property!(__data, "__"));
// __data -> gdata (replaces supplied prefix)
mixin(property!(__data, "__", "g"));
// _data -> c_data (adds new prefix)
mixin(property!(_data, "", "c"));
// _data -> _data (can't match prefix, keeping as is)
mixin(property!(_data, "A"));
mixin(property!(_data, "A", "B"));
// _data -> propertyData (replaces entire name)
mixin(property!(_data, "propertyData", true));
---
*/
// static string property(alias symbol, string prefixRem = "_", string prefixAdd = "")() {
//     return ___silyPropertyGenGetter!(symbol, prefixRem, prefixAdd, false) ~ "\n" ~
//            ___silyPropertyGenSetter!(symbol, prefixRem, prefixAdd, false);
// }

// /// Ditto
// static string setter(alias symbol, string prefixRem = "_", string prefixAdd = "")() {
//     return ___silyPropertyGenSetter!(symbol, prefixRem, prefixAdd, false);
// }

// /// Ditto
// static string getter(alias symbol, string prefixRem = "_", string prefixAdd = "")() {
//     return ___silyPropertyGenGetter!(symbol, prefixRem, prefixAdd, false);
// }

// /// Ditto
// static string property(alias symbol, string symbolRename, bool B)() if (B == true) {
//     return ___silyPropertyGenGetter!(symbol, "", symbolRename, true) ~ "\n" ~
//            ___silyPropertyGenSetter!(symbol, "", symbolRename, true);
// }

// /// Ditto
// static string setter(alias symbol, string symbolRename, bool B)() if (B == true) {
//     return ___silyPropertyGenSetter!(symbol, "", symbolRename, true);
// }

// /// Ditto
// static string getter(alias symbol, string symbolRename, bool B)() if (B == true) {
//     return ___silyPropertyGenGetter!(symbol, "", symbolRename, true);
// }
