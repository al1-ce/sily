module sily.bashfmt;

import std.conv : to;
import std.stdio : write, writef;

static this() {
    version(windows) {
        import core.stdc.stdlib: exit;
        exit(2);
    }
}


alias FG = Foreground;
alias BG = Background;
alias FM = Formatting;
alias FR = FormattingReset;

enum Foreground : string {
    reset = "\033[39m",
    black = "\033[30m",
    red = "\033[31m",
    green = "\033[32m",
    yellow = "\033[33m",
    blue = "\033[34m",
    magenta = "\033[35m",
    cyan = "\033[36m",
    ltgray = "\033[37m",
    dkgray = "\033[90m",
    ltred = "\033[91m",
    ltgreen = "\033[92m",
    ltyellow = "\033[93m",
    ltblue = "\033[94m",
    ltmagenta = "\033[95m",
    ltcyan = "\033[96m",
    white = "\033[97m",
}

enum Background : string {
    reset = "\033[49m",
    black = "\033[40m",
    red = "\033[41m",
    green = "\033[42m",
    yellow = "\033[43m",
    blue = "\033[44m",
    magenta = "\033[45m",
    cyan = "\033[46m",
    ltgray = "\033[47m",
    dkgray = "\033[100m",
    ltred = "\033[101m",
    ltgreen = "\033[102m",
    ltyellow = "\033[103m",
    ltblue = "\033[104m",
    ltmagenta = "\033[105m",
    ltcyan = "\033[106m",
    white = "\033[107m"
}

enum Formatting : string {
    bold = "\033[1m",
    dim = "\033[2m",
    italics = "\033[3m",
    uline = "\033[4m",
    blink = "\033[5m",
    inverse = "\033[7m",
    hidden = "\033[8m",
    striked = "\033[9m",
    dline = "\033[21m",
    cline = "\033[4:3m",
    oline = "\033[53"
}

enum FormattingReset : string {
    reset = "\033[0m",
    fullreset = "\033[m",

    bold = "\033[21m",
    dim = "\033[22m",
    italics = "\033[22m",
    uline = "\033[24m",
    blink = "\033[25m",
    inverse = "\033[27m",
    hidden = "\033[28m",
    striked = "\033[29m",
    dline = "\033[24m",
    cline = "\033[4:0m",
    oline = "\033[55m"
}

/** 
 * Casts args to string and writes to stdout
 *
 * Intended to be used to print formatting
 * ---
 * fwrite("White text", FG.red, "Red text", FG.reset, BG.red, "Red background", FR.fullreset);
 * ---
 * Params:
 *   args = Text or one of formatting strings
 */
void fwrite(A...)(A args) {
    foreach (arg; args) {
        write(cast(string) arg);
    }
}

/** 
 * Casts args to string and writes to stdout with `\n` at the end
 *
 * Intended to be used to print formatting
 * ---
 * fwriteln("White text", FG.red, "Red text", FG.reset, BG.red, "Red background", FR.fullreset);
 * ---
 * Params:
 *   args = Text or one of formatting strings
 */
void fwriteln(A...)(A args) {
    foreach (arg; args) {
        write(cast(string) arg);
    }
    write("\n");
}

/** 
 * Erases `num` lines in terminal starting with current.
 * Params:
 *   num = Number of lines to erase
 */
void eraseLines(int num) {
    eraseCurrentLine();
    --num;

    while (num) {
        moveCursorUp(1);
        eraseCurrentLine();
        --num;
    }
}

/** 
 * Moves cursor in terminal to `{x, y}`
 * Params:
 *   x = Column to move to
 *   y = Row to move to
 */
void moveCursorTo(int x, int y) {
    writef("\033[%d;%df", x, y);
}

/** 
 * Moves cursor in terminal up by `lineAmount`
 * Params: 
 *   lineAmount = int
 */
void moveCursorUp(int lineAmount = 1) {
    writef("\033[%dA", lineAmount);
}

/** 
 * Moves cursor in terminal down by `lineAmount`
 * Params: 
 *   lineAmount = int
 */
void moveCursorDown(int lineAmount = 1) {
    writef("\033[%dB", lineAmount);
}

/** 
 * Moves cursor in terminal right by `columnAmount`
 * Params: 
 *   columnAmount = int
 */
void moveCursorRight(int columnAmount = 1) {
    writef("\033[%dC", columnAmount);
}

/** 
 * Moves cursor in terminal left by `columnAmount`
 * Params: 
 *   columnAmount = int
 */
void moveCursorLeft(int columnAmount = 1) {
    writef("\033[%dD", columnAmount);
}

/** 
 * Clears terminal screen and resets cursor position
 */
void clearScreen() {
    write("\033[2J");
    moveCursorTo(0, 0);
}

/** 
 * Clears terminal screen
 */
void clearScreenOnly() {
    write("\033[2J");
}

/** 
 * Fully erases current line 
 */
void eraseCurrentLine() {
    write("\033[2K");
}

/** 
 * Erases text from start of current line to cursor 
 */
void eraseLineLeft() {
    write("\033[1K");
}

/** 
 * Erases text from cursor to end of current line
 */
void eraseLineRight() {
    write("\033[K");
}

/** 
 * Saves cursor position to be restored later
 */
void saveCursorPosition() {
    write("\033[s");
}

/** 
 * Restores saved cursor position (moves cursor to saved pos)
 */
void restoreCursorPosition() {
    write("\033[u");
}

/** 
 * Hides cursor. Does not reset position
 */
void hideCursor() {
    write("\033[?25l");
}

/** 
 * Shows cursor. Does not reset position
 */
void showCursor() {
    write("\033[?25h");
}

/** 
 * Intended to be used in SIGINT callback
 *
 * Resets all formatting and shows cursor
 */
void cleanTerminalState() nothrow @nogc @system {
    import core.stdc.stdio: printf;
    printf("\033[?25h\033[m");
}