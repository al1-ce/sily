#!/usr/bin/env dub
/+ dub.sdl:
name "utilstest"
dependency "sily" path="../"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio;
import std.conv: to;

import sily.array;
import sily.clang;

void main() {
    deepLength([[[[[1, 2, 3, 4], [0]], [[4, 3], [5, 6, 7]]]]]).writeln();
    writeln(1 * 1 * 2 * 2 * 4 * 1 * 2 * 2 * 3);
    writeln(1 + 1 + 2 + 2 + 4 + 1 + 2 + 2 + 3);
    csizeof([[[[[1, 2, 3, 4], [0]], [[4, 3], [5, 6, 7]]]]]).writeln();
    deepLength([1, 2]).writeln();
    csizeof( cast(int[2]) [1, 2]).writeln();

    int[2][2] b = [[1, 2], [3, 4]];
    csizeof( cast(int[][]) [[1, 2], [4 ,5]]).writeln();
    csizeof(b).writeln();
    deepLength( cast(int[][]) [[1, 2], [4 ,5]]).writeln();
    deepLength(b).writeln();
    writeln();
    writeln("byte ", byte.sizeof);
    writeln("char ", char.sizeof);
    writeln("short ", short.sizeof);
    writeln("int ", int.sizeof);
    writeln("long ", long.sizeof);
    writeln("float ", float.sizeof);
    writeln("double ", double.sizeof);
    writeln("real ", real.sizeof);

    [[1, 2, 3], [1, 3]].deepLength.writeln;
    
    writeln();

    import sily.meta.enums;

    enum Elements {
        One = 1,
        Two,
        Three,
        Four,
        FifthElement,
        ELEMENT_FIVE,
        OneThatRules_World,
        O1es7yIsKey,
        O1es7YIsKey
    }
    // mixin(expandEnum!Elements);
    mixin(expandEnumUpper!Elements);
    writeln(ONE.to!int);
    // writeln(Two.to!int);
    // writeln(FifthElement.to!int);
    writeln(FIFTH_ELEMENT.to!int);
    writeln(ELEMENT_FIVE.to!int);
    writeln(ONE_THAT_RULES_WORLD.to!int);
    writeln(O1ES7Y_IS_KEY.to!int);
    writeln(O1ES7_YIS_KEY.to!int);
}
