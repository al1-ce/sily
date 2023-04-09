module sily.tui.node;

public import sily.color: col;
public import sily.vector: ivec2;

import std.algorithm.comparison: min, max; 

import sily.terminal: terminalWidth, terminalHeight;
import sily.string: splitStringWidth;

import sily.tui.render;

alias Node = Element*;

private Node root;

static this() {
    root = new Element("root", null, [], "root", [], Size.full, ivec2(0), col(0, 0, 0, 0));
}

private const string _upperBlock = "\u2580";
private const string _lowerBlock = "\u2584";


/*
To class or not to class
If to make element a class then I'd be able to easily define everything
by inheriting main class
But structs are kind of more memory efficient

Needed elements (bare minimum):
    - Panel (box)
    - Label (text/paragraph/header)
    - Button (input?)
    - Canvas (hard rendering)

Logically they all can be a single element type which you can
Node n = get!("#myelement").add();
n.addEventListener(Evt.mousePress, function() {});
n.drawCurve(vec2()...)

Struct it is
*/

private struct Element {
    string _name = "undefined";
    Node _parent = null;
    Node[] _children = [];
    string _id = "";
    string[] _class = [];
    /// Style size, 0-inf - normal size, -1 - Fill, -2 - Auto
    ivec2 _size = Size.full;
    ivec2 _pos = ivec2(0, 0);
    col _backgroundColor = col(0.2f);
    col _textColor = col(1.0f);
    dstring _text = "";
    TextHAlign _halign = TextHAlign.center;
    TextVAlign _valign = TextVAlign.middle;
    // TODO: border
    // TODO: text decorations
    // TODO: padding?
    // TODO: priority (draw order)

    // Should be always true at start or forceRender at start
    bool _renderNeeded = true;

    
    /**
    Creates "tree" representation in format:
    ---
    Name: [Child, Child2: [Child3, Child 4]]
    ---
    */
    string toTreeString() {
        if (_children.length == 0) return _name;
        string _out = _name ~ ": [";
        for (int i = 0; i < _children.length; ++i) {
            Element child = *(_children[i]);
            _out ~= child.toTreeString();
            if (i + 1 != _children.length) _out ~= ',';
        }
        _out ~= ']';
        return _out;
    }

    void render() {
        ivec2 pos = getPosition();
        // do render of itself
        ivec2 size = getSize();
        bool isTopEdge = pos.y % 2 == 1;
        bool isUnevenSize = size.y % 2 == 1;
        bool isBottomEdge = isTopEdge != isUnevenSize; // wierd XOR
        col pcolor = getParentColor();
        int height = size.y / 2;
        if (isTopEdge || isBottomEdge) height += 1;
        
        // TODO: calculate other children color overlap 
        // (A is not child of B but sill overlays with wrong color)

        // draw background
        if (_backgroundColor.a > 0.1) {
            for (int y = 0; y < height; ++y) {
                cursorMove(pos.x, pos.y / 2 + y);
                bool isEdge = (isTopEdge && y == 0) || (isBottomEdge && y + 1 == height);
                if (isEdge) {
                    if (isEdge && pcolor.a > 0.1) write(pcolor.escape(true));
                    write(_backgroundColor.escape(false));
                } else {
                    write(_backgroundColor.escape(true));
                }
                for (int x = 0; x < size.x; ++x) {
                    if (isTopEdge && y == 0) {
                        write(_lowerBlock);
                    } else
                    if (isBottomEdge && y + 1 == height) {
                        write(_upperBlock);
                    } else {
                        write(" ");
                    }
                }
                write("\033[m");
            }
        }

        if (_textColor.a > 0.1 && _text.length > 0) {
            dstring[] t = splitStringWidth(_text, size.x);
            int yred = 0;
            if (isTopEdge) yred += 1;
            if (isBottomEdge) yred += 1;
            int maxY = max(min(t.length, height - yred), 0);
            for (int y = isTopEdge ? 1 : 0; y < maxY + isTopEdge ? 1 : 0; ++y) {
                ivec2 tp = ivec2(pos.x, pos.y / 2 + y);
                dstring line = t[y - (isTopEdge ? 1 : 0)];
                int len = cast(int) line.length;
                int lct = cast(int) t.length;
                if (_halign == TextHAlign.center) {
                    // offset it by (width - line width) / 2
                    tp.x = tp.x + (size.x - len) / 2;                
                } else 
                if (_halign == TextHAlign.right){ // right
                    // offset it by widht - line width
                    tp.x = tp.x + size.x - len;
                }
                if (_valign == TextVAlign.middle) {
                    tp.y = tp.y + (height - lct) / 2;
                } else
                if (_valign == TextVAlign.bottom) {
                    tp.y = tp.y + height - lct - (isTopEdge ? 1 : 0);
                }

                cursorMove(tp.x, tp.y);
                write(_backgroundColor.escape(true));
                write(_textColor.escape(false));
                write(line);
                write("\033[m");
            }
        }

        foreach (Node child; _children) {
            (*child).render();
        }

        // write("\033[mA");

        _renderNeeded = false;
    }

    void forceRender() {
        render();
    }

    void requestRender() {
        if (_renderNeeded) {
            render();
        } else {
            foreach (Node child; _children) {
                (*child).requestRender();
            }
        }
    }

    void addChild(Node child) {
        _children ~= child;
        (*child)._parent = &this;
    }

    ivec2 getSize() {
        int tw = terminalWidth();
        int th = terminalHeight() * 2;
        if (_parent == null) return ivec2(tw, th);
        ivec2 s = _size;
        // -1 - full fill
        s.x = s.x == -1 ? tw : s.x;
        s.y = s.y == -1 ? th : s.y;
        // -2 - fill from content
        s.x = s.x == -2 ? tw : s.x;
        s.y = s.y == -2 ? th : s.y;

        ivec2 _parentSize = (*_parent).getSize();
        ivec2 _maxSize = _parentSize - _pos; 
        s = s.min(_maxSize);

        // TODO: fix auto
        // TODO: limit to parent size
        return s;
    }

    ivec2 getPosition() {
        if (_parent == null) return _pos;
        ivec2 ppos = (*_parent).getPosition();
        return _pos + ppos;
    }

    col getParentColor() {
        if (_parent == null) return col(0.0f, 0.0f);
        return (*_parent)._backgroundColor;
    }
}

void forceRender() {
    (*root).forceRender();
}

void requestRender() {
    (*root).requestRender();
}

/*
Style sizes
none - hidden
content - auto size
full - fill parent
wide - fill parent width, auto height
tall - fill parent height, auto width
*/
enum Size: ivec2 {
    none = ivec2(0, 0),
    content = ivec2(-2, -2),
    full = ivec2(-1, -1),
    wide = ivec2(-1, -2),
    tall = ivec2(-2, -1)
}

enum TextVAlign {
    middle,
    top,
    bottom
}

enum TextHAlign {
    center,
    left,
    right
}

Node append(Node parent = root, Node child = new Element()) {
    (*parent).addChild(child);
    return child;
}

Node create() {
    return new Element();
}

Node background(Node node, col back) {
    (*node)._backgroundColor = back;
    (*node)._renderNeeded = true;
    return node;
}

Node size(Node node, ivec2 size) {
    (*node)._size = size;
    (*node)._renderNeeded = true;
    return node;
}

Node position(Node node, ivec2 pos) {
    (*node)._pos = pos;
    (*node)._renderNeeded = true;
    return node;
}

Node text(Node node, dstring text) {
    (*node)._text = text;
    (*node)._renderNeeded = true;
    return node;
}

Node foreground(Node node, col color) {
    (*node)._textColor = color;
    (*node)._renderNeeded = true;
    return node;
}

Node halign(Node node, TextHAlign _align) {
    (*node)._halign = _align;
    (*node)._renderNeeded = true;
    return node;
} 

Node valign(Node node, TextVAlign _align) {
    (*node)._valign = _align;
    (*node)._renderNeeded = true;
    return node;
}

/**
Returns node based on selector, similar to CSS selectors.
Example:
Node bigPanel = query!"#nodeid"; 
Node[] labels = query!".label";
Node[] allNodes = query!"\*"; 
*/
Node query(string selector)(Node from = root) if (selector.length > 0 && selector[0] == '#') {
    
    return null;
}
/// Ditto
Node[] query(string selector)(Node from = root) if (selector.length > 0 && selector[0] != '#') {
    
    return null;
}

