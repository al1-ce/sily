#!/usr/bin/env dub
/+ dub.sdl:
name "sdlang-test"
dependency "sily" path="../"
dependency "sily:sdlang" path="../"
targetType "executable"
targetPath "../bin/"
+/

import sily.sdlang;
// import sily.sdlang.experimental;

import std.stdio;
import f = std.file;

void main() {
    SDLNode[] arr = parseSDL("name \"sdlang-test\"\ndependency \"sily\" path=\"/g/sily-dlang/\"");
    arr.generateSDL.writeln();

    SDLNode[] arr2 = parseSDL(f.readText("test/testfile.sdl"));
    arr2.generateSDL.writeln();
    arr2[11].name.writeln();
    arr2[11].children[2].name.writeln();
    arr2[11].children[2].values.writeln();
    arr2[11].children[2].attributes.writeln();
    writeln;

    SDLNode[] arr3 = parseSDL("qual \"stat1\" \"stat2\" ver=2");
    arr3[0].writeln();
    arr3[0].values.writeln();
    arr3[0].attributes.writeln();
    writeln;

    SDLNode[] arr4 = parseSDL(f.readText("test/testfile2.sdl"));

    foreach (a; arr4) {
        a.writeNode();
    }

    writeln;
    arr4[5].children.writeln();
    writeln;

    writeln(arr4[1].values[0].kind == SDLType.int_);
    writeln(arr4[1].values[0].value!int);

    writeln;

    // SDLNode[] arr5 = parseSDL(f.readText("/g/sily-raylib/example/resource.sdl"), true);
    // arr5.generateSDL.writeln();
    //
    // writeln(arr4[1].values[0].isType!SDLInt);
    //
    // arr5[0].attribute!string("path").writeln();
    // arr5[1].qualifiedName.writeln();
    // arr5[1].node("transform").qualifiedName.writeln();
    // arr5[1].node("transform").getNodes("content").values!int(SDLInt).writeln();
    // arr5[1].getNode("transform").nodes("content").getValues!int(SDLInt).writeln();
    // arr5[1].getNode("transform").getNode("content").values.writeln();
    // arr5[1].getNode("transform").writeln();
    // arr5.attributes!string("type").writeln();
}

// void writeNode(SDLNode node) {
//     node.name.write(" ");
//     node.values.write(" ");
//     node.attributes.writeln();
// }

