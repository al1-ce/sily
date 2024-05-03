#!/usr/bin/env dub
/+ dub.sdl:
name "htmlparsetest"
dependency "sily:web" path="../"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio;

import sily.html;

void main() {
    string s = q"{
<a href="#p64001914" class="quotelink">
    &gt;&gt;64001914
</a>
<br>
Before summer, I think.... They&#039;re probably gonna be at CTW2 this summer. I hope...
<img/>
<img />
<br/> <br />
<img>
<div class="none help" style="test {iam: #25545;}">
    Testing my text wow wohoooo
    <div> child 1 dam</div>
    <div> child 2 wo <div> subchild 1 </div></div>
</div>
}";
    writeln(s);

    HTMLTag[] tags = parseHTML(s);

    writeln();

    foreach (tag; tags) {
        // writeln("TAG!!!!", (*tag).type, "!!!!TAG");
        writeln(tag.toString());
        writeln();
    }
}
