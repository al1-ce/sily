module sily.terminal;
import core.sys.posix.sys.ioctl;

static this() {
    version(windows) {
        import core.stdc.stdlib: exit;
        exit(2);
    }
}

/** 
 * Returns bash terminal width
 */
int terminalWidth() {
    winsize w;
    ioctl(0, TIOCGWINSZ, &w);
    return w.ws_col;
}

/** 
 * Returns bash terminal height
 */
int terminalHeight() {
    winsize w;
    ioctl(0, TIOCGWINSZ, &w);
    return w.ws_row;
}