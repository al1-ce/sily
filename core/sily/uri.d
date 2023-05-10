/++
URI/URL/URN parser.

URI scheme:
---
        userinfo            port                       |--query---|
        |      |            | |                        |          |
https://john.doe@www.ex.com:123/forum/question/;par=non?tag=n&ord=o#topmost
|   |   |        |        |   ||              ||      |            |     |
scheme  |        |--host--|   ||-----path-----||path params        |-tag-|
        |                     |
        |------authority------|

URI = scheme ":" ["//" authority] path ["?" query] ["#" fragment]
authority = [userinfo "@"] host [":" port]
---

URI can be either full URI:
---
scheme://userinfo@host:port/path?query#tag
---
Or portions of it:
---
scheme://userinfo@host?query
scheme://host/path
scheme:path
scheme://user:pass@host:244
---
+/
module sily.uri;

import std.conv: to;
import std.string: isNumeric;
import std.algorithm.searching: canFind;

import sily.uni;

/// URI representation
struct URI {
    /// Protocol/Scheme (https:// -> https)
    string protocol = "";
    /// Ditto
    alias scheme = protocol;
    /// User info (s://user.name:pass@host -> user.name:pass)
    string userinfo = "";
    /// Host/Domain (s://host.com/page -> host.com)
    string host = "";
    /// Port (s://host:25545 -> 25545)
    int port = -1;
    /// Path (s://host/path/file -> path/file)
    string path = "";
    /// Path parameters (s://host/path;param=val -> [param=val])
    string[string] parameters;
    /// Query (s://host?q=4;s=5&e=1 -> [q: 4, s: 5, e: 1])
    string[string] query;
    /// Tag/Fragment (s://host#fragment -> fragment)
    string tag = "";
    /// Ditto
    alias fragment = tag;
    /// Is host an IP address
    bool isHostIP = false;
    
    /// Treats host and path as single filepath (i.e file:///home/user/ -> /home/user)
    @property string filepath() {
        string _out;
        if (host.length) _out ~= host;
        if (path.length) _out ~= path;
        if (_out.length > 0 && _out[$-1] == '/') _out = _out[0..$-1];
        return _out;
    }
    
    /// Sets/Returns authority (userinfo@host:port)
    @property string authority() {
        string _out;
        if (userinfo.length) _out ~= userinfo ~ "@";
        if (host.length) _out ~= host;
        if (port >= 0) _out ~= ":" ~ port.to!string;
        return _out;
    }
    /// Ditto
    @property void authority(string uri) {
        string temp = "";
        bool valid;
        int pos = 0;
        
        // Userdata
        for (int i = pos; i < uri.length; ++i) {
            char c = uri[i];
            if (c == '@') {
                valid = true;
                pos = i + 1;
                break;
            }
            temp ~= c;
        }

        if (valid) userinfo = temp;
        valid = false;
        temp = "";
        
        // Host
        for (int i = pos; i < uri.length; ++i) {
            char c = uri[i];
            if (i + 1 == uri.length || c == ':') {
                valid = true;
                if (i + 1 == uri.length) {
                    pos = i + 1;
                    temp ~= c;
                    break;
                }

                bool isPort = true;
                string _t = "";

                for (int j = i + 1; j < uri.length; ++j) {
                    char p = uri[j];
                    _t ~= p;
                    if (p == ':' || !isDigit(p)) {
                        isPort = false;
                        break;
                    }
                }

                if (isPort) {
                    pos = i + 1;
                    break;
                }
            }
            temp ~= c;
        }

        if (valid) {
            host = temp;
            if (pos < uri.length) {
                port = to!int(uri[pos..$]);
            }
        }
    }
    
    /// Set query with query format ("key=val&key2&key3=val2")
    void setQuery(string _query) {
        setQueryParams(_query, '&', query);
    }
    /// Set path parameters with parameters format ("key=val;key2;key3=val2")
    void setParameters(string _query) {
        setQueryParams(_query, ';', parameters);
    }

    private void setQueryParams(string _query, char sep, ref string[string] arr) {
        string key = "";
        string val = "";
        bool iskey = true;
        foreach (c; _query) {
            if (c == '=' && iskey && key.length) {
                iskey = false;
                continue;
            }
            if (c == sep) {
                if (key.length) {
                    arr[key] = val;
                    iskey = true;
                }
                key = "";
                val = "";
                continue;
            }
            if (iskey) {
                key ~= c;
            } else {
                val ~= c;
            }
        }

        if (key.length) arr[key] = val;

    }
}
import std.stdio;
/// Parses URI string
URI parseURI(string uri) {
    URI u = URI();
    
    string temp = "";
    bool valid = false;
    int pos = 0;
    
    // scheme = [a-z, +, -, .]:
    for (int i = pos; i < uri.length; ++i) {
        char c = uri[i];
        if (c == ':') {
            if (uri.length > i + 1 && isDigit(uri[i + 1])) break;
            valid = true;
            pos = i + 1;
            break;
        }
        if (!c.validScheme) break;
        temp ~= c;
    }

    if (valid) u.scheme = temp;
    temp = "";
    valid = false;

    // authority = //user:passwrd@host:port
    // if authority and scheme
    bool isQuery = false;
    if (uri[pos] == '#' || uri[pos] == '?') isQuery = true; 
    bool isAuthorityMarker = uri[pos..pos+2] == "//";
    if (isAuthorityMarker || (u.scheme == "" && !isQuery)) {
        if (isAuthorityMarker) pos += 2;
        if (pos < uri.length && uri[pos] == '[') {
            for (int i = pos + 1; i < uri.length; ++i) {
                if (uri[i] == ']') {
                    u.isHostIP = true;
                    break;
                }
            }
        }
        for (int i = pos; i < uri.length; ++i) {
            char c = uri[i];
            if (c == '/' || c == '?' || c == '#' || i + 1 == uri.length) {
                if (i + 1 == uri.length && c != '/' && c != '?' && c != '#') temp ~= c;
                valid = true;
                pos = i;
                break;
            }
            temp ~= c;
        }
    }

    if (valid && !u.isHostIP) u.authority = temp;
    if (valid && u.isHostIP) u.host = temp;

    if (!valid && u.scheme == "") pos = 0;

    temp = findUntil(uri, pos, '/', [';', '?', '#']);
    if (temp.length) u.path = '/' ~ temp;

    temp = findUntil(uri, pos, ';', ['?', '#']);
    if (temp.length) u.setParameters(temp);

    temp = findUntil(uri, pos, '?', ['#']);
    if (temp.length) u.setQuery(temp);

    temp = findUntil(uri, pos, '#', []);
    if (temp.length) u.fragment = temp;

    return u;
}

/// Encodes URI struct into string
string encodeURI(URI uri) {
    string _out;

    bool hasScheme    = uri.scheme.length != 0;
    bool hasAuthority = uri.authority.length != 0;
    bool hasPath      = uri.path.length != 0;
    bool hasParams    = uri.parameters.length != 0;
    bool hasQuery     = uri.query.length != 0;
    bool hasFragment  = uri.fragment.length != 0;

    if (hasScheme) _out ~= uri.scheme ~ ":";

    if (hasAuthority) {
        if (hasScheme) _out ~= "//";
        _out ~= uri.authority;
        if (!hasPath) _out ~= "/";
    }

    if (hasPath) _out ~= uri.path;

    if (hasParams) {
        _out ~= ";";
        _out ~= joinQuery(uri.parameters, ';');
    }

    if (hasQuery) {
        _out ~= "?";
        _out ~= joinQuery(uri.query, '&');
    }

    if (hasFragment) _out ~= "#" ~ uri.fragment;

    return _out;
}

private string joinQuery(ref string[string] arr, char sep) {
    string _out;
    string[] keys = arr.keys;
    for (int i = 0; i < keys.length; ++i) {
        string key = keys[i];
        _out ~= key;
        if (arr[key].length) _out ~= "=" ~ arr[key];
        if (i + 1 != keys.length) _out ~= sep;
    }
    return _out;
}

private string findUntil(string uri, ref int pos, char _init, char[] _until) {
    string temp;
    for (int i = pos; i < uri.length; ++i) {
        char c = uri[i];
        if (i == pos) {
            if (c != _init) return "";
            continue;
        }
        bool isUntil = _until.canFind(c);
        if (isUntil || i + 1 == uri.length) {
            if (i + 1 == uri.length && !isUntil) temp ~= c;
            pos = i;
            break;
        }
        temp ~= c;
    }
    if (temp.length == 1 && temp[0] == _init) return "";
    return temp;
}

// TODO: encode " " as %20

private bool validScheme(char c) {
    return isAlphaNumeric(c) || c == '+' || c == '-' || c == '.';
}
