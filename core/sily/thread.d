// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/+
Threading utils
+/
module sily.thread;

// import std.concurrency;
import core.thread;

/// Internal std.core.Thread wrapper
struct AsyncThread {
    private Thread _thread;
}

/**
Executes function in new thread

Example:
---
async({
    writeln("I'm in a thread");
});

async({
    writeln("I'm in a joined thread");
}).await();
---
*/
AsyncThread async(void function() fn) {
    AsyncThread athread = AsyncThread(new Thread(fn));
    athread._thread.start();
    return athread;
}

/// Ditto
AsyncThread async(void delegate() fn) {
    AsyncThread athread = AsyncThread(new Thread(fn));
    athread._thread.start();
    return athread;
}

/// Joins thread (waits for execution)
void await(AsyncThread thread) {
    thread._thread.join(false);
}

