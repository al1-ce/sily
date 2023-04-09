module sily.tui.event;

import io = sily.terminal.input;

private void delegate(io.InputEvent)[] _inputCallback;

// TODO: rename
void addInputListener(void delegate(io.InputEvent) f) {
    _inputCallback ~= f;
}

// FIXME: shouldnt pollEvent pool event from queue and peek just show it?
void pollInputEvent() {
    io.pollEvent();
    while (!io.queueEmpty()) {
        io.InputEvent e = io.peekEvent();
        foreach (f; _inputCallback) {
            f(e);
        }
    }
}

