#!/usr/bin/env dub
/+ dub.sdl:
name "speedy"
dependency "speedy-stdio" version="~>0.2.0"
targetType "executable"
targetPath "../bin/"
+/

static import speedy.stdio;
static import std.stdio;
import core.thread: Thread;
import std.datetime: msecs;

void main() {
    // Press CTRL+Q or CTRL+C to advance
    
    terminalModeSetRaw(false);

    while(true) {
        // Checks if ctrl+q or ctrl+c is pressed
        if (kbhit) { int g = getch(); if (g == 3 || g == 17) break; }
        int tw = terminalWidth;
        int th = terminalHeight;
        // Clears screen and puts cursor to 1,1
        write("\033[2J\033[H");
        for (int y = 0; y < th; ++y) {
            for (int x = 0; x < tw; ++x) {
                // Writes color for each space (y - red, x - green)
                write(
                    "\033[48;2;", 
                    cast(int) ((y / 1.0 / th) * 255), ";",
                    cast(int) ((x / 1.0 / tw) * 255), ";0m "
                    );
            }
            // Sets cursor to 1,y
            write("\033[", y + 1, ";1f");
        }
        // Prints text at 15,15
        write("\033[m\033[15;15fSpeedy raw buffered");
        // Flushes buffer into stdout
        flushBufferSpeedy();
        // Sleeps
        Thread.sleep(msecs(1));
    }

    terminalModeReset();

    terminalModeSetRaw(false);

    while(true) {
        if (kbhit) { int g = getch(); if (g == 3 || g == 17) break; }
        int tw = terminalWidth;
        int th = terminalHeight;
        write("\033[2J\033[H");
        for (int y = 0; y < th; ++y) {
            for (int x = 0; x < tw; ++x) {
                write(
                    "\033[48;2;", 
                    cast(int) ((y / 1.0 / th) * 255), ";",
                    cast(int) ((x / 1.0 / tw) * 255), ";0m "
                    );
            }
            write("\033[", y + 1, ";1f");
        }
        write("\033[m\033[15;15fStd raw buffered");
        flushBufferStd();
        Thread.sleep(msecs(10));
    }

    terminalModeReset();

    terminalModeSetRaw(true);

    while(true) {
        if (kbhit) { int g = getch(); if (g == 3 || g == 17) break; }
        int tw = terminalWidth;
        int th = terminalHeight;
        write("\033[2J\033[H");
        for (int y = 0; y < th; ++y) {
            for (int x = 0; x < tw; ++x) {
                write(
                    "\033[48;2;", 
                    cast(int) ((y / 1.0 / th) * 255), ";",
                    cast(int) ((x / 1.0 / tw) * 255), ";0m "
                    );
            }
            write("\033[", y + 1, ";1f");
        }
        write("\033[m\033[15;15fSpeedy raw unbuffered");
        flushBufferSpeedy(false);
        Thread.sleep(msecs(10));
    }

    terminalModeReset();

    terminalModeSetRaw(true);

    while(true) {
        if (kbhit) { int g = getch(); if (g == 3 || g == 17) break; }
        int tw = terminalWidth;
        int th = terminalHeight;
        write("\033[2J\033[H");
        for (int y = 0; y < th; ++y) {
            for (int x = 0; x < tw; ++x) {
                write(
                    "\033[48;2;", 
                    cast(int) ((y / 1.0 / th) * 255), ";",
                    cast(int) ((x / 1.0 / tw) * 255), ";0m "
                    );
            }
            write("\033[", y + 1, ";1f");
        }
        write("\033[m\033[15;15fStd raw unbuffered");
        flushBufferStd(false);
        Thread.sleep(msecs(10));
    }

    terminalModeReset();
    std.stdio.write("\033[2J\033[H");
}

dstring _screenBuffer = "";

/// Writes buffer into stdout and flushes stdout
public static void flushBufferSpeedy(bool doFlush = true) {
    speedy.stdio.write(_screenBuffer);
    if (doFlush) speedy.stdio.unsafe_stdout_flush();
    _screenBuffer = "";
}

/// Writes buffer into stdout and flushes stdout
public static void flushBufferStd(bool doFlush = true) {
    std.stdio.stdout.write(_screenBuffer);
    if (doFlush) std.stdio.stdout.flush();
    _screenBuffer = "";
}

/// Writes args into buffer
public static void write(A...)(A args) if (args.length > 0) {
    import std.conv: to;
    foreach (arg; args) {
        _screenBuffer ~= arg.to!dstring;
    }
}

import core.sys.posix.sys.ioctl: winsize, ioctl, TIOCGWINSZ;

/// Returns bash terminal width
int terminalWidth() {
    winsize w;
    ioctl(0, TIOCGWINSZ, &w);
    return w.ws_col;
}

/// Returns bash terminal height
int terminalHeight() {
    winsize w;
    ioctl(0, TIOCGWINSZ, &w);
    return w.ws_row;
}

import core.stdc.stdio: setvbuf, _IONBF, _IOLBF;
import core.stdc.stdlib: atexit;
import core.stdc.string: memcpy;
import core.sys.posix.termios: termios, tcgetattr, tcsetattr, TCSANOW;
import core.sys.posix.unistd: read;
import core.sys.posix.sys.select: select, fd_set, FD_ZERO, FD_SET;
import core.sys.posix.sys.time: timeval;

import std.stdio: stdin, stdout;

private extern(C) void cfmakeraw(termios *termios_p);

private termios originalTermios;

/// Resets termios back to default and buffers stdout
extern(C) alias terminalModeReset = function() {
    // Writes original terminal state to stdin
    tcsetattr(0, TCSANOW, &originalTermios);
    // Sets stdout to be buffered by line
    setvbuf(stdout.getFP, null, _IOLBF, 1024);
};

/// Creates new termios and unbuffers stdout
void terminalModeSetRaw(bool removeStdoutBuffer = true) {
    import core.sys.posix.termios;
    termios newTermios;

    // Stores current terminal state
    tcgetattr(stdin.fileno, &originalTermios);
    // Copies current terminal state to new one
    memcpy(&newTermios, &originalTermios, termios.sizeof);

    // Sets terminal mode to raw
    cfmakeraw(&newTermios);

    // Raw mode flags
    newTermios.c_lflag &= ~(ICANON | ECHO | ISIG | IEXTEN);
    newTermios.c_iflag &= ~(ICRNL | INLCR | OPOST);
    newTermios.c_cc[VMIN] = 1;
    newTermios.c_cc[VTIME] = 0;

    // Sets stdout to unbuffered
    if (removeStdoutBuffer) setvbuf(stdout.getFP, null, _IONBF, 0);

    // Applies new state to stdin
    tcsetattr(stdin.fileno, TCSANOW, &newTermios);

    // Adds exit handler in case of SIGINT
    atexit(terminalModeReset);
}

/// Returns 1 if any key was pressed
int kbhit() {
    timeval tv = { 0, 0 };
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(stdin.fileno, &fds);
    return select(1, &fds, null, null, &tv);
}

/// Returns last pressed key
int getch() {
    int r;
    uint c;

    if ((r = cast(int) read(stdin.fileno, &c, ubyte.sizeof)) < 0) {
        return r;
    } else {
        return c;
    }
}
