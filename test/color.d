#!/usr/bin/env dub
/+ dub.sdl:
name "colortest"
dependency "sily" path="../"
dependency "sily:term" path="../"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio;
import std.conv;

import sily.color;
import sily.bash;

void main() {

    for (float r = 0; r < 1; r += 0.1) {
        for (float g = 0; g < 1; g += 0.1) {
            for (float b = 0; b < 1; b += 0.1) {
                col c = col(r, g, b);
                write(c.toTrueColorString(true) ~ " ");
                // write(c.getAnsiString(true) ~ c.getAnsi(true).to!string);
            }
        }
        writeln("" ~ FG.RESET ~ BG.RESET);
    }
    for (float r = 0; r < 1; r += 0.1) {
        for (float g = 0; g < 1; g += 0.1) {
            for (float b = 0; b < 1; b += 0.1) {
                col c = col(r, g, b);
                write(c.toAnsiString(true) ~ " ");
                // write(c.getAnsiString(true) ~ c.getAnsi(true).to!string);
            }
        }
        writeln("" ~ FG.RESET ~ BG.RESET);
    }
    for (float r = 0; r < 1; r += 0.1) {
        for (float g = 0; g < 1; g += 0.1) {
            for (float b = 0; b < 1; b += 0.1) {
                col c = col(r, g, b);
                // write(r, " ", g, " ", b, " ");
                write(c.toAnsi8String(true) ~ " ");
                // write(c.getAnsi8String(true) ~ c.getAnsi8(true).to!string ~ " ");
            }
        }
        writeln("" ~ FG.RESET ~ BG.RESET);
    }

    for (int i = 0; i < 140; i++) {
        col c = col.fromAnsi(i);
        write(c.toTrueColorString(true) ~ " ");
        // write(col.getFromAnsi8(i).getTrueColorString(true) ~ i.to!string);
        // write(col.getFromAnsi8(i).toString());
    }
    writeln("" ~ FG.RESET ~ BG.RESET);
    // writeln(
    //         fmt(fmt(fmt(fmt("My cool text", FM.blink),
    //         FG.ltgreen) ~ " with ",
    //         BG.dkgray) ~ "color",
    //         FM.dline) ~ " and style");
    writeln(
        FORMAT.BLINK,
        FORMAT.DOUBLE_UNDERLINE,
        FG.LT_GREEN,
        BG.DK_GRAY,
        "My cool text",
        FORMAT.BLINK,
        FG.RESET,
        " with ",
        BG.RESET,
        "color",
        FRESET.ALL,
        " and style");
}
