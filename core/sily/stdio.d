/// std.stdio wrapper
module sily.stdio;

static import std.stdio;
import std.traits: isSomeString;

// import sily.terminal: isTerminalRaw;

version(Posix) {
    // FIXME: remove
    /// Rewinds stdout and truncates it
    deprecated("Will be moved to sily.terminal")
    void rewindStdout() {
        import core.sys.posix.unistd: ftruncate;
        import std.stdio: stdout;

        stdout.rewind();
        ftruncate(stdout.fileno, 0);
    }
}

// void write(A...)(A args) {
//     std.stdio.write(args);
// }

// void writeln(A...)(A args) {
//     std.stdio.write(args);
//     std.stdio.write(isTerminalRaw ? "\r\n" : "\n");
// }

// void writef(A...)(A args) {
//     std.stdio.writef(args);
// }

// void writefln(A...)(A args) {
//     std.stdio.writef(args);
//     std.stdio.writef(isTerminalRaw ? "\r\n" : "\n");
// }
