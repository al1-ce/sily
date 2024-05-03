// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/+
Threaded sleep
+/
module sily.async.timer;

import std.concurrency;
import core.thread;

/**
Executes delegate on timeout or interval

Params:
  func = Delegate function to execute
  timespan = Time in milliseconds

Example:
---
// Using normal functions
void func() { writeln("Timer end"); }
import std.functional: toDelegate;
setTimeout(toDelegate(&func), 6000);

// Using inline delegates
setTimeout(delegate void() { writeln("Timer end"); }, 6000);

// Interval
setInterval(delegate void() { writeln("Timer tick"); }, 10);

// Stop timer
// After stopping timer it cannot be restarted
AsyncTimer timer = setInterval(delegate void() { writeln("Timer tick"); }, 10);
timer.stop();

// Adjusting timer values
// Will be adjusted on next cycle (aka after 10 msec)
timer = setInterval(delegate void() { writeln("Timer tick"); }, 10);
timer.timespan = 50;
timer.interval = false; // will prevent timer from running next cycle
---
*/
AsyncTimer setTimeout(void delegate() func, int timespan) {
    return setAsyncTimer(func, AsyncTimer(timespan, false, new AsyncTimerValues()));
}

/// Ditto
AsyncTimer setInterval(void delegate() func, int timespan) {
    return setAsyncTimer(func, AsyncTimer(timespan, true, new AsyncTimerValues()));
}

private AsyncTimer setAsyncTimer(void delegate() func, AsyncTimer timer) {
    timer.start();
    spawn(
        cast(shared) (&timeoutCallback),
        cast(shared) func,
        cast(shared) (timer.intervalptr()),
        cast(shared) (timer.timespanptr()),
        cast(shared) (timer.enabledptr())
    );
    return timer;
}

private static void timeoutCallback(shared void delegate() func,
                                    shared bool* interval,
                                    shared int* timespan,
                                    shared bool* enabled) {
    do {
        Thread.sleep((*timespan).msecs);
        if (*enabled) func();
    } while ((*enabled) && (*interval));
    (*(cast(bool*) enabled)) = false;
}

private static struct AsyncTimerValues {
    private bool _enabled = false;

    private int _timespan = 0;

    private bool _isInterval = false;
}

/// Timer struct used by setTimeout and setInverval. Does not contains timer functionality itself.
static struct AsyncTimer {
    private AsyncTimerValues* _timer;

    @property int  timespan() { return (*_timer)._timespan; }
    @property void timespan(int p_timespan) { (*_timer)._timespan = p_timespan; }

    @property bool interval() { return (*_timer)._isInterval; }
    @property void interval(bool p_isInterval) { (*_timer)._isInterval = p_isInterval; }

    @property bool enabled() { return (*_timer)._enabled; }

    @property private bool* enabledptr() { return &((*_timer)._enabled); }
    @property private int* timespanptr() { return &((*_timer)._timespan); }
    @property private bool* intervalptr() { return &((*_timer)._isInterval); }

    private this(int p_timespan, bool p_interval, AsyncTimerValues* timer) {
        _timer = timer;
        timespan = p_timespan;
        interval = p_interval;
    }

    /// Stops timer (timeout and interval execution)
    void stop() {
        (*_timer)._enabled = false;
    }

    /// Will do nothing, used by timeout and interval
    void start() {
        (*_timer)._enabled = true;
    }

    /// Will sleep until timer is finished (not recommended with interval)
    void await() {
        while ((*_timer)._enabled) {
            Thread.sleep(500.usecs);
        }
    }
}


