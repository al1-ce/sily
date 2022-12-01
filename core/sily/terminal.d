module sily.terminal;
import core.sys.posix.sys.ioctl;

int terminalWidth() {
    winsize w;
    ioctl(0, TIOCGWINSZ, &w);
    return w.ws_col;
}

int terminalHeight() {
    winsize w;
    ioctl(0, TIOCGWINSZ, &w);
    return w.ws_row;
}