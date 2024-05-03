// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/++
Custom SDLang parser. Fully compatible with SDLang language reference

Added features:
- Attributes without a value will be assumed to have value of `true`
    or if they have ! before them then they are assumed to be false
---
// `local` will be assumed as if it was `local=true`, same for `override`
// `tagged` will be assumed false
tag type="something" 1 3 local name="tag"
item type="health" override
object type="something" !tagged
---
Justification: this feature allows for quicly tagging the tag

- $, ! and @ are now allowed to be in front of name
---
// All next tags are valid
$tag // ??? tag
!tag // override tag
@tag // ??? tag
---
Justification: this can be used to mark tag with specific usage
// TODO: figure out $!@ usage in tags

- Attributes can now auto-parse some non-string values as if they were tags
---
global:consumable type="item"

food inherit=global:consumable

tea inherit=food
---
Justification: this could be benificial to reference other tags (and only tags)
// TODO: figure out if `tag attr=!othertag` should be allowed (probably no)
+/
module sily.sdl;

import sily.sdl.parser;
public import sily.sdl.types;

/++
Parses SDL string and returns root node
+/
SDLTag parseSDL(string input) {
    // SDLTag[] result;
    // try {
    //     sdl.parseSDLDocument!((n) { result ~= n; })(input, "");
    // } catch (Exception e) {
    //     if (printOnError) {
    //         import std.stdio: writeln;
    //         writeln("EXCEPTION: ", e.message);
    //     }
    // }
    // return result;
    SDLParser parser = SDLParser(input);
    SDLTag tag = parser.parse();
    return tag;
}


/++
Writes SDL data into string
Example:
---
import sily.sdlang;
import std.file;
SDLTag[] arr1 = parseSDL(readText("file.sdl"));
string out = arr1.generateSDL();
---
+/
string generateSDL(SDLTag input) {
    return "";
}

/// Returns true is value `val` is type `T`
bool isType(SDLType T)(SDLValue val) {
    // return val.kind == T;
    return false;
}

/// Returns true if `node` has child with qualified name `qualifiedName`
bool hasNode(SDLTag node, string qualifiedName) {
    foreach(child; node.children) {
        if (child.qualifiedName == qualifiedName) return true;
    }
    return false;
}

/// Returns child of `node` with qualified name `qualifiedName`
SDLTag getNode(SDLTag node, string qualifiedName) {
    foreach(child; node.children) {
        if (child.qualifiedName == qualifiedName) return child;
    }
    return SDLTag.init;
}
/// Ditto
alias node = getNode;

/// Returns children of `node` with qualified name `qualifiedName`
SDLTag[] getNodes(SDLTag node, string qualifiedName) {
    SDLTag[] arr = [];
    foreach(child; node.children) {
        if (child.qualifiedName == qualifiedName) arr ~= child;
    }
    return arr;
}

/// Returns nodes from `nodes` array with qualified name `qualifiedName`
SDLTag[] getNodes(SDLTag[] nodes, string qualifiedName) {
    SDLTag[] arr = [];
    foreach(child; nodes) {
        if (child.qualifiedName == qualifiedName) arr ~= child;
    }
    return arr;
}

/// Alias to `getNodes(SDLTag, string)` and `getNodes(SDLTag[], string)`
alias nodes = getNodes;

/// Returns true if `node` has attribute with qualified name `qualifiedName`
bool hasAttribute(SDLTag node, string qualifiedName) {
    foreach(attrib; node.attributes) {
        if (attrib.qualifiedName == qualifiedName) return true;
    }
    return false;
}

/// Returns true if `node` has attribute with qualified name `qualifiedName` of type `T`
bool hasAttribute(SDLType T)(SDLTag node, string qualifiedName) {
    foreach(attrib; node.attributes) {
        if (attrib.qualifiedName == qualifiedName && attrib.value.kind == T) return true;
    }
    return false;
}

/// Returns all values of type `S` as type `T` from node.
T[] getValues(T)(SDLTag node, SDLType type) {
    T[] arr = [];
    foreach (val; node.values) {
        if (val.kind == type) arr ~= val.value!T;
    }
    return arr;
}

/// Returns all values of type `S` as type `T` from nodes. Useful when dealing with matrices
T[] getValues(T)(SDLTag[] node, SDLType type) {
    T[] arr = [];
    foreach (n; node) {
        foreach (val; n.values) {
            if (val.kind == type) arr ~= val.value!T;
        }
    }
    return arr;
}

/// Alias to `getValues(T)(SDLTag, SDLType)` and `getValues(T)(SDLTag[], SDLType)`
alias values = getValues;

/// Returns count of values of type `T`
size_t hasValues(SDLType T)(SDLTag node) {
    size_t size = 0;
    // foreach (val; node.values) {
    //     if (val.kind == type) ++size;
    // }
    return size;
}
/// Ditto
size_t hasValues(SDLType T)(SDLTag[] node) {
    size_t size = 0;
    // foreach (n; node) {
    //     foreach (val; n.values) {
    //         if (val.kind == type) ++size;
    //     }
    // }
    return size;
}
/// Ditto
alias value = hasValues;

/// Returns attribute value with qualified name `qualifiedName` and type as `T`
T getAttribute(T)(SDLTag node, string qualifiedName) {
    if (node.hasAttribute(qualifiedName)) {
        return node.getAttribute(qualifiedName).value!T;
    }
    return T.init;
}

/// Alias to `getAttribute(T)(SDLTag, string)`
alias attribute = getAttribute;

/// Returns SDLang attribute value as T
T getValue(T)(SDLAttribute attr) {
    // return attr.value.value!T;
    return T.init;
}
/// Ditto
alias value = getValue;

