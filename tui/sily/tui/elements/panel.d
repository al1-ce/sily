/// Panel TUI Element
module sily.tui.elements.panel;

import sily.tui;
import sily.tui.render;
import sily.tui.elements: Element;

import sily.color;
import sily.vector;

/// Element implementing basic panel
class Panel: Element {
    /// Panel position
    public uvec2 pos = uvec2.zero;
    /// Panel size
    public uvec2 size = uvec2.zero;
    /// Panel color
    public col color = Colors.white;

    /**
    Creates new panel
    Params:
        _pos = Position
        _size = Size
        _color = Color
    */
    this(uvec2 _pos, uvec2 _size, col _color) {
        pos = _pos;
        size = _size;
        color = _color;
    }

    /// Panel render
    protected override void _render() {
        Render.at(pos.x, pos.y);
        for (int y = 0; y < size.y; ++y) {
            Render.write(color.escape(true));
            for (int x = 0; x < size.x; ++x) {
                Render.write(" ");
            }
            Render.write("\033[m");
            Render.at(pos.x, pos.y + y);
        }
    }
}