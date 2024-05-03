#!/usr/bin/env dub
/+ dub.sdl:
name "testfmt"
dependency "sily" path="../"
dependency "sily:term" path="../"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio: writeln, write, readln;
import sily.bash;

void main() {
    writeln();
    writeln("Couple of next lines will be erased");
    writeln("But you'll see this line");
    writeln("You should not see this line");
    eraseLines(2);
    writeln("And this one");
    writeln("And these two lines");
    writeln("Too");
    eraseLines(3);
    writeln("And this one too");
    writeln(FG.DK_GRAY, BG.BLACK, "Text");
    writeln(FORMAT.BLINK, "Blinking", FRESET.FULL);
    writeln(FORMAT.BOLD, "Bold", FRESET.FULL);
    writeln(FORMAT.DIM, "Dim", FRESET.FULL);
    writeln(FORMAT.DOUBLE_UNDERLINE, "Double lined", FRESET.FULL);
    writeln(FORMAT.INVERSE, "Inversed", FRESET.FULL);
    writeln(FORMAT.ITALICS, "Italics", FRESET.FULL);
    writeln(FORMAT.STRIKED, "Striked", FRESET.FULL);
    writeln(FORMAT.UNDERLINE, "Underlined", FRESET.FULL);
    writeln(FG.RED, "Red", FORMAT.BLINK, "Blink", BG.CYAN, "ALl", FRESET.FULL);
    cursorSavePosition();
    cursorMoveUp(3);
    cursorMoveDown();
    cursorMoveRight(22);
    cursorMoveLeft(2);
    write(BG.LT_BLUE, FG.BLACK, ">this one is written out of sequence<", FRESET.FULL);
    cursorRestorePosition();
    writeln();
}
