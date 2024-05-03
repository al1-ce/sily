// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

module sily.sdl.types;

import std.datetime: Date, Duration, SysTime;

private alias binary_t = immutable(ubyte)[];

struct SDLTag {
    /// Name of tag (`name ...`)
    string name;
    /// Namespace of tag (`namespace:... ...`)
    string namespace;
    /// Qualified name (`namepsace:name`)
    string qualifiedName;
    /// Array of values (`tag val1 val2`)
    SDLValue[] values;
    /// Array of attributes (`tag attr=2`)
    SDLAttribute[] attributes;
    /// Array of children (`tag { child1; child2 }`)
    SDLTag[] children;

    @property bool empty() => !(
        qualifiedName.length != 0 ||
        values.length != 0 ||
        attributes.length != 0 ||
        children.length != 0
    );

    string toString() const {
        import std.conv: to;
        string s;
        s ~= qualifiedName;
        foreach (value; values) {
            s ~= " ";
            s ~= value.toString();
        }
        foreach (attribute; attributes) {
            s ~= " ";
            s ~= attribute.toString();
        }
        if (children.length != 0) {
            s ~= " {\n";
            foreach (child; children) {
                s ~= child.toString();
                s ~= "\n";
            }
            s ~= "}\n";
        }
        return s;
    }
}

struct SDLValue {
    private SDLValueBox _value;
    private SDLType _type = SDLNull;

    /// Sets value
    @property void value(T)(T val) if (IS_VALID_SDL_TYPE!T) => assignSDLValue!T(_value, _type, val);

    /// Returns value
    @property T value(T)() if (IS_VALID_SDL_TYPE!T) => getSDLValue!T(_value, _type);

    /// Returns type
    @property SDLType type() => _type;

    /// Constructs new value
    this(T)(T val) if (IS_VALID_SDL_TYPE!T) {
        assignSDLValue!(T)(_value, _type, val);
    }

    private union SDLValueBox {
        void*    null_ = null;
        string   text;
        binary_t binary;
        int      int_;
        long     long_;
        long[2]  decimal;
        float    float_;
        double   double_;
        bool     bool_;
        SysTime  dateTime;
        Date     date;
        Duration duration;
    }

    string toString() const {
        return getSDLValueString(_value, _type);
    }
}

struct SDLAttribute {
    /// Attribute name
    string name;
    /// Attribute namespace
    string namespace;
    /// Qualified name
    string qualifiedName;
    /// Attribute value
    SDLValue value;

    string toString() const {
        return qualifiedName ~ " = " ~ value.toString();
    }
}


private bool IS_VALID_SDL_TYPE(T)() {
    static if (
            is(T == void*)  || is(T == string) || is(T == immutable(ubyte)[]) ||
            is(T == int)    || is(T == long)   || is(T == long[2]) || is(T == float) ||
            is(T == double) || is(T == bool)   || is(T == SysTime) || is(T == Date) ||
            is(T == Duration)
            ) {
        return true;
    } else {
        return false;
    }
}

private void assignSDLValue(T)(ref SDLValue.SDLValueBox box, ref SDLType type, T value) {
    static if (is(T == void*))    { box.null_    =  null; type = SDLNull; }
    static if (is(T == string))   { box.text     = value; type = SDLString; }
    static if (is(T == binary_t)) { box.binary   = value; type = SDLBinary; }
    static if (is(T == int))      { box.int_     = value; type = SDLInt; }
    static if (is(T == long))     { box.long_    = value; type = SDLLong; }
    static if (is(T == long[2]))  { box.decimal  = value; type = SDLDecimal; }
    static if (is(T == float))    { box.float_   = value; type = SDLFloat; }
    static if (is(T == double))   { box.double_  = value; type = SDLDouble; }
    static if (is(T == bool))     { box.bool_    = value; type = SDLBool; }
    static if (is(T == SysTime))  { box.dateTime = value; type = SDLDateTime; }
    static if (is(T == Date))     { box.date     = value; type = SDLDate; }
    static if (is(T == Duration)) { box.duration = value; type = SDLDuration; }
}

private T getSDLValue(T)(ref SDLValue.SDLValueBox box, ref SDLType type) {
    static if (is(T == void*))    { return null; }
    static if (is(T == string))   { if (type == SDLString)   return box.text;     else return T.init; }
    static if (is(T == binary_t)) { if (type == SDLBinary)   return box.binary;   else return T.init; }
    static if (is(T == int))      { if (type == SDLInt)      return box.int_;     else return T.init; }
    static if (is(T == long))     { if (type == SDLLong)     return box.long_;    else return T.init; }
    static if (is(T == long[2]))  { if (type == SDLDecimal)  return box.decimal;  else return T.init; }
    static if (is(T == float))    { if (type == SDLFloat)    return box.float_;   else return T.init; }
    static if (is(T == double))   { if (type == SDLDouble)   return box.double_;  else return T.init; }
    static if (is(T == bool))     { if (type == SDLBool)     return box.bool_;    else return T.init; }
    static if (is(T == SysTime))  { if (type == SDLDateTime) return box.dateTime; else return T.init; }
    static if (is(T == Date))     { if (type == SDLDate)     return box.date;     else return T.init; }
    static if (is(T == Duration)) { if (type == SDLDuration) return box.duration; else return T.init; }
}

private string getSDLValueString(const ref SDLValue.SDLValueBox box, const ref SDLType type) {
    import std.conv: to;
    if (type == SDLNull)     return "null";
    if (type == SDLString)   return '\"' ~ box.text ~ '\"';
    if (type == SDLBinary)   return box.binary.to!string;
    if (type == SDLInt)      return box.int_.to!string;
    if (type == SDLLong)     return box.long_.to!string;
    if (type == SDLDecimal)  return box.decimal.to!string;
    if (type == SDLFloat)    return box.float_.to!string;
    if (type == SDLDouble)   return box.double_.to!string;
    if (type == SDLBool)     return box.bool_.to!string;
    if (type == SDLDateTime) return box.dateTime.to!string;
    if (type == SDLDate)     return box.date.to!string;
    if (type == SDLDuration) return box.duration.to!string;
    return "";
}

/// Type of SDLang value
enum SDLType {
    null_,
    text,
    binary,
    int_,
    long_,
    decimal,
    float_,
    double_,
    bool_,
    dateTime,
    date,
    duration
}
/// Ditto
alias SDLNull     = SDLType.null_;
/// Ditto
alias SDLString   = SDLType.text;
/// Ditto
alias SDLBinary   = SDLType.binary;
/// Ditto
alias SDLInt      = SDLType.int_;
/// Ditto
alias SDLLong     = SDLType.long_;
/// Ditto
alias SDLDecimal  = SDLType.decimal;
/// Ditto
alias SDLFloat    = SDLType.float_;
/// Ditto
alias SDLDouble   = SDLType.double_;
/// Ditto
alias SDLBool     = SDLType.bool_;
/// Ditto
alias SDLDateTime = SDLType.dateTime;
/// Ditto
alias SDLDate     = SDLType.date;
/// Ditto
alias SDLDuration = SDLType.duration;

