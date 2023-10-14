/++
Async utils
+/
module sily.async;

import std.net.curl: HTTPStatusException;

alias HTTPRequest = Promise!(string, HTTPStatusException);

private struct PromiseHandler {
    void delegate() handler;
    bool onFullfill;
    bool onReject;
}

/++
Simple implementation of JavaScript promises
Example:
---
HTTPRequest prom = new Promise!(string, HTTPStatusException)();

prom.then(delegate void(string s) {
    writeln(s);
}).then(null, delegate void(HTTPStatusException e) {
    writeln("Error ", e.status, ": ",  e.msg);
}).except(delegate void(HTTPStatusException e) {
    writeln(e.msg);
}).finish(delegate void() {
    writeln("Finished after error");
});

prom.resolve("My data");
prom.refresh();
prom.reject(new HTTPStatusException(451, "Reject message"));
---
+/
final class Promise(T, E: Throwable = Exception) {

    private PromiseHandler[] _handlers;

    private PromiseState _state;

    private alias ThisType = Promise!(T, E);

    private struct BlackBox {
        static if (!is(T == void)) T value;
    }

    private BlackBox _value;
    private E _error;

    alias V = typeof(BlackBox.tupleof);
    
    /// Resolves promise and calles `then onResolve` callbacks
    private void resolve(BlackBox val) {
        _state = PromiseState.fulfilled;
        _value = val;
        foreach (func; _handlers) {
            if (func.onFullfill) {
                func.handler();
            }
        }
        _handlers = null;
    }

    /// Ditto
    void resolve() {
        resolve(BlackBox());
    }

    static if (!is(T == void)) {
        /// Resolves promise and calles `then onResolve` callbacks
        void resolve(T val) {
            resolve(BlackBox(val));
        }
    }

    /// Resolves promise and calles `then onError` callback
    void reject(E err) {
        _state = PromiseState.rejected;
        _error = err;
        foreach (func; _handlers) {
            if (func.onReject) {
                func.handler();
            }
        }
        _handlers = null;
    }

    private void tryResolve(R, S)(R delegate(S) callback, S val) {
        static if (is(R == void)) {
            static if (is(S == void)) {
                callback();
                resolve();
            } else {
                callback(val);
                resolve();
            }
        } else {
            static if (is(S == void)) {
                resolve(callback());
            } else {
                resolve(callback(val));
            }
        }
    }

    private void tryResolve(R)(R delegate() callback) {
        static if (is(R == void)) {
            callback();
            resolve();
        } else {
            resolve(callback());
        }
    }
    
    /// Registers on resolve functions (set null for no callback)
    Promise!(S, F) then(S, F = E)(S delegate(V) onResolve, S delegate(E) onReject = null) {
        Promise!(S, F) next = new Promise!(S, F);

        void resolveHandler() {
            if (onResolve !is null) {
                try {
                    // next.resolve(onResolve(_value.tupleof));
                    next.tryResolve(onResolve, _value.tupleof);
                } catch (F e) {
                    next.reject(e);
                }
            } else {
                next.resolve();
                // static if (is(S == void)) {
                //     next.resolve();
                // } else {
                //     next.resolve(_value.tupleof);
                // }
            }
        }

        void rejectHandler() {
            if (onReject !is null) {
                try {
                    // next.resolve(onReject(_error));
                    next.tryResolve(onReject, _error);
                } catch (F e) {
                    next.reject(e);
                }
            } else {
                next.reject(_error);
            }
        }

        switch (_state) {
            case PromiseState.pending:
                _handlers ~= PromiseHandler(&resolveHandler, true, false);
                _handlers ~= PromiseHandler(&rejectHandler, false, true);
            break;
            case PromiseState.fulfilled:
                resolveHandler();
            break;
            case PromiseState.rejected:
                rejectHandler();
            break;
            default: break;
        }

        return next;
    }
    
    /// Registers catch callback, equivalent to `then(null, ErrorCallback)`
    Promise!(S, F) except(S, F = E)(S delegate(F) onCatch) {
        return this.then(null, onCatch);
    }
    
    /// Registers callback to be called at end. Equivalent to `then(onFinally, onFinally)`
    Promise!(S, E) finish(S)(S delegate(V) onResolve) {
        Promise!(S, E) next = new Promise!(S, E);

        void resolveHandler() {
            if (onResolve !is null) {
                try {
                    // next.resolve(onResolve(_value.tupleof));
                    next.tryResolve(onResolve, _value.tupleof);
                } catch (E e) {
                    next.reject(e);
                }
            } else {
                static if (is(S == void)) {
                    next.resolve();
                } else {
                    next.resolve(_value.tupleof);
                }
            }
        }

        switch (_state) {
            case PromiseState.pending:
                _handlers ~= PromiseHandler(&resolveHandler, true, true);
            break;
            case PromiseState.fulfilled:
                resolveHandler();
            break;
            case PromiseState.rejected:
                resolveHandler();
            break;
            default: break;
        }

        return next;
    }
}

private enum PromiseState {
    pending,
    fulfilled,
    rejected
}

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
        cast(immutable) (&timeoutCallback), 
        cast(immutable) func, 
        cast(immutable) (timer.intervalptr()),
        cast(immutable) (timer.timespanptr()),
        cast(immutable) (timer.enabledptr())
    );
    return timer;
}

private static void timeoutCallback(immutable void delegate() func, 
                                    immutable bool* interval, 
                                    immutable int* timespan, 
                                    immutable bool* enabled) {
    do {
        Thread.sleep((*timespan).msecs);
        if (*enabled) func();
    } while ((*enabled) && (*interval));
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

    void stop() {
        (*_timer)._enabled = false;
    }

    void start() {
        (*_timer)._enabled = true;
    }
}

// TODO: async
// TODO: await
// import std.traits: getSymbolsByUDA;

// /// Used for UDA @async
// enum async = true;