module sily.html.token;

import std.ascii: isWhite;

import sily.html.lexer: stripWhitespace;

// TODO: classes?
// TODO: proper html?

/// READONLY! html struct
struct HTMLTag {
    private Tag* _tag;

    @disable this();

    /// Tag type (i.e `a`, `img`). For text tags it's empty
    @property string type() { return (*_tag).type; }

    /// InnerText (only used when tag is empty)
    @property string text() { return (*_tag).text; }

    /// Tag attributes
    @property string[string] attributes() { return (*_tag).attributes; }

    /// Tag children
    @property HTMLTag[] children() {
        HTMLTag[] c = [];
        foreach (child; (*_tag).children) {
            c ~= HTMLTag(child);
        }
        return c;
    }

    this(string _type) {
        _tag = new Tag(_type);
    }

    this(Tag* tag) {
        _tag = tag;
    }

    this(string _type, string _text) {
        _tag = new Tag(_type, _text);
    }

    this(string _type, Tag*[] _children) {
        _tag = new Tag(_type, _children);
    }

    this(string _type, HTMLTag[] _children) {
        Tag*[] childs = [];
        foreach (child; _children) {
            childs ~= child._tag;
        }

        _tag = new Tag(_type, childs);
    }

    this(string _type, string[string] _attr) {
        _tag = new Tag(_type, _attr);
    }

    this(string _type, string[string] _attr, Tag*[] _children) {
        _tag = new Tag(_type, _attr, _children);
    }

    this(string _type, string[string] _attr, HTMLTag[] _children) {
        Tag*[] childs = [];
        foreach (child; _children) {
            childs ~= child._tag;
        }
        _tag = new Tag(_type, _attr, childs);
    }

    string toString() const {
        return (*_tag).toString();
    }
}

private struct Tag {
    /// Type of tag
    string type = "";
    /// Text (only for empty tags)
    string text = "";
    /// Tag attributes
    string[string] attributes;
    /// Child tags (not allowed for empty tags)
    Tag*[] children;

    string toString() const {
        if (type == "") return text;
        string attrstr = "";
        if (attributes.keys.length) {
            foreach (k; attributes.keys) {
                attrstr ~= k ~ "=\"" ~ attributes[k] ~ "\" ";
            }
            attrstr = " " ~ attrstr[0..$-1];
        }

        string textstr = text;

        if (children.length) {
            foreach (child; children) textstr ~= (*child).toString();
        }

        return "<" ~ type ~ attrstr ~ ">" ~ textstr ~ "</" ~ type ~ ">";
    }

    this(string _type) {
        type = _type.stripWhitespace();
    }

    this(string _type, string _text) {
        type = _type.stripWhitespace();
        text = _text.stripWhitespace();
    }

    this(string _type, Tag*[] _children) {
        type = _type.stripWhitespace();
        children = _children;
    }

    this(string _type, string[string] _attr) {
        type = _type;
        attributes = _attr;
    }

    this(string _type, string[string] _attr, Tag*[] _children) {
        type = _type;
        attributes = _attr;
        children = _children;
    }
}

