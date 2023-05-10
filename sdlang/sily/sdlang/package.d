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
---
Defined types:
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

// TODO: sdlang lookups
// hasValue
// hasAttribute
// hasNode
// etc...
/*
bool isType(NodeType T)(Node node) {
bool hasKeyType(NodeType T)(Node node, string key) {
bool hasKeyAs(T)(Node node, string key) {
void getKey(T)(Node node, T* variable, string field) {
*/
