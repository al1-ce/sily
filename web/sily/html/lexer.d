/++
A very forgiving (because it's html and it's markup) html lexer
+/
module sily.html.lexer;

// import std.string;
import std.ascii: isWhite;
import std.string: toLower;
import std.algorithm.searching: canFind;

import sily.uni: isAlpha, isAlphaNumeric, isDigit;

import sily.html.token;

private const string[] singleTags = [
    "br", "hr"
];

string stripWhitespace(string text) {
    long i;
    for (i = 0; i < text.length; ++i) {
        if (text[i] == '\n') continue;
        if (!text[i].isWhite) {
            break;
        }
    }
    text = text[i..$];
    for (i = cast(long) text.length - 1; i > 0; --i) {
        if (text[i] == '\n') continue;
        if (!text[i].isWhite) {
            break;
        }
    }
    text = text[0..i + 1];
    return text;
}

struct Lexer {
    // #################################### Properties

    /// Text to parse
    private char[] _text = [];

    /// Current position in _text array
    private int _pos = 0;

    /// Current character
    private char _char = '\0';

    /// Is EOF
    private bool _eof = false;

    /// Has exception occured
    private bool _exception = false;

    // #################################### Constructor

    /// Init lexer for parsing
    this(char[] p_text) {
        _text = p_text;
        _pos = 0;
        _char = (_text.length == 0) ? '\0' : _text[_pos];
    }

    /// Ditto
    this(string p_text) {
        _text = cast(char[]) p_text;
        _pos = 0;
        _char = (_text.length == 0) ? '\0' : _text[_pos];
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

    HTMLTag parseTag() {
        skip(); // consume <
        skipSpace(); // skip possible whitespace before tag type

        string type = "";
        string[string] attrib;

        // parsing tag name <TAGNAME> or <TAGNAME >
        while (!check('>') && look().isAlpha && !eof()) {
            type ~= look();
            skip();
        }

        type = toLower(type);
        skipSpace();

        // tag tries to close itself, respect that
        if (check('/') && peek('>')) {
            skip(2);
            return HTMLTag(type);
        }

        // we hit single tag like <br> or <hr>
        if (check('>') && singleTags.canFind(type)) {
            skip();
            return HTMLTag(type);
        }

        // parsing attributes <tag attr="asdasd">
        while (!check('>') && !eof()) {
            skipSpace();

            // end of opened tag
            if (check('>')) break;
            // self-closing tags
            if (check('/') && peek('>')) { skip(2); return HTMLTag(type); }

            // no whitespace so we check for alpha
            // if char is alpha then we start handing properties
            if (!look().isAlpha) {
                skipToAlpha();
            } else {
                string attr = "";
                string val = "";

                // add attribute as long as it's a-zA-Z
                while (look().isAlpha && !check('>') && !eof()) { attr ~= look(); skip(); }

                // if we hit = them it's val assign
                if (check('=') && !peek('>')) {
                    skip();
                    // we hit string
                    if (check('"') || check('\'')) {
                        val = parseString();
                    } else {
                        // not string, consume everything non-whitespace
                        while (!look().isWhite && !check('>') && !eof()) { val ~= look(); skip(); }
                    }
                } else if (check('=')) skip();

                // don't need to care about val because of props like `autoplay`
                if (attr.length != 0) attrib[attr] = val;
            }
        }

        // we either hit EOF or >, which one is it
        if (eof()) return HTMLTag(type, attrib);
        skip();

        HTMLTag[] children = [];
        // text is empty tag
        // until we see next tag start or end
        while (!eof()) {
            string currentText = "";

            // get any text if there is any
            while (!check('<') && !eof()) {
                currentText ~= look();
                skip();
            }

            // if we have any text we want to add it
            currentText = currentText.stripWhitespace();
            if (currentText.length) children ~= HTMLTag("", currentText);

            if (eof()) break;

            // we hit < what to do next
            size_t p = _pos;
            // look ahead if we're closing or not
            // only way we're here is if we hit <
            // so skip it and skip any spaces
            skip();
            skipSpace();
            // possibly closing (now it's 100% closing all time)
            if (check('/')) {
                // ok, so, there was a bunch of stuff, BUT!
                // if we encounter something like
                // <a><b></a></b> it wouldn't make sense
                // so i'm just going to treat nearest closing
                // tag as this closing
                // meaning </THIS_PART> is completely optional
                // and doesn't mean anything for parser
                while (!check('>') && !eof()) skip();
                skip();
                break;
            }

            // not closing it's a new tag,
            // so we're gotta rewind back and parse it
            rewind(_pos - p);
            children ~= parseTag();
        }

        // we either hit end tag or EOF,
        // so only thing left is to return
        return HTMLTag(type, attrib, children);
    }

    HTMLTag parseText() {
        // future me, you ain't dumb enough for me
        // to comment this function like others
        string result = "";
        while (!check('<') && !eof()) {
            result ~= look();
            skip();
        }
        return HTMLTag("", result);
    }

    string parseString() {
        // what kind of "string"
        const char br = look();
        string result = "";
        // consume opening quote
        skip();

        // until we hit EOF or closing quote we eat
        while (look() != br && !eof()) {
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
                    case '\0': skip(); return result;
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

        return result;
    }

    // #################################### Token Parsing

    /// Advances to next token and returns it
    HTMLTag nextToken() {
        while (!eof()) {
            // don't want any spaces
            if (look().isWhite) { skipSpace(); continue; }

            // hit tag, must parse
            if (check('<')) return parseTag();

            // not tag, not space, must be text then
            return parseText();
        }
        return HTMLTag("");
    }
}
