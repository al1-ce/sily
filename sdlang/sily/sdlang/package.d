/++
Wrapper for SDLite.

Noticable differences between SDLang and SDLite parser:
- Line breaking is not allowed ("title \", newline, "   'value'")
+/
module sily.sdlang;

import sdl = sdlite;
import std.range;

import taggedalgebraic.taggedunion;

/++
Representation of single sdlang node
Example:
---
// Create SDLNode. SDLNode("name", SDLValue[] values, SDLAttribute[] attributes, SDLNode[] children)
SDLNode node = SDLNode("name", [SDLValue.text("values")], [], []);
// Get name
node.name;
// Get namespace
node.namespace;
// Get/Set qualified name (eq to namespace:name)
node.qualifiedName;
node.qualifiedName = "namespace:name";
// Get array of values (aka 'node 1 "b" v=2' -> returns 1 "b")
node.values;
// Get array of attributes (aka 'node 1 "b" v=2' -> returns v=2)
node.attributes;
// Get array of children
node.children;
// Gets attribute by qualified name
node.getAttribute("email")
// Gets attribute by qualified name with default value
node.getAttribute("email", SDLValue.text("mail@mail.com"))
---
+/
alias SDLNode = sdl.SDLNode;

/++
Value of sdlang node
Example:
---
// Create new value
SDLValue val = SDLValue.double_(22.5);  
// Get value casted to int
val.value!int;
// Check type
val.kind == SDLType.text;
---
+/
alias SDLValue = sdl.SDLValue;

/++
Attribute of sdlang node (attr="val")
Example:
---
// Create new attribute
SDLAttribute attr = SDLAttribute("qualifiedName", SDLValue.text("value"));
// Get name
attr.name;
// Get namepsace
attr.namespace;
// Get/Set qualified name (namespace:name)
attr.qualifiedName;
attr.qualifiedName = "namespace:name";
// Get/Set value
attr.value;
attr.value = SDLValue.text("new value")
---
+/
alias SDLAttribute = sdl.SDLAttribute;

/++
Alias to SDLValue.Kind. Represents type of SDLValue.
Example:
---
node.values[0].kind == SDLType.float_;
node.values[0].kind == SDLFloat;
---
Defined types (have aliases in form `SDLTypeName`, i.e SDLBinary or SDLDateTime):
---
Void null_;
string text;
immutable(ubyte)[] binary;
int int_;
long long_;
long[2] decimal;
float float_;
double double_;
bool bool_;
SysTime dateTime;
Date date;
Duration duration;
---
+/
alias SDLType = sdl.SDLValue.Kind;
/// Ditto
alias SDLNull = SDLType.null_;
/// Ditto
alias SDLString = SDLType.text;
/// Ditto
alias SDLBinary = SDLType.binary;
/// Ditto
alias SDLInt = SDLType.int_;
/// Ditto
alias SDLLong = SDLType.long_;
/// Ditto
alias SDLDecimal = SDLType.decimal;
/// Ditto
alias SDLFloat = SDLType.float_;
/// Ditto
alias SDLDouble = SDLType.double_;
/// Ditto
alias SDLBool = SDLType.bool_;
/// Ditto
alias SDLDateTime = SDLType.dateTime;
/// Ditto
alias SDLDate = SDLType.date;
/// Ditto
alias SDLDuration = SDLType.duration;

/++
Parses SDL string into SDLNode[]
Example:
---
import sily.sdlang;
import std.file;
SDLNode[] arr1 = parseSDL(readText("file.sdl"));
SDLNode[] arr2 = parseSDL("name \"Direct SDLang parsing\" cool=true");
SDLNode[] arr3 = parseSDL("name will print parsing error", true);
---
+/
SDLNode[] parseSDL(string input, bool printOnError = false) {
    SDLNode[] result;
    try {
        sdl.parseSDLDocument!((n) { result ~= n; })(input, "");
    } catch (Exception e) {
        if (printOnError) {
            import std.stdio: writeln;
            writeln("EXCEPTION: ", e.message);
        }
    }
    return result;
}

private alias generateSDLang = sdl.generateSDLang;

/++
Writes SDL data into string
Example:
---
import sily.sdlang;
import std.file;
SDLNode[] arr1 = parseSDL(readText("file.sdl"));
string out = arr1.generateSDL();
---
+/
string generateSDL(SDLNode[] input) {
    auto app = appender!string;
    app.generateSDLang(input);
    return app.data;
}

/// Ditto
string generateSDL(SDLNode input) {
    auto app = appender!string;
    app.generateSDLang(input);
    return app.data;
}

/// Ditto
string generateSDL(SDLValue input) {
    auto app = appender!string;
    app.generateSDLang(input);
    return app.data;
}

/// Returns true is value `val` is type `T`
bool isType(SDLType T)(SDLValue val) {
    return val.kind == T;
}

/// Returns true if `node` has child with qualified name `qualifiedName`
bool hasNode(SDLNode node, string qualifiedName) {
    foreach(child; node.children) {
        if (child.qualifiedName == qualifiedName) return true;
    }
    return false;
}

/// Returns child of `node` with qualified name `qualifiedName`
SDLNode getNode(SDLNode node, string qualifiedName) {
    foreach(child; node.children) {
        if (child.qualifiedName == qualifiedName) return child;
    }
    return SDLNode.init;
}
/// Ditto
alias node = getNode;

/// Returns children of `node` with qualified name `qualifiedName`
SDLNode[] getNodes(SDLNode node, string qualifiedName) {
    SDLNode[] arr = [];
    foreach(child; node.children) {
        if (child.qualifiedName == qualifiedName) arr ~= child;
    }
    return arr;
}

/// Returns nodes from `nodes` array with qualified name `qualifiedName`
SDLNode[] getNodes(SDLNode[] nodes, string qualifiedName) {
    SDLNode[] arr = [];
    foreach(child; nodes) {
        if (child.qualifiedName == qualifiedName) arr ~= child;
    }
    return arr;
}

/// Alias to `getNodes(SDLNode, string)` and `getNodes(SDLNode[], string)`
alias nodes = getNodes;

/// Returns true if `node` has attribute with qualified name `qualifiedName`
bool hasAttribute(SDLNode node, string qualifiedName) {
    foreach(attrib; node.attributes) {
        if (attrib.qualifiedName == qualifiedName) return true;
    }
    return false;
}

/// Returns true if `node` has attribute with qualified name `qualifiedName` of type `T`
bool hasAttribute(SDLType T)(SDLNode node, string qualifiedName) {
    foreach(attrib; node.attributes) {
        if (attrib.qualifiedName == qualifiedName && attrib.value.kind == T) return true;
    }
    return false;
}

/// Returns all values of type `S` as type `T` from node.
T[] getValues(T)(SDLNode node, SDLType type) {
    T[] arr = [];
    foreach (val; node.values) {
        if (val.kind == type) arr ~= val.value!T;
    }
    return arr;
}

/// Returns all values of type `S` as type `T` from nodes. Useful when dealing with matrices
T[] getValues(T)(SDLNode[] node, SDLType type) {
    T[] arr = [];
    foreach (n; node) {
        foreach (val; n.values) {
            if (val.kind == type) arr ~= val.value!T;
        }
    }
    return arr;
}

/// Alias to `getValues(T)(SDLNode, SDLType)` and `getValues(T)(SDLNode[], SDLType)`
alias values = getValues;

/// Returns count of values of type `T`
size_t hasValues(SDLType T)(SDLNode node) {
    size_t size = 0;
    foreach (val; node.values) {
        if (val.kind == type) ++size;
    }
    return size;
}
/// Ditto
size_t hasValues(SDLType T)(SDLNode[] node) {
    size_t size = 0;
    foreach (n; node) {
        foreach (val; n.values) {
            if (val.kind == type) ++size;
        }
    }
    return size;
}
/// Ditto
alias value = hasValues;

/// Returns attribute value with qualified name `qualifiedName` and type as `T`
T getAttribute(T)(SDLNode node, string qualifiedName) {
    if (node.hasAttribute(qualifiedName)) { 
        return node.getAttribute(qualifiedName).value!T;
    }
    return T.init;
}

/// Returns attribute value with qualified name `qualifiedName` and type as `T`
T[] getAttributes(T)(SDLNode[] node, string qualifiedName) {
    T[] arr = [];
    foreach (n; node) {
        if (n.hasAttribute(qualifiedName)) { 
            arr ~= n.getAttribute(qualifiedName).value!T;
        }
    }
    return arr;
}

/// Alias to `getAttribute(T)(SDLNode, string)`
alias attribute = getAttribute;

/// Alias to `getAttributes(T)(SDLNode[], string)`
alias attributes = getAttributes;

/// Returns SDLang attribute value as T
T getValue(T)(SDLAttribute attr) {
    return attr.value.value!T;
}
/// Ditto
alias value = getValue;
