module sily.unit;

import sily.logger;

import sily.bashfmt;
import sily.terminal;

import std.stdio: writef;
import std.format: format;
import std.conv: to;

private int _testPassed = 0;
private int _testFailed = 0;
private int _testTotal = 0;

private void addTest(bool result) {
    if (result == false) {
        _testFailed += 1;
    } else {
        _testPassed += 1;
    }
    _testTotal += 1;
}

public void startUnittest(int line = __LINE__, string file = __FILE__)() {
    _testTotal = 0;
    _testPassed = 0;
    _testFailed = 0;
    hr('-', to!dstring("Starting test at " ~ file ~ ":" ~ line.to!string), "\033[90m");
}

public void writeReport(int line = __LINE__, string file = __FILE__)(bool exitOnError = false, bool color = true) {
    // writef("Total tests:  %d\nPassed tests: %d\nFailed tests: %d\n",
    //         _testTotal, _testPassed, _testFailed);
    // if (_testFailed != 0 && exitOnError) throw new Error("Unittest failed.", file, line);
    // TODO: if color
    writef("Total tests:  %d\n", _testTotal);
    writef("Passed tests: %s%d%s\n", cast(string) (_testPassed == 0 ? FG.ltred : FG.reset), _testPassed, cast(string) FG.reset);
    writef("Failed tests: %s%d%s\n", cast(string) (_testFailed == 0 ? FG.reset : FG.ltred), _testFailed, cast(string) FG.reset);

    if (_testFailed != 0 && exitOnError) exit(ErrorCode.general);
}

public void assertEquals(T, S, int line = __LINE__, string file = __FILE__)
                        (T t, S s, string message = "Expected '%s', got '%s'.") {
    bool passed = t == s;
    addTest(passed);
    if (!passed) {
        error!(line, file)(message.format(t.to!string, s.to!string));
    }
}

public void assertFalse(T, int line = __LINE__, string file = __FILE__)
                       (T t, string message = "Expected '%s', got '%s'.") {
    assertEquals!(T, bool, line, file)(t, false, message);
}
