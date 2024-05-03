// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/**
Package containings meta utilities line swizzling or mixins.
*/
module sily.meta.swizzle;
import std.array;
import std.string;
import std.algorithm;

// for my sanity or for sanity of anyone who's seeing this
// is(typeof(A + B)) is basically a check if two types
// are compatible together.
// so 0 + "A" will return false, but 0 + true will return true
/**
Returns true if op between type T and type R is compatible and returns type convertable to E (T)
Example:
---
// Assuming "this" is a vector with type "T"
auto opBinary(string op, R)(in Vector!(R, N) b) const
if ( isValidOp(op, T, R) ) {
    // op
}
// If we want for return value to be float
auto opBinary(string op, R)(in Vector!(R, N) b) const
if ( isValidOp(op, T, R, float) ) {
    // op
}
---
*/
bool isValidOp(string op, T, R, E = T)() pure {
    mixin(`return is( typeof( mixin("T.init"` ~ op ~ `"R.init" ) ): E );`);
}

/* --------------------------------- Swizzle -------------------------------- */

/**
Allows swizzling for vector types "Vector!(Type, Size)". Creates opDispatch
containing available swizzle
Usage:
---
// Params: T, size_t size,  string dataArrayName, string accessString, string dataSep, string accessSep

// Setting up separators automatically
mixin accessByString!(T, 4, "data", "x y z w");

// Data separator can be anything
mixin accessByString!(int, 3, "data", "x,y,z", ",");

// Same for access separator
mixin accessByString!(float, 3, "data", "x,y,z/r,g,b", ",", "/");

// What sily.vector uses:
static if (N == 2 || N == 3 || N == 4) {
    static if (N == 2) private enum AS = "x y|w h|u v";
    else
    static if (N == 3) private enum AS = "x y z|w h d|u v t|r g b";
    else
    static if (N == 4) private enum AS = "x y z w|r g b a";
    mixin accessByString!(T, N, "data", AS);
}
---
*/
mixin template accessByString( T, size_t N, string data, string accessString, string dataSep=" ", string accessSep="|")
    if( isCompatibleArrayAccessStrings(N,accessString,dataSep,accessSep) ) {
    pure @property {
        T opDispatch(string v)() const if( getIndex(accessString,v,dataSep,accessSep) != -1 ) {
            mixin( format( "return this.%s[%d];", data, getIndex(accessString,v,dataSep,accessSep) ) );
        }

        ref T opDispatch(string v)() if( getIndex(accessString,v,dataSep,accessSep) != -1 ) {
            mixin( format( "return this.%s[%d];", data, getIndex(accessString,v,dataSep,accessSep) ) );
        }

        static if( isOneSymbolPerFieldForAnyAccessString(accessString,dataSep,accessSep) ) {
            auto opDispatch(string v)() const
            if( v.length > 1 && oneOfAnyAccessAll(accessString,v,dataSep,accessSep) ) {
                static string gen() {
                    string[] res;
                    foreach( i, sym; v )
                        res ~= format( "this.%s[%d]", data, getIndex( accessString, ""~sym, dataSep, accessSep ) );
                    return res.join(",");
                }

                mixin( `return Vector!(T, v.length)(` ~ gen() ~ `);` );
            }

            auto opDispatch(string v,U)( in U b )
            if( v.length > 1 && oneOfAnyAccessAll(accessString,v,dataSep,accessSep) &&
                isCompatibleArrayAccessString(v.length,v) &&
            ( isSpecVector!(v.length,T,U) || ( isDynamicVector!U && is(typeof(T(U.datatype.init))) ) ) ) {
                static if( b.isDynamic ) enforce( v.length == b.length );

                static string gen() {
                    string[] res;
                    foreach( i, sym; v )
                        res ~= format( "this.%s[%d] = T( b[%d] );", data,
                                    getIndex( accessString, ""~sym, dataSep, accessSep ), i );
                    return res.join("\n");
                }

                mixin( gen() );
                return b;
            }
        }
    }
}

/// compatible for creating access dispatches
pure bool isCompatibleArrayAccessStrings( size_t N, string str, string sep1="", string sep2="|" )
in { assert( sep1 != sep2 ); } do {
    auto strs = str.split(sep2);
    foreach( s; strs )
        if( !isCompatibleArrayAccessString(N,s,sep1) )
            return false;

    string[] fa;
    foreach( s; strs )
        fa ~= s.split(sep1);

    foreach( ref v; fa ) v = strip(v);

    foreach( i, a; fa )
        foreach( j, b; fa )
            if( i != j && a == b ) return false;

    return true;
}


/// compatible for creating access dispatches
pure bool isCompatibleArrayAccessString( size_t N, string str, string sep="" ) {
    return N == getAccessFieldsCount(str,sep) && isArrayAccessString(str,sep);
}

///
pure bool isArrayAccessString( in string as, in string sep="", bool allowDot=false ) {
    if( as.length == 0 ) return false;
    auto splt = as.split(sep);
    foreach( i, val; splt )
        if( !isValueAccessString(val,allowDot) || canFind(splt[0..i],val) )
            return false;
    return true;
}

///
pure size_t getAccessFieldsCount( string str, string sep ) { return str.split(sep).length; }

///
pure ptrdiff_t getIndex( string as, string arg, string sep1="", string sep2="|" )
in { assert( sep1 != sep2 ); } do {
    foreach( str; as.split(sep2) )
        foreach( i, v; str.split(sep1) )
            if( arg == v ) return i;
    return -1;
}

///
pure bool oneOfAccess( string str, string arg, string sep="" ) {
    auto splt = str.split(sep);
    return canFind(splt,arg);
}

///
pure bool oneOfAccessAll( string str, string arg, string sep="" ) {
    auto splt = arg.split("");
    return all!(a=>oneOfAccess(str,a,sep))(splt);
}

///
pure bool oneOfAnyAccessAll( string str, string arg, string sep1="", string sep2="|" )
in { assert( sep1 != sep2 ); } do {
    foreach( s; str.split(sep2) )
        if( oneOfAccessAll(s,arg,sep1) ) return true;
    return false;
}

/// check symbol count for access to field
pure bool isOneSymbolPerFieldForAnyAccessString( string str, string sep1="", string sep2="|" )
in { assert( sep1 != sep2 ); } do {
    foreach( s; str.split(sep2) )
        if( isOneSymbolPerFieldAccessString(s,sep1) ) return true;
    return false;
}

/// check symbol count for access to field
pure bool isOneSymbolPerFieldAccessString( string str, string sep="" ) {
    foreach( s; str.split(sep) )
        if( s.length > 1 ) return false;
    return true;
}

pure {

    bool isValueAccessString( in string as, bool allowDot=false ) {
        return as.length > 0 &&
        startsWithAllowedChars(as) &&
        (allowDot?(all!(a=>isValueAccessString(a))(as.split("."))):allowedCharsOnly(as));
    }

    bool startsWithAllowedChars( in string as ) {
        switch(as[0]) {
            case 'a': .. case 'z': goto case;
            case 'A': .. case 'Z': goto case;
            case '_': return true;
            default: return false;
        }
    }

    bool allowedCharsOnly( in string as ) {
        foreach( c; as ) if( !allowedChar(c) ) return false;
        return true;
    }

    bool allowedChar( in char c ) {
        switch(c) {
            case 'a': .. case 'z': goto case;
            case 'A': .. case 'Z': goto case;
            case '0': .. case '9': goto case;
            case '_': return true;
            default: return false;
        }
    }

}
