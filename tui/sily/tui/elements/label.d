/// Label TUI Element
module sily.tui.elements.label;

import std.conv: to;

import sily.tui;
import sily.tui.render;
import sily.tui.elements: Element;

import sily.color;
import sily.vector;

/// Element implementing text render
class Label: Element {
    /// Label text
    public dstring text = "";
    /// Label position
    public uvec2 pos = uvec2.zero;
    /// Label text color
    public col front = Colors.black;
    /// Label background color
    public col back = Colors.white;

    /**
    Creates new Label
    Params:
        _text = Text
        _pos = Position
        _front = Text color
        _back = Background color
    */
    public this(dstring _text, uvec2 _pos, col _front, col _back) {
        text = _text;
        pos = _pos;
        front = _front;
        back = _back;
    }

    /// Label rendering
    protected final override void _render() {
        Render.at(pos.x, pos.y).write(
            front.escape(false),
            back.escape(true),
            text,
            "\033[m"
        );
    }

    /// Returns label length
    public int length() { return text.length.to!uint; }
}