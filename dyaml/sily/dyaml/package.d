/// dYaml wrapper
module sily.dyaml;

import dyaml;

/**
Checks if node is NodeType.

Usage:
---
node.isType!NodeType.mapping;
---

Params:
    node = Node to check
*/
public bool isType(NodeType T)(Node node) {
    if (node.type == T) {
        return true;
    }
    return false;
}

/**
Checks if node has key of NodeType.

Usage:
---
node.hasKeyType!(NodeType.mapping)("keymap");
---

Params:
    node = Node to get key from
    key = Key name
*/
public bool hasKeyType(NodeType T)(Node node, string key) {
    if (node.containsKey(key)) {
        if (node[key].type == T) {
            return true;
        }
    }
    return false;
}

/**
Checks if node has key of type.

Usage:
---
node.hasKeyAs!bool("useColor");
---

Params:
    node = Node to get key from
    key = Key name
*/
public bool hasKeyAs(T)(Node node, string key) {
    if (node.containsKey(key)) {
        if (node[key].convertsTo!T) {
            return true;
        }
    }
    return false;
}

/**
Puts value from node key if key exists.

Usage:
---
node.getKey!bool(&useColor, "useColor");
---

Params:
    node = Node to get key from
    variable = Pointer to variable
    field = Key name
*/
public void getKey(T)(Node node, T* variable, string field) {
    if (node.hasKeyAs!T(field)) {
        *variable = node[field].as!T;
    }
}