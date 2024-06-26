#!/usr/bin/env dub
/+ dub.sdl:
name "propertytest"
dependency "sily" path="../"
targetType "executable"
targetPath "../bin/"
+/
module test.propertytest;

import std.stdio: writeln;
import sily.property;

void main() {
    Thingy t = new Thingy();
    t.trea = "Trea";
    writeln(t.trea);
    writeln(t.treb);
    // t.treb = "Stuff"; // error
    // writeln(t.trec); // error
    t.trec = "Stuff";
    t.tred = "tred";
    writeln(t.tred);
    t.gtree = "gtree";
    writeln(t.gtree);
    t.tredd = "tredd";
    writeln(t.tredd);
    t.c__tref = "c__tref";
    writeln(t.c__tref);
    t.__tredd = "__tredd";
    writeln(t.__tredd);
    t.treedee = "treedee";
    writeln(t.treedee);
    writeln(t.tredd);
}

class Thingy {
    private string _trea = "a";
    private string _treb = "b";
    private string _trec = "c";
    private string __tred = "d";
    private string __tredd = "d";
    private string __tree = "e";
    private string __tref = "f";

    mixin property!_trea;
    mixin getter!(_treb);
    mixin setter!(_trec);
    mixin getter!(__tred, "__");
    mixin setter!(__tred, "__");
    mixin property!(__tree, "__", "g");
    mixin property!(__tref, "", "c");
    mixin property!(__tredd, "__");
    mixin property!(__tredd, "A");
    mixin property!(__tredd, "treedee", true);
    // mixin( property!(__tredd) );

    // mixin(___silyPropertyGenSetter!(__tredd, "", "treedee", true));
    // mixin(___silyPropertyGenGetter!(__tredd, "", "treedee", true));

    // public string treedee(string a, string b) @property {
    //     return (__tredd = a ~ b);
    // }
}
