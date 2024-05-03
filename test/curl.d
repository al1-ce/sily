#!/usr/bin/env dub
/+ dub.sdl:
name "curltest"
dependency "sily" path="../"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio;
import std.conv: to;
import std.net.curl: HTTPStatusException;
import std.json;

import sily.curl;
import sily.async;
import sily.thread;

void main() {
    HTTPRequest prom = new Promise!(string, HTTPStatusException)();

    writeln("---------------- TEST RESOLVE ----------------");
    prom.then(delegate void(string s) {
        writeln(s);
    }).then(null, delegate void(HTTPStatusException e) {
        writeln("Error ", e.status, ": ",  e.msg);
    }).except(delegate void(HTTPStatusException e) {
        writeln(e.msg);
    }).finish(delegate void() {
        writeln("Finished after everything");
    });

    prom.resolve("My data");
    writeln();

    writeln("---------------- TEST REJECT ----------------");
    prom = new Promise!(string, HTTPStatusException)();

    prom.then(delegate void(string s) {
        writeln(s);
        throw new HTTPStatusException(202, "Message");
    }).then(null, delegate void(HTTPStatusException e) {
        writeln("Error ", e.status, ": ",  e.msg);
    }).then(delegate void() {
        writeln("Recovery after error");
    }).finish(delegate void() {
        writeln("Finished after everything");
    });

    prom.reject(new HTTPStatusException(451, "Reject message"));
    writeln();

    writeln("---------------- TEST CURL GITHUB ----------------");
    string[string] _head =
        ["Accept": "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28"];

    FetchConfig _config = {
        headers: _head,
        method: GET,
    };

    async({
        fetch("https://api.github.com/repos/al1-ce/todoer/issues", _config
        ).then(delegate JSONValue(string data) {
            return parseJSON(data);
        }).then(delegate void(JSONValue json) {
            writeln("GH CURL START HERE ======");
            foreach (issue; json.array) {
                writeln(issue["title"].str);
            }
            writeln("GH CURL END");
        }).except(delegate void(HTTPStatusException e) {
            writeln("GH CURL Error ", e.status, ": ",  e.msg);
        });
    });
    writeln("!Should see results of curl a bit after!");
    writeln();

    writeln("---------------- TEST RESOLVE STRING ----------------");
    prom = new Promise!(string, HTTPStatusException)();
    prom.then(delegate string(string v) {
        return v ~ " from delegate";
    }).then(delegate void(string v) {
        writeln(v);
    });

    prom.resolve("resolve string");
    writeln();

    writeln("---------------- TEST REJECT ----------------");
    prom = new Promise!(string, HTTPStatusException)();
    prom.except(delegate string(HTTPStatusException v) {
        return v.msg ~ " from delegate";
    }).then(delegate void(string v) {
        writeln(v);
    });

    prom.reject(new HTTPStatusException(123, "Exception"));
    writeln();

    writeln("---------------- TEST TIMEOUT ----------------");

    import std.functional: toDelegate;

    void func() {
        writeln("THREAD: Timer end message (should see only one time)");
    }

    writeln("Starting timer");
    setTimeout(delegate void() {writeln("THREAD: Timer end");}, 200).stop();
    // writeln("Ending timer");
    setTimeout(toDelegate(&func), 400);
    // writeln("Starting timer");
    import core.thread;
    AsyncTimer timer = setTimeout(toDelegate(&func), 400);
    timer.stop();

    writeln("---------------- TEST INTERVAL ----------------");
    int _i = 0;
    // Stop timer
    // After stopping timer it cannot be restarted
    timer = setInterval(delegate void() { writeln("THREAD: Timer tick ", _i); ++_i; }, 20);
    Thread.sleep((200).msecs);
    timer.stop();
    writeln("Expected _i = 9");

    // Adjusting timer values
    // Will be adjusted on next cycle (aka after 10 msec)
    timer = setInterval(delegate void() { writeln("THREAD: Timer tick 1 and stop 2"); }, 10);
    timer.timespan = 50;
    Thread.sleep((100).msecs);
    timer.interval = false;
    timer.await();
    writeln("---------------- TEST TIMER TIME ----------------");
    setTimeout(delegate void() {writeln("THREAD: Timer end,should see 'Sleep end' after");}, 400).await();
    // Thread.sleep((6000).msecs);
    writeln("Sleep end");

    // Thread.sleep(1000.msecs);
}
