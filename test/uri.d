#!/usr/bin/env dub
/+ dub.sdl:
name "queuetest"
dependency "sily" path="../"
dependency "sily-terminal" version="~>4"
dependency "sily-terminal:logger" version="~>4"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio;
import std.conv: to;
import std.algorithm.searching: canFind;

import sily.uri;

import sily.bashfmt;
import sily.logger;

void eq(T, S, int line = __LINE__, string file = "uri.d")(T t1, S t2, string message = "") {
    bool cond = t1 == t2;
    hr('─', message.to!dstring, cond ? (cast(string) FR.reset) : (cast(string) FG.ltred), 
                cond ? (cast(string) FR.reset) : (cast(string) FG.ltred));
    if (!cond) writeln(cast(string)(FG.dkgray), "Expected: ", cast(string)(FG.ltred));
    if (!cond) {
        write(t2.to!string);
    }
    if (!cond) writeln();
    if (!cond) writeln(cast(string)(FG.dkgray), "Got: ", cast(string)(FG.ltred));
    write(t1.to!string);
    if (!cond) write(cast(string)(FR.fullreset));
    writeln();
}


void main() {
    string[] uris = [
        "http://localhost:80/foo.html?&q=1:2:3",
        "https://localhost:80/foo.html?&q=1",
        "localhost/foo",
        "https://localhost/foo",
        "localhost:8080",
        "localhost?&foo=1",
        "localhost?&foo=1:2:3",
        "ftp://user:passwd@example.com:1555/docs/Java&C++",
        "urn:localhost:8080",
        "urn:loc://localhost/host:8080#?q",
        "//localhost/host:8080#?q",
        "https://john.doe@www.example.com:123/forum/questions/?tag=networking&order=newest#top",
        "ldap://[2001:db8::7]/?c=GB&objectClass&one",
        "mailto:John.Doe@example.com",
        "news:comp.infosystems.www.servers.unix",
        "tel:+1-816-555-1212",
        "telnet://192.0.2.16:80/",
        "urn:oasis:names:specification:docbook:dtd:xml:4.1.2",
        "http://a/b/c/d;p?q",
        "http://editing.com/resource/file.php?command=checkout",
        "test-redirect-drab.vercel.app/?url=https://example.com",
        "/path/resource.txt",
        "path/resource.txt",
        "../resource.txt",
        "./resource.txt",
        "resource.txt",
        "#fragment",
        "uid://duqkskhiei6y4/",
        "res://assets/textures/ship/civilian.png",
        "res://assets/textures/ship/civilian.png;file=new;fil=old?ff=neu",
        "scheme://<username>:<password>@<host>:0/<path>;<parameters>?<query>#<fragment>",
        "http://example.com/:@-._~!$&'()*+,=;:@-._~!$&'()*+,=:@-._~!$&'()*+,==?/?:@-._~!$'()*+,;=/?:@-._~!$'()*+,;==#/?:@-._~!$&'()*+,;=",
        "ldap://[2001:db8::7/?c=GB&objectClass&one",
    ];
    
    foreach (uri; uris) {
        URI u = parseURI(uri);
        string s = u.scheme;
        bool isfile = s == "res" || s == "file" || s == "uid" || s == "";
        writeln(uri);
        if (!isfile) writeln(encodeURI(u));
        if (isfile) writeln(u.filepath);
        writeln(u);
        writeln;
    }

    encodeURI(parseURI(uris[$-6])).eq(uris[$-6]);
    encodeURI(parseURI(uris[$-5])).eq(uris[$-5]);
    encodeURI(parseURI(uris[$-4])).eq(uris[$-4]);
    encodeURI(parseURI(uris[$-3])).eq(uris[$-3]);
    encodeURI(parseURI(uris[$-2])).eq(uris[$-2]);
    encodeURI(parseURI(uris[$-1])).eq(uris[$-1]);

    // URI _u = parseURI(uris[$-1]);
    // _u.host.writeln();
    // _u.path.writeln();
    // _u.parameters.writeln();
    // _u.query.writeln();
    // _u.fragment.writeln();

}
