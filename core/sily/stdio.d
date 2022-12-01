module sily.stdio;

/** 
 * Rewinds stdout and truncates it
 */
void rewindStdout() {
    import core.sys.posix.unistd: ftruncate;
    import std.stdio: stdout;
    
    stdout.rewind();
    ftruncate(1, 0);
}