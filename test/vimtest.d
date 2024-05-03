#!/usr/bin/env dub
/+ dub.sdl:
name "logtest"
dependency "sily" path="../"
dependency "sily:logger" path="../"
// dependency "logger" path="/g/sily-dlang/logger"
targetType "executable"
targetPath "../bin/"
+/
module test.logtest;

import std.stdio;
import std.conv;

import core.thread: Thread;
import core.time: msecs;

import sily.logger;
import sily.bashfmt;
import sily.logger.pixelfont;

void main() {
    cast(int) 10;
    extern(C) void n() {}

    void c(void delegate() v) {
        v();
    }
    switch(adv) {
        case 0: break;
        case 1: break;
        default: break;
    }
    if (i != 4 - 1) s ~= ", ";
    
        float c_size = (2.pow(c_bits) - 1).to!float;
    i != !i;
        // writeln(dl, " ", dln);
.5f;
0.2;
1_0._20;
    int[10] arr = 2;
    int i = arr[0.. $];
    int c = arr[0..$];
    int b = arr[0..1];
    c(n());
    log!off;
    "log!on";
    ".$test 0..$";
    printCompilerInfo();
    hr('=', "log", "\033[33m");
    log("Testing normal log");
    hr('=');
    message("LogLevel: off");
    globalLogLevel = LogLevel.off;
    log!(LogLevel.off!())("Using off level with off to display at any time");
    // log("Should not see");
    // hr();
    // message("LogLevel: fatal");
    // globalLogLevel = LogLevel.fatal;
    // log!(LogLevel.fatal)("Should see fatal");
    // message("Should not see info & error");
    // log!(LogLevel.info)("Should not see info");
    // message("Should not see error");
    // log!(LogLevel.error)("Should not see error");
    // globalLogLevel = LogLevel.errorOnly | LogLevel.infoOnly;
    // hr();
    // message("LogLevel: infoOnly | errorOnly");
    // log!(LogLevel.info)("Should see info");
    // log!(LogLevel.error)("Should see error");
    // message("Should not see trace & fatal");
    // log!(LogLevel.trace)("Should not see trace");
    // log!(LogLevel.fatal)("Should not see fatal");
    // hr();
    message("LogLevel: all");
    globalLogLevel = LogLevel.all;


    // writef("\033[2J");
    // writef("\033[H");
    hr('-', "log trace");
    import sily.terminal: terminalWidth;
    block("Also code blocks", `private string formatString(A...)(A args) {
    string out_ = "";
    foreach (arg; args) out_ ~= arg.to!string;
    return out_;
}`, cast(int) (terminalWidth() * 0.75f), 0);
    hr('▒', "Cool, right?", "\033[38;5;52m", "\033[48;5;52m\033[38;5;11m");
    center("You can also use hr() as headers");
    info("This logger also supports multiline text\nAnd this one is after \\n");
    info("Info ", "message split", " into many", " substrings");
    warning("Warning message, beware");
    hr('#', "ERROR", "\033[91m", "\033[101m");
    error("Any errors that might come up while execution");
    critical("Critical error. Need attention but not fatal");
    fatal("Program crashed");
    // write('\u2501');

    ProgressBar b1 = ProgressBar("Normal:           ");
    ProgressBar b2 = ProgressBar("Char:             ");
    ProgressBar b3 = ProgressBar("Char With Back:   ");
    ProgressBar b4 = ProgressBar();
    ProgressBar b5 = ProgressBar("Blocks With ANSI8:");
    ProgressBar b6 = ProgressBar("Custom Length:    ");

    b2.incomplete = ' ';
    b2.break_ = '!';
    b2.complete = '#';
    b2.after = '|';

    b3.before = '[';
    b3.after = ']';
    b3.incomplete = '-';
    b3.break_ = '>';
    b3.complete = '=';
    b3.labelFormat = "\033[7m";

    b6.labelFormat = "\033[3m";

    b4.colors = ["\033[36m"];

    b6.before = '[';
    b6.after = ']';
    b6.incomplete = '\0';
    b6.break_ = '■';
    b6.complete = '■';

    b5.colors = [
        "\033[38;5;52m", 
        "\033[38;5;88m",
        "\033[38;5;124m",
        "\033[38;5;130m",
        "\033[38;5;166m",
        "\033[38;5;172m",
        "\033[38;5;214m",
        "\033[38;5;226m",
        "\033[38;5;190m",
        "\033[38;5;154m",
        "\033[38;5;118m",
        "\033[38;5;82m"
        ];

    b5.before = '?';
    b5.incomplete = '░';
    // b5.break_ = '▒';
    b5.break_ = '▓';
    b5.complete = '█';

    int adv = 20;
    hr('-', "Bars");
    for (int i = 0; i <= 100; i += adv) {
        // progress(i, "A: ", "", '=', '!', '=');
        // writefln("Processing: %3d%%", i);
        progress(b1); 
        progress(b2);
        progress(b3);
        progress(b4);
        progress(b5);
        progress(b6, 50);
        Thread.sleep(500.msecs);
        b1.advance(adv);
        b2.advance(adv / 4);
        b3.advance(adv);
        b4.advance(adv / 2);
        b5.advance(adv);
        b6.advance(adv);

        if (i != 100) eraseLines(7);
    }
private:

    // center(get3x4("Epic Titles II: Now On TV"));
    center(get3x4("Sphinx of black quartz, judge my vow."));
    hr('\u2501');
    
    // center(get5x6("Epic Titles II: Now On TV"));
    center(get5x6("Sphinx of black quartz, judge my vow."));
    writeln("");
}
