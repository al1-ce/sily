#!/usr/bin/env dub
/+ dub.sdl:
name "coniotest"
dependency "sily" path="../"
dependency "sily:term" path="../"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio: writef;
import std.conv: to;

import sily.term;
import sily.term.input;
import sily.log;
import sily.bash;
import sily.vector;
import sily.color;

import core.sys.posix.sys.ioctl: ioctl;
import sily.term.linux.kd: KDSKBMODE, K_RAW, K_XLATE, K_MEDIUMRAW;

void main() {
    writef("Press key (Press CTRL+Q to exit): \n");
    terminalModeSetRaw();
    mouseEnable();

    int key;
    bool quit = false;
    int i = 0;
    while (!quit) {
        string chrs = "";
        while (kbhit()) {
            if (i == 0) writef("[");
            ++i;
            key = getch();

            if (key == 17) { // C-q
                quit = true;
                writef("\r\n");
                writef("Quitting");
                writef("\r");
                break;
            // } else {
            } else {
                writef(" %d ", key);
                import std.ascii;
                if (!isControl(key.to!char)) chrs ~= key.to!char;
                if (key == 27) chrs ~= "\\e";
            }
        }
        if (i != 0 && !quit) writef("] %s\n\r", chrs);
        i = 0;
    }
    mouseDisable();
    terminalModeReset();
}
