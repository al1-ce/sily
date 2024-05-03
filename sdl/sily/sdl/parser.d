// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

module sily.sdl.parser;

// import std.string;
import std.ascii: isWhite;
import std.string: toLower;
import std.algorithm.searching: canFind, endsWith;
import std.conv: to;
import std.array: split;

import std.stdio: writeln; // FIXME: remove

import sily.uni: isAlpha, isAlphaNumeric, isDigit;

import sily.sdl.types;

struct SDLParser {
    private char[] _text = [];
    private int _pos = 0;
    private char _char = '\0';
    private bool _eof = false;
    private bool _exception = false;

    // #################################### Constructors

    /// Init lexer for parsing
    this(char[] p_text) {
        _text = p_text;
        _pos = 0;
        _char = (_text.length == 0) ? '\0' : _text[_pos];
        _eof = _text.length == 0;
    }

    /// Ditto
    this(string p_text) {
        _text = cast(char[]) p_text;
        _pos = 0;
        _char = (_text.length == 0) ? '\0' : _text[_pos];
        _eof = _text.length == 0;
    }

    // #################################### Getters

    /// Has exception occured
    @property bool errorStatus() { return _exception; }

    /// Is EOF
    @property bool eof() { return _eof; }

    // #################################### Stream Handling

    /// Returns current character
    private char look() { return _char; }

    /// Compares if current character is `c`
    private bool check(char c) { return _char == c; }

    /// Returns next char or `\0`
    private char peek() { return (_pos + 1 > _text.length) ? '\0' : _text[_pos + 1]; }

    /// Checks next char agains `c`
    private bool peek(char c) { return (_pos + 1 > _text.length) ? false : c == _text[_pos + 1]; }

    /// Moves backwards by `pos` characters
    private void rewind(size_t pos = 1) {
        string skipped = "";
        while (pos--) {
            --_pos;

            if (eof() && _pos < _text.length) {
                _eof = false;
            }

            if (_pos == 0) {
                break;
            }

            _char = (_pos >= _text.length) ? '\0' : _text[_pos];
            skipped = _char ~ skipped;
        }
        // import std.stdio: write; write("\033[41m", skipped, "\033[m");
    }

    /// Moves forward by `pos` characters
    private void skip(size_t pos = 1) {
        while (pos--) {
            if (++_pos >= _text.length) {
                _eof = true;
                _char = '\0';
                break;
            } else {
                _char = _text[_pos];
            }
            // import std.stdio: write; write("\033[42m", _char, "\033[m");
        }
    }

    /// Skips whitespace
    private void skipSpace() {
        while (look().isWhite && !eof()) {
            skip();
        }
    }

    /// Skips non-whitespace
    private void skipToAlpha() {
        while (!look().isAlpha && !eof()) {
            skip();
        }
    }

    // #################################### Token Handling

    SDLValue parseString() {
        // what kind of "string"
        const char br = look();
        string result = "";
        // consume opening quote
        skip();


        // until we hit EOF or closing quote we eat
        while (look() != br && !eof()) {
            // FIXME: don't do escaping on literal string
            // this might be escape sequence
            if (check('\\')) {
                switch (peek()) {
                    case br: result ~= br; break;
                    case 'a': result ~= '\a'; break;
                    case 'b': result ~= '\b'; break;
                    case 'f': result ~= '\f'; break;
                    case 'n': result ~= '\n'; break;
                    case 'r': result ~= '\r'; break;
                    case 't': result ~= '\t'; break;
                    case 'v': result ~= '\v'; break;
                    case '\\': result ~= '\\'; break;
                    case '\'': result ~= '\''; break;
                    case '\"': result ~= '\"'; break;
                    case '\?': result ~= '\?'; break;
                    // we hit end, not good
                    case '\0': skip(); return SDLValue(result);
                    // not escape, add both chars as is
                    default: result ~= [look(), peek()];
                }
                // TODO: digital stuff (\u \x \000)
                // consume escape sequence
                skip(2);
                // must do while checks again, since we did something
                continue;
            }

            // everything is ok, we add normally
            result ~= look();
            skip();
        }

        // consume closing quote
        if (look() == br) skip();

        return SDLValue(result);
    }

    SDLValue parseBinary() { return SDLValue(); }

    SDLValue parseNumber() {
        SDLValue val;
        string num;
        bool hasDecimal = false;

        while (!eof() && !look().isWhite()) {
            // FIXME: only one dot allowed
            if (look().isDigit() || check('.') || check('L') ||
                check('d') || check('f') || (check('B') && peek('D'))) {
                num ~= look();
                if (check('.')) hasDecimal = true;
                if (check('B') && peek('D')) skip();
                if (look().isAlpha()) break;
                skip();
            }
        }

        skip(); // coz we break before skipping

        if (!hasDecimal) {
            if (num.endsWith('L')) return SDLValue(num[0..$-1].to!long);
            return SDLValue(num.to!int);
        } else {
            if (num.endsWith('d')) return SDLValue(num[0..$-1].to!double);
            if (num.endsWith('f')) return SDLValue(num[0..$-1].to!double);
            if (num.endsWith("BD")) {
                string[2] ar = num.split('.');
                long[2] v;
                v[0] = ar[0].to!long;
                v[1] = ar[1].to!long;
                return SDLValue(v);
            }
            return SDLValue(num.to!double);
        }

        // FIXME: do something on error
        writeln("Error: Failed to parse number!!!");
        return SDLValue();
    }

    /// Parses boolean and null
    SDLValue parseBool() { return SDLValue(); }

    SDLAttribute parseAttribute() { return SDLAttribute(); }

    /// Checks if next token is value, rewinds and returns if true
    bool guessIsValue() { return false; }

    SDLTag parseTag() {
        SDLTag tag;

        writeln("Parsing name");
        while (!eof() && !look().isWhite()) {
            if (check(':')) { tag.namespace = tag.name; tag.name = ""; continue; }
            tag.name ~= look();
            skip();
        }
        // FIXME: broken in case of `namespace:` without name
        // FIXME: should allow only [a-zA-Z_][a-zA-Z0-9_-.$]*

        if (tag.name == "") tag.name = "content";
        if (tag.namespace != "") {
            tag.qualifiedName = tag.namespace ~ ':' ~ tag.name;
        } else {
            tag.qualifiedName = tag.name;
        }

        skip();

        while (!eof()) {
            // We can skip \n then
            if (isNewlineSplit()) if (peek('\n')) { skip(2); writeln("newline"); continue; }
            if (check('\n') || check(';')) { skip(); break; } // we don't want NON OTBS HAHAHAHA

            /// Number or date
            if (isNumberStart()) {
                writeln("Parsing number");
                tag.values ~= parseNumber();
                continue;
            }

            // Attrib, auto-attrib, bool, null
            if (isAttributeStart()) {
                writeln("Parsing attrib or bool");
                if (guessIsValue()) {
                    tag.values ~= parseBool();
                } else {
                    tag.attributes ~= parseAttribute();
                }
                continue;
            }

            // Only string
            if (isStringStart()) {
                writeln("Parsing string");
                tag.values ~= parseString();
                continue;
            }

            // Only binary
            if (isBinaryStart()) {
                writeln("Parsing binary");
                tag.values ~= parseBinary();
                continue;
            }

            // Here lie children
            if (check('{')) {
                skip();
                // FIXME: need some elaborate stuff to check if we need to parse children
                writeln("Parsing children");
                parseTag();
                continue;
            }

            // I am child and this is end
            if (check('}')) {
                writeln("No more children");
                skip();
                return tag; // FIXME: eeh?
            }
            // FIXME: if see } and not child what do
        }

        return tag;
    }

    bool isNumberStart() => (look().isDigit() || check('+') || check('-'));
    bool isAttributeStart() => (look().isAlpha());
    bool isStringStart() => (check('"') || check('\'') || check('`'));
    bool isNewlineSplit() => (check('\\') && peek('\n'));
    bool isBinaryStart() => (check('['));

    bool isTagStart() => (check('@') || check('!') || check('$')) || look().isAlpha();

    // #################################### Token Parsing

    /// Advances to next token and returns it
    SDLTag nextToken() {
        SDLTag token;
        while (!eof()) {
            // don't want any spaces
            if (look().isWhite) { skipSpace(); continue; }

            // hit tag, must parse
            if (isTagStart()) {
                writeln("Parsing tag");
                return parseTag();
            } else {
                // FIXME: actually should be an error
                skip();
                writeln("Error: Failing to parse token!!!");
            }

            // not tag, not space, must be text then
            // return parseText();
            break;
        }
        return token;
    }

    SDLTag parse() {
        SDLTag root;
        root.qualifiedName = "root";
        root.name = "root";

        while (!eof()) {
            writeln("Next token");
            SDLTag token = nextToken();
            if (token.empty) break;
            root.children ~= token;
        }

        return root;
    }
}
