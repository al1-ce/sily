// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/**
Module containing various color related utilities
*/
module sily.color;

import std.algorithm : canFind;
import std.algorithm.comparison;
import std.algorithm.comparison: compclamp = clamp;
import std.array : replace;
import std.conv;
import std.math;
import std.regex;
import std.stdio;
import std.string;
import std.traits;
import std.uni : toLower;
import std.traits: isNumeric;

import sily.vector;
import sily.meta.swizzle;
import sily.array;

/// GLSL style alias to Color
alias col = Color;
alias Color8 = color8;

/// Constructs color from 8 bit (0-255) components
private Color color8(ubyte R, ubyte G, ubyte B, ubyte A = 255) {
    return Color(R / 255.0f, G / 255.0f, B / 255.0f, A / 255.0f);
}

/// Color structure with data accesible with `[N]` or swizzling
struct Color {
    /// Color data
    float[4] data = 1.0f;

    /// Alias to allow easy `data` access
    alias data this;
    /// Alias to data
    alias arrayof = data;

    /**
    Constructs Color from float components. If no components present
    color will default to white ([1, 1, 1, 1])
    Example:
    ---
    // You can explicitly define alpha or omit it
    Color red = Color(1, 0, 0);
    Color reda = Color(1, 0, 0, 1);
    // If presented with one or two components
    // color will fill rgb portion of itself
    // with only this component
    // You can also omit/define alpha with it
    Color gray = Color(0.5);
    Color graya = Color(0.5, 0.8);
    // Also theres two aliases to help you
    // GLSL style color as type
    col c = col(0.2, 0.4, 1)
    // And custom constructor that allows you
    // to use 8 bit values (0-255)
    Color webCol = Color8(255, 0, 255);
    // Colors can be accessed with array slicing,
    // by using color symbols or swizzling (rgba)
    float rcomp = c.r;
    float gcomp = c[1];
    float bcomp = c.b;
    float[] redblue = c.rb;
    float[] redbluebluegreen = c.rbbg;
    ---
    */
    this(in float val) {
        foreach (i; 0 .. 3) { data[i] = val; }
        data[3] = 1.0f;
    }
    /// Ditto
    this(in float val, in float a) {
        foreach (i; 0 .. 3) { data[i] = val; }
        data[3] = a;
    }
    /// Ditto
    this(in float[3] vals...) {
        data = vals ~ [1.0f];
    }
    /// Ditto
    this(in float[4] vals...) {
        data = vals;
    }

    /// Returns color component in 8 bit form
    ubyte r8() { return cast(ubyte) (data[0] * 255u); }
    /// Ditto
    ubyte g8() { return cast(ubyte) (data[1] * 255u); }
    /// Ditto
    ubyte b8() { return cast(ubyte) (data[2] * 255u); }
    /// Ditto
    ubyte a8() { return cast(ubyte) (data[3] * 255u); }

    /* -------------------------------------------------------------------------- */
    /*                         UNARY OPERATIONS OVERRIDES                         */
    /* -------------------------------------------------------------------------- */

    /// opBinary x [+, -, *, /, %] y
    auto opBinary(string op, R)(in Color!(R, N) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        Color ret = Color();
        foreach (i; 0 .. 4) { mixin( "ret.data[i] = data[i] " ~ op ~ " b.data[i];" ); }
        return ret;
    }

    /// Ditto
    auto opBinaryRight(string op, R)(in Color!(R, N) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        Color ret = Color();
        foreach (i; 0 .. 4) { mixin( "ret[i] = b.data[i] " ~ op ~ " data[i];" ); }
        return ret;
    }

    /// Ditto
    auto opBinary(string op, R)(in R b) const if ( isNumeric!R ) {
        // assert(this !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        Color ret = Color();
        foreach (i; 0 .. 4) { mixin( "ret.data[i] = data[i] " ~ op ~ " b;" ); }
        return ret;
    }

    /// Ditto
    auto opBinaryRight(string op, R)(in R b) const if ( isNumeric!R ) {
        // assert(this !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        Color ret = Color();
        foreach (i; 0 .. 4) { mixin( "ret[i] = b " ~ op ~ " data[i];" ); }
        return ret;
    }

    /// opEquals x == y
    bool opEquals(R)(in Color!(R, 4) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        bool eq = true;
        foreach (i; 0 .. 4) {
            eq = eq && data[i] == b.data[i];
            if (!eq) break;
        }
        return eq;
    }

    /// opCmp x [< > <= >=] y
    int opCmp(R)(in Color!(R, N) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        float al = luminance;
        float bl = b.luminance;
        if (al == bl) return 0;
        if (al < bl) return -1;
        return 1;
    }

    /// opUnary [-, +, --, ++] x
    auto opUnary(string op)() if(op == "-"){
        // assert(this !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        Color ret = Color();
        if (op == "-")
            foreach (i; 0 .. 4) { ret.data[i] = -data[i]; }
        return ret;
    }

    /// opOpAssign x [+, -, *, /, %]= y
    auto opOpAssign(string op, R)( in Color!(R, N) b ) if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        foreach (i; 0 .. 4) { mixin( "data[i] = data[i] " ~ op ~ " b.data[i];" ); }
        return this;
    }

    /// Ditto
    auto opOpAssign(string op, R)( in R b ) if ( isNumeric!R ) {
        // assert(this !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        foreach (i; 0 .. 4) { mixin( "data[i] = data[i] " ~ op ~ " b;" ); }
        return this;
    }

    /// opCast cast(x) y
    R opCast(R)() const if (isVector!R && (R.size == 3 || R.size == 4) && isFloatingPoint!(R.dataType)){
        R ret;
        foreach (i; 0 ..  R.size) {
            ret[i] = cast(R.dataType) data[i];
        }
        return ret;
    }
    /// Ditto
    R opCast(R)() const if (isVector!R && (R.size == 3 || R.size == 4) && !isFloatingPoint!(R.dataType)){
        R ret;
        foreach (i; 0 ..  R.size) {
            ret[i] = cast(R.dataType) (data[i] * 255.0f);
        }
        return ret;
    }
    /// Ditto
    bool opCast(T)() const if (is(T == bool)) {
        float s = 0;
        foreach (i; 0..3) {
            s += data[i];
        }
        return !s.isClose(0, float.epsilon);
    }


    /// Returns hash
    size_t toHash() const @safe nothrow {
        return typeid(data).getHash(&data);
    }

    // incredible magic from sily.meta
    // idk how it works but it works awesome
    // and im not going to touch it at all
    enum AccessString = "r g b a"; // exclude from docs
    mixin accessByString!(float, 4, "data", AccessString); // exclude from docs

    // /**
    // Returns color transformed to float vector.
    // Also direct assign syntax is allowed:
    // ---
    // // Assigns rgba values
    // Vector!(float, 4) v4 = Color(0.4, 1.0);
    // // Only rgb values
    // Vector!(float, 3) v3 = Color(0.7);
    // ---
    // */
    // vec4 asVector4f() {
    //     return vec4(data);
    // }
    // /// Ditto
    // vec3 asVector3f() {
    //     return vec3(data[0..3]);
    // }

    /// Returns copy of color
    Color copyof() {
        return Color(data);
    }

    /// Returns string representation of color: `[1.00, 1.00, 1.00, 1.00]`
    string toString() const {
        import std.conv : to;
        string s;
        s ~= "[";
        foreach (i; 0 .. 4) {
            s ~= format("%.2f", data[i]);
            if (i != 4 - 1) s ~= ", ";
        }
        s ~= "]";
        return s;
    }

    /// Returns pointer to data
    float* ptr() return {
        return data.ptr;
    }

    /* -------------------------------------------------------------------------- */
    /*                                 PROPERTIES                                 */
    /* -------------------------------------------------------------------------- */

    /// Returns: inverted color
    Color invert(bool invertAlpha = false) {
        Color c;
        c.data[0] = 1.0f - data[0];
        c.data[1] = 1.0f - data[1];
        c.data[2] = 1.0f - data[2];
        if (invertAlpha) c.data[3] = 1.0f - data[3];
        return c;
    }

    /// Returns: luminance of the color in the [0.0, 1.0] range
    float luminance() {
        return compclamp(0.2126f * data[0] + 0.7152f * data[1] + 0.0722f * data[2], 0.0f, 1.0f);
    }

    /**
    Returns the linear interpolation with another color
    Params:
      p_to = Color to interpolate with
      p_weight = Interpolation factor in [0.0, 1.0] range
    */
	Color lerp(const Color p_to, float p_weight) {
        Color c;
		c.data[0] = data[0] + (p_weight * (p_to.data[0] - data[0]));
		c.data[1] = data[1] + (p_weight * (p_to.data[1] - data[1]));
		c.data[2] = data[2] + (p_weight * (p_to.data[2] - data[2]));
		c.data[3] = data[3] + (p_weight * (p_to.data[3] - data[3]));
        return c;
	}

    /**
    Darkens color by `p_amount`
    Params:
      p_amount = Amount to darken
    */
	Color darken(float p_amount) {
        Color c;
		c.data[0] = data[0] * (1.0f - p_amount);
		c.data[1] = data[1] * (1.0f - p_amount);
		c.data[2] = data[2] * (1.0f - p_amount);
        return c;
	}

    /**
    Lightens color by `p_amount`
    Params:
      p_amount = Amount to lighten
    */
	Color lighten(float p_amount) {
        Color c;
		c.data[0] = data[0] + (1.0f - data[0]) * p_amount;
		c.data[1] = data[1] + (1.0f - data[1]) * p_amount;
		c.data[2] = data[2] + (1.0f - data[2]) * p_amount;
        return c;
	}

    /**
    Clamps color values between `min` and `max`
    Params:
      min = Minimal allowed value
      max = Maximal allowed value
    */
    Color clamp(float min = 0.0f, float max = 1.0f) {
        Color c;
        c.data[0] = compclamp(data[0], min, max);
        c.data[1] = compclamp(data[1], min, max);
        c.data[2] = compclamp(data[2], min, max);
        c.data[3] = compclamp(data[3], min, max);
        return c;
    }

    /* -------------------------------------------------------------------------- */
    /*                                    HTML                                    */
    /* -------------------------------------------------------------------------- */

    private uint tocolbit(uint c_bits, int[4] c_order ...) {
        uint c_size = 2.pow(c_bits) - 1;
        uint c_shift = c_bits;
        uint c = (data[c_order[0]] * c_size).round.to!uint;
        c <<= c_shift;
        c |= (data[c_order[1]] * c_size).round.to!uint;
        c <<= c_shift;
        c |= (data[c_order[2]] * c_size).round.to!uint;
        c <<= c_shift;
        c |= (data[c_order[3]] * c_size).round.to!uint;
        return c;
    }

    // uint toargb32() { return tocolbit(8, 3, 0, 1, 2); }
    // uint toabgr32() { return tocolbit(8, 3, 2, 1, 0); }
    // uint torgba32() { return tocolbit(8, 0, 1, 2, 3); }
    // uint toargb64() { return tocolbit(16, 3, 0, 1, 2); }
    // uint toabgr64() { return tocolbit(16, 3, 2, 1, 0); }
    // uint torgba64() { return tocolbit(16, 0, 1, 2, 3); }

    private string _to_hex(float p_val) const {
        int v = (p_val * 255).round.to!int;
        v = v.clamp(0, 255);
        string ret;

        for (int i = 0; i < 2; i++) {
            char[2] c = [ 0, 0 ];
            int lv = v & 0xF;
            if (lv < 10) {
                c[0] = ('0' + lv).to!char;
            } else {
                c[0] = ('a' + lv - 10).to!char;
            }

            v >>= 4;
            string cs = c.to!string;
            ret = cs ~ ret;
        }

        return ret;
    }

    /**
    Returns html representation of color in format `#RRGGBB`
    If `p_alpha` is true returns color in format `#RRGGBBAA`
    Params:
      p_alpha = Include alpha?
    Returns: Html string
    */
    string toHtml(bool p_alpha = false) {
        string txt;
        txt ~= _to_hex(data[0]);
        txt ~= _to_hex(data[1]);
        txt ~= _to_hex(data[2]);
        if (p_alpha) {
            txt ~= _to_hex(data[3]);
        }
        return txt;
    }

    /**
    Returns hex representation of color in format `0xrrggbb`
    Returns: uint hex
    */
    uint toHex() {
        int r = rint(data[0] * 255);
        int g = rint(data[1] * 255);
        int b = rint(data[2] * 255);
        return ((r & 0xff) << 16) + ((g & 0xff) << 8) + (b & 0xff);
    }

    /* -------------------------------------------------------------------------- */
    /*                                   SETTERS                                  */
    /* -------------------------------------------------------------------------- */

    private static Color fromHex(uint p_hex, uint c_mask, uint c_bits, bool c_hasAlpha) {
        float c_size = (2.pow(c_bits) - 1).to!float;
        uint c_shift = c_bits;
        float a = 0;
        if (c_hasAlpha) {
            a = (p_hex & c_mask) / c_size;
            p_hex >>= c_shift;
        }
        float b = (p_hex & c_mask) / c_size;
        p_hex >>= c_shift;
        float g = (p_hex & c_mask) / c_size;
        p_hex >>= c_shift;
        float r = (p_hex & c_mask) / c_size;

        return Color(r, g, b, a);
    }

    /**
    Constructs color from hexadecimal value
    Params:
      p_hex = uint hex value to set color to
      p_hasAlpha = Does p_hex include alpha
    */
    static Color fromHex(uint p_hex, bool p_hasAlpha = false) { return col.fromHex(p_hex, 0xFF, 8, p_hasAlpha); }
    // void setHex64(uint p_hex, bool p_hasAlpha = false) { setHex(p_hex, 0xFFFF, 16, p_hasAlpha); }

    /**
    Constructs color from hsv
    Params:
      p_h = hue
      p_s = saturation
      p_v = value
      p_alpha = alpha
    */
    static Color fromHsv(float p_h, float p_s, float p_v, float p_alpha = 1.0f) {
        int i;
        float f, p, q, t;
        Color c;
        c.data[3] = p_alpha;

        if (p_s == 0) {
            return Color(p_v, p_v, p_v);
        }

        p_h *= 6.0f;
        p_h = p_h.fmod(6);
        i = p_h.floor().to!int;

        f = p_h - i;
        p = p_v * (1 - p_s);
        q = p_v * (1 - p_s * f);
        t = p_v * (1 - p_s * (1 - f));

        switch (i) {
            case 0: // Red is the dominant color
                c.data[0] = p_v;
                c.data[1] = t;
                c.data[2] = p;
                break;
            case 1: // Green is the dominant color
                c.data[0] = q;
                c.data[1] = p_v;
                c.data[2] = p;
                break;
            case 2:
                c.data[0] = p;
                c.data[1] = p_v;
                c.data[2] = t;
                break;
            case 3: // Blue is the dominant color
                c.data[0] = p;
                c.data[1] = q;
                c.data[2] = p_v;
                break;
            case 4:
                c.data[0] = t;
                c.data[1] = p;
                c.data[2] = p_v;
                break;
            default: // (5) Red is the dominant color
                c.data[0] = p_v;
                c.data[1] = p;
                c.data[2] = q;
                break;
        }

        return c;
    }

    /**
    Constructs color from html string in format `#RRGGBB`
    Params:
      html = Color string
    */
    static Color fromHtml(string html) {
        auto rg = regex(r"/^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i");
        auto m = matchAll(html, rg);
        m.popFront();
        float _r = to!int(m.front.hit, 16) / 255; m.popFront();
        float _g = to!int(m.front.hit, 16) / 255; m.popFront();
        float _b = to!int(m.front.hit, 16) / 255; m.popFront();
        return Color(to!float(_r), to!float(_g), to!float(_b), 1.0f);
    }

    /* -------------------------------------------------------------------------- */
    /*                               HSV PROPERTIES                               */
    /* -------------------------------------------------------------------------- */

    /// Returns `h` component of hsv
    float hue() {
        float cmin = data[0].min(data[1]);
        cmin = cmin.min(data[2]);
        float cmax = data[0].max(data[1]);
        cmax = cmax.min(data[2]);

        float delta = cmax - cmin;
        if (delta == 0) { return 0; }

        float h;
        if (data[0] == cmax) {
            h = (data[1] - data[2]) / delta;
        } else
        if (data[1] == cmax) {
            h = 2 + (data[2] - data[0]) / delta;
        } else {
            h = 4 + (data[2] - data[0]) / delta;
        }

        h /= 6.0f;
        if (h < 0) {
            h += 1.0f;
        }
        return h;
    }

    /// Returns `s` component of hsv
    float saturation() {
        float cmin = data[0].min(data[1]);
        cmin = cmin.min(data[2]);
        float cmax = data[0].max(data[1]);
        cmax = cmax.min(data[2]);

        float delta = cmax - cmin;

        return (cmax != 0) ? (delta / cmax) : 0;
    }

    /// Returns `v` component of hsv
    float value() {
        float cmax = data[0].max(data[1]);
        cmax = cmax.max(data[2]);
        return cmax;
    }

    /* -------------------------------------------------------------------------- */
    /*                                BASH GETTERS                                */
    /* -------------------------------------------------------------------------- */

    /**
    Constructs color from ANSI index
    Params:
      ansi = Color index
    */
    static Color fromAnsi8(int ansi) {
        if (ansi > 100) ansi -= 92;
        if (ansi > 90) ansi -= 82;
        if (ansi > 40) ansi -= 40;
        if (ansi > 30) ansi -= 30;
        if (ansi >= lowHEX.length) ansi = lowHEX.length.to!int - 1;
        if (ansi < 0) ansi = 0;
        // write(ansi);
        return Color.fromHex(lowHEX[ansi]);
    }

    /**
    Constructs color from ANSI256 index
    Params:
      ansi = Color index
    */
    static Color fromAnsi(int ansi) {
        if (ansi < 0 || ansi > 255) {
            return Color(0);
        }
        if (ansi < 16) {
            return Color.fromHex(Color.lowHEX[ansi]);
        }

        if (ansi > 231) {
            const int s = (ansi - 232) * 10 + 8;
            return Color(s / 255.0f, s / 255.0f, s / 255.0f, 1);
        }

        const int n = ansi - 16;
        int _b = n % 6;
        int _g = (n - _b) / 6 % 6;
        int _r = (n - _b - _g * 6) / 36 % 6;
        _b = _b ? _b * 40 + 55 : 0;
        _r = _r ? _r * 40 + 55 : 0;
        _g = _g ? _g * 40 + 55 : 0;

        return Color(_r / 255.0, _g / 255.0, _b / 255.0, 1);
    }

    /* -------------------------------------------------------------------------- */
    /*                                BASH SETTERS                                */
    /* -------------------------------------------------------------------------- */

    private alias rint = (a) => to!int(round(a));


    private float colorDistance(Color e1, Color e2) {
        int rmean = ( cast(int) e1.r + cast(int) e2.r ) / 2;
        int r = cast(int) e1.r - cast(int) e2.r;
        int g = cast(int) e1.g - cast(int) e2.g;
        int b = cast(int) e1.b - cast(int) e2.b;
        // return sqrt(
        //     (((512 + rmean) * r * r) >> 8) +
        //     4.0f * g * g +
        //     (((767 - rmean) * b * b) >> 8)
        //     );
        return sqrt((2 + rmean / 255) * r * r + 4 * g * g + (2 + (255 - rmean) / 255) * b * b + 0.0f);
    }

    /**
    Returns closest ANSI8 color index
    Params:
      isBackground = Is color a background
    Returns: ANSI8 color
    */
    int toAnsi8(bool isBackground = false) {
        /*
        39 - default foreground, 49 - default backgound
        Main colors are from 30 - 39, light variant is 90 - 97.
        97 is white, 30 is black. to get background - add 10 to color code
        goes like:
        black, red, green, yellow, blue, magenta, cyan, lgray
        then repeat with lighter variation
        */

        int ri = rint(data[0] * 255);
        int gi = rint(data[1] * 255);
        int bi = rint(data[2] * 255);

        if (ri / 64 == gi / 64 && gi / 64 == bi / 64) {
            // 0 128 192 255
            if (ri <= 64) return 30 + (isBackground ? 10 : 0);
            if (ri <= 160) return 90 + (isBackground ? 10 : 0);
            if (ri <= 224) return 37 + (isBackground ? 10 : 0);
            if (ri <= 255) return 97 + (isBackground ? 10 : 0);
        }

        // int diff = 255 * 3;
        float diff = 255 * 3;
        int pos = 0;
        // writeln(lowHEX[15] - hex);
        for (int i = 0; i < 16; i ++) {
            if (i == 0 || i == 7 || i == 8 || i == 15) continue;
            int rh = lowRGB[i * 3];
            int gh = lowRGB[i * 3 + 1];
            int bh = lowRGB[i * 3 + 2];
            // int rd = abs(rh - ri);
            // int gd = abs(gh - gi);
            // int bd = abs(bh - bi);
            // int udiff = rd + gd + bd;
            float udiff = colorDistance(col(ri, gi, bi), col(rh, gh, bh));
            if (udiff < diff) {
                diff = udiff;
                pos = i;
            }
        }
        // write(pos);

        int ansi = pos + 30;
        if (pos >= 8) ansi += 60 - 8;
        return ansi + (isBackground ? 10 : 0);
    }

    /**
    Returns closest ANSI256 color index
    */
    int toAnsi() {
        /*
        256 ANSI color coding is:
        0 - 14 Special colors, probably check by hand
        goes like:
        black, red, green, yellow, blue, magenta, cyan, lgray
        then repeat with lighter variation
        16 - 231 RGB colors with color coding like this:
        Pure R component is on 16, 52, 88, 124, 160, 196. Aka map(r, comp)
        B component is r +0..5
        G component is rb +0,6,12,18,24,30 (but not 36 coz it's next red)
        in end rgb coding, considering mcol = floor(col*5)
        rgbansi = 16 + (16 * r) + (6 * g) + b;
        232 - 255 Grayscale from dark to light
        refer to https://misc.flogisoft.com/_media/bash/colors_format/256-colors.sh-v2.png
        */

        float r = data[0];
        float g = data[1];
        float b = data[2];

        int ri = rint(data[0] * 255);
        int gi = rint(data[1] * 255);
        int bi = rint(data[2] * 255);

        if (ri / 16 == gi / 16 && gi / 16 == bi / 16) {
            // handles grayscale
            if (ri < 8) {
                return 16;
            }

            if (ri > 248) {
                return 231;
            }

            return rint(((ri - 8.0) / 247.0) * 24.0) + 232;
        }

        int ansi = 16
            + ( 36 * rint(r * 5))
            + ( 6 *  rint(g * 5))
            +        rint(b * 5);

        return ansi;
    }

    /**
    Returns closest bash ANSI8 color string
    Params:
      isBackground = Is color a background
    Returns: Bash ANSI8 color string
    */
    string toAnsi8String(bool isBackground = false) {
        return "\033[" ~ toAnsi8(isBackground).to!string ~ "m";
    }

    /**
    Returns closest bash ANSI256 color string
    Params:
      isBackground = Is color a background
    Returns: Bash ANSI256 color string
    */
    string toAnsiString(bool isBackground = false) {
        return (isBackground ? "\033[48;5;" : "\033[38;5;") ~
            toAnsi().to!string ~ "m";
    }

    /**
    Returns bash truecolor string
    Params:
      isBackground = Is color a background
    Returns: Bash truecolor string
    */
    string toTrueColorString(bool isBackground = false) {
        return (isBackground ? "\033[48;2;" : "\033[38;2;") ~
            rint(data[0] * 255).to!string ~ ";" ~
            rint(data[1] * 255).to!string ~ ";"  ~
            rint(data[2] * 255).to!string  ~ "m";

    }

    private static const uint[] lowHEX = [
    0x000000, 0x800000, 0x008000, 0x808000, 0x000080, 0x800080, 0x008080, 0xc0c0c0,
    0x808080, 0xff0000, 0x00ff00, 0xffff00, 0x0000ff, 0xff00ff, 0x00ffff, 0xffffff
    ];

    private static const ushort[] lowRGB = [
        0, 0, 0,  128, 0, 0,  0, 128, 0,  128, 128, 0,  0, 0, 128,  128, 0, 128,  0, 128, 128,  192, 192, 192,
        128, 128, 128,  255, 0, 0,  0, 255, 0,  255, 255, 0,  0, 0, 255,  255, 0, 255,  0, 255, 255,  255, 255, 255
    ];
}

/// Enum containing most common web colors
enum Colors: Color {
    aliceBlue            = Color8(240,248,255), /// <font color=aliceBlue>&#x25FC;</font>
    antiqueWhite         = Color8(250,235,215), /// <font color=antiqueWhite>&#x25FC;</font>
    aqua                 = Color8(0,255,255),   /// <font color=aqua>&#x25FC;</font>
    aquamarine           = Color8(127,255,212), /// <font color=aquamarine>&#x25FC;</font>
    azure                = Color8(240,255,255), /// <font color=azure>&#x25FC;</font>
    beige                = Color8(245,245,220), /// <font color=beige>&#x25FC;</font>
    bisque               = Color8(255,228,196), /// <font color=bisque>&#x25FC;</font>
    black                = Color8(0,0,0),       /// <font color=black>&#x25FC;</font>
    blanchedAlmond       = Color8(255,235,205), /// <font color=blanchedAlmond>&#x25FC;</font>
    blue                 = Color8(0,0,255),     /// <font color=blue>&#x25FC;</font>
    blueViolet           = Color8(138,43,226),  /// <font color=blueViolet>&#x25FC;</font>
    brown                = Color8(165,42,42),   /// <font color=brown>&#x25FC;</font>
    burlyWood            = Color8(222,184,135), /// <font color=burlyWood>&#x25FC;</font>
    cadetBlue            = Color8(95,158,160),  /// <font color=cadetBlue>&#x25FC;</font>
    chartreuse           = Color8(127,255,0),   /// <font color=chartreuse>&#x25FC;</font>
    chocolate            = Color8(210,105,30),  /// <font color=chocolate>&#x25FC;</font>
    coral                = Color8(255,127,80),  /// <font color=coral>&#x25FC;</font>
    cornflowerBlue       = Color8(100,149,237), /// <font color=cornflowerBlue>&#x25FC;</font>
    cornsilk             = Color8(255,248,220), /// <font color=cornsilk>&#x25FC;</font>
    crimson              = Color8(220,20,60),   /// <font color=crimson>&#x25FC;</font>
    cyan                 = Color8(0,255,255),   /// <font color=cyan>&#x25FC;</font>
    darkBlue             = Color8(0,0,139),     /// <font color=darkBlue>&#x25FC;</font>
    darkCyan             = Color8(0,139,139),   /// <font color=darkCyan>&#x25FC;</font>
    darkGoldenrod        = Color8(184,134,11),  /// <font color=darkGoldenrod>&#x25FC;</font>
    darkGray             = Color8(169,169,169), /// <font color=darkGray>&#x25FC;</font>
    darkGrey             = Color8(169,169,169), /// <font color=darkGrey>&#x25FC;</font>
    darkGreen            = Color8(0,100,0),     /// <font color=darkGreen>&#x25FC;</font>
    darkKhaki            = Color8(189,183,107), /// <font color=darkKhaki>&#x25FC;</font>
    darkMagenta          = Color8(139,0,139),   /// <font color=darkMagenta>&#x25FC;</font>
    darkOliveGreen       = Color8(85,107,47),   /// <font color=darkOliveGreen>&#x25FC;</font>
    darkOrange           = Color8(255,140,0),   /// <font color=darkOrange>&#x25FC;</font>
    darkOrchid           = Color8(153,50,204),  /// <font color=darkOrchid>&#x25FC;</font>
    darkRed              = Color8(139,0,0),     /// <font color=darkRed>&#x25FC;</font>
    darkSalmon           = Color8(233,150,122), /// <font color=darkSalmon>&#x25FC;</font>
    darkSeaGreen         = Color8(143,188,143), /// <font color=darkSeaGreen>&#x25FC;</font>
    darkSlateBlue        = Color8(72,61,139),   /// <font color=darkSlateBlue>&#x25FC;</font>
    darkSlateGray        = Color8(47,79,79),    /// <font color=darkSlateGray>&#x25FC;</font>
    darkSlateGrey        = Color8(47,79,79),    /// <font color=darkSlateGrey>&#x25FC;</font>
    darkTurquoise        = Color8(0,206,209),   /// <font color=darkTurquoise>&#x25FC;</font>
    darkViolet           = Color8(148,0,211),   /// <font color=darkViolet>&#x25FC;</font>
    deepPink             = Color8(255,20,147),  /// <font color=deepPink>&#x25FC;</font>
    deepSkyBlue          = Color8(0,191,255),   /// <font color=deepSkyBlue>&#x25FC;</font>
    dimGray              = Color8(105,105,105), /// <font color=dimGray>&#x25FC;</font>
    dimGrey              = Color8(105,105,105), /// <font color=dimGrey>&#x25FC;</font>
    dodgerBlue           = Color8(30,144,255),  /// <font color=dodgerBlue>&#x25FC;</font>
    fireBrick            = Color8(178,34,34),   /// <font color=fireBrick>&#x25FC;</font>
    floralWhite          = Color8(255,250,240), /// <font color=floralWhite>&#x25FC;</font>
    forestGreen          = Color8(34,139,34),   /// <font color=forestGreen>&#x25FC;</font>
    fuchsia              = Color8(255,0,255),   /// <font color=fuchsia>&#x25FC;</font>
    gainsboro            = Color8(220,220,220), /// <font color=gainsboro>&#x25FC;</font>
    ghostWhite           = Color8(248,248,255), /// <font color=ghostWhite>&#x25FC;</font>
    gold                 = Color8(255,215,0),   /// <font color=gold>&#x25FC;</font>
    goldenrod            = Color8(218,165,32),  /// <font color=goldenrod>&#x25FC;</font>
    gray                 = Color8(128,128,128), /// <font color=gray>&#x25FC;</font>
    grey                 = Color8(128,128,128), /// <font color=grey>&#x25FC;</font>
    green                = Color8(0,128,0),     /// <font color=green>&#x25FC;</font>
    greenYellow          = Color8(173,255,47),  /// <font color=greenYellow>&#x25FC;</font>
    honeydew             = Color8(240,255,240), /// <font color=honeydew>&#x25FC;</font>
    hotPink              = Color8(255,105,180), /// <font color=hotPink>&#x25FC;</font>
    indianRed            = Color8(205,92,92),   /// <font color=indianRed>&#x25FC;</font>
    indigo               = Color8(75,0,130),    /// <font color=indigo>&#x25FC;</font>
    ivory                = Color8(255,255,240), /// <font color=ivory>&#x25FC;</font>
    khaki                = Color8(240,230,140), /// <font color=khaki>&#x25FC;</font>
    lavender             = Color8(230,230,250), /// <font color=lavender>&#x25FC;</font>
    lavenderBlush        = Color8(255,240,245), /// <font color=lavenderBlush>&#x25FC;</font>
    lawnGreen            = Color8(124,252,0),   /// <font color=lawnGreen>&#x25FC;</font>
    lemonChiffon         = Color8(255,250,205), /// <font color=lemonChiffon>&#x25FC;</font>
    lightBlue            = Color8(173,216,230), /// <font color=lightBlue>&#x25FC;</font>
    lightCoral           = Color8(240,128,128), /// <font color=lightCoral>&#x25FC;</font>
    lightCyan            = Color8(224,255,255), /// <font color=lightCyan>&#x25FC;</font>
    lightGoldenrodYellow = Color8(250,250,210), /// <font color=lightGoldenrodYellow>&#x25FC;</font>
    lightGray            = Color8(211,211,211), /// <font color=lightGray>&#x25FC;</font>
    lightGrey            = Color8(211,211,211), /// <font color=lightGrey>&#x25FC;</font>
    lightGreen           = Color8(144,238,144), /// <font color=lightGreen>&#x25FC;</font>
    lightPink            = Color8(255,182,193), /// <font color=lightPink>&#x25FC;</font>
    lightSalmon          = Color8(255,160,122), /// <font color=lightSalmon>&#x25FC;</font>
    lightSeaGreen        = Color8(32,178,170),  /// <font color=lightSeaGreen>&#x25FC;</font>
    lightSkyBlue         = Color8(135,206,250), /// <font color=lightSkyBlue>&#x25FC;</font>
    lightSlateGray       = Color8(119,136,153), /// <font color=lightSlateGray>&#x25FC;</font>
    lightSlateGrey       = Color8(119,136,153), /// <font color=lightSlateGrey>&#x25FC;</font>
    lightSteelBlue       = Color8(176,196,222), /// <font color=lightSteelBlue>&#x25FC;</font>
    lightYellow          = Color8(255,255,224), /// <font color=lightYellow>&#x25FC;</font>
    lime                 = Color8(0,255,0),     /// <font color=lime>&#x25FC;</font>
    limeGreen            = Color8(50,205,50),   /// <font color=limeGreen>&#x25FC;</font>
    linen                = Color8(250,240,230), /// <font color=linen>&#x25FC;</font>
    magenta              = Color8(255,0,255),   /// <font color=magenta>&#x25FC;</font>
    maroon               = Color8(128,0,0),     /// <font color=maroon>&#x25FC;</font>
    mediumAquamarine     = Color8(102,205,170), /// <font color=mediumAquamarine>&#x25FC;</font>
    mediumBlue           = Color8(0,0,205),     /// <font color=mediumBlue>&#x25FC;</font>
    mediumOrchid         = Color8(186,85,211),  /// <font color=mediumOrchid>&#x25FC;</font>
    mediumPurple         = Color8(147,112,219), /// <font color=mediumPurple>&#x25FC;</font>
    mediumSeaGreen       = Color8(60,179,113),  /// <font color=mediumSeaGreen>&#x25FC;</font>
    mediumSlateBlue      = Color8(123,104,238), /// <font color=mediumSlateBlue>&#x25FC;</font>
    mediumSpringGreen    = Color8(0,250,154),   /// <font color=mediumSpringGreen>&#x25FC;</font>
    mediumTurquoise      = Color8(72,209,204),  /// <font color=mediumTurquoise>&#x25FC;</font>
    mediumVioletRed      = Color8(199,21,133),  /// <font color=mediumVioletRed>&#x25FC;</font>
    midnightBlue         = Color8(25,25,112),   /// <font color=midnightBlue>&#x25FC;</font>
    mintCream            = Color8(245,255,250), /// <font color=mintCream>&#x25FC;</font>
    mistyRose            = Color8(255,228,225), /// <font color=mistyRose>&#x25FC;</font>
    moccasin             = Color8(255,228,181), /// <font color=moccasin>&#x25FC;</font>
    navajoWhite          = Color8(255,222,173), /// <font color=navajoWhite>&#x25FC;</font>
    navy                 = Color8(0,0,128),     /// <font color=navy>&#x25FC;</font>
    oldLace              = Color8(253,245,230), /// <font color=oldLace>&#x25FC;</font>
    olive                = Color8(128,128,0),   /// <font color=olive>&#x25FC;</font>
    oliveDrab            = Color8(107,142,35),  /// <font color=oliveDrab>&#x25FC;</font>
    orange               = Color8(255,165,0),   /// <font color=orange>&#x25FC;</font>
    orangeRed            = Color8(255,69,0),    /// <font color=orangeRed>&#x25FC;</font>
    orchid               = Color8(218,112,214), /// <font color=orchid>&#x25FC;</font>
    paleGoldenrod        = Color8(238,232,170), /// <font color=paleGoldenrod>&#x25FC;</font>
    paleGreen            = Color8(152,251,152), /// <font color=paleGreen>&#x25FC;</font>
    paleTurquoise        = Color8(175,238,238), /// <font color=paleTurquoise>&#x25FC;</font>
    paleVioletRed        = Color8(219,112,147), /// <font color=paleVioletRed>&#x25FC;</font>
    papayaWhip           = Color8(255,239,213), /// <font color=papayaWhip>&#x25FC;</font>
    peachPuff            = Color8(255,218,185), /// <font color=peachPuff>&#x25FC;</font>
    peru                 = Color8(205,133,63),  /// <font color=peru>&#x25FC;</font>
    pink                 = Color8(255,192,203), /// <font color=pink>&#x25FC;</font>
    plum                 = Color8(221,160,221), /// <font color=plum>&#x25FC;</font>
    powderBlue           = Color8(176,224,230), /// <font color=powderBlue>&#x25FC;</font>
    purple               = Color8(128,0,128),   /// <font color=purple>&#x25FC;</font>
    red                  = Color8(255,0,0),     /// <font color=red>&#x25FC;</font>
    rosyBrown            = Color8(188,143,143), /// <font color=rosyBrown>&#x25FC;</font>
    royalBlue            = Color8(65,105,225),  /// <font color=royalBlue>&#x25FC;</font>
    saddleBrown          = Color8(139,69,19),   /// <font color=saddleBrown>&#x25FC;</font>
    salmon               = Color8(250,128,114), /// <font color=salmon>&#x25FC;</font>
    sandyBrown           = Color8(244,164,96),  /// <font color=sandyBrown>&#x25FC;</font>
    seaGreen             = Color8(46,139,87),   /// <font color=seaGreen>&#x25FC;</font>
    seashell             = Color8(255,245,238), /// <font color=seashell>&#x25FC;</font>
    sienna               = Color8(160,82,45),   /// <font color=sienna>&#x25FC;</font>
    silver               = Color8(192,192,192), /// <font color=silver>&#x25FC;</font>
    skyBlue              = Color8(135,206,235), /// <font color=skyBlue>&#x25FC;</font>
    slateBlue            = Color8(106,90,205),  /// <font color=slateBlue>&#x25FC;</font>
    slateGray            = Color8(112,128,144), /// <font color=slateGray>&#x25FC;</font>
    slateGrey            = Color8(112,128,144), /// <font color=slateGrey>&#x25FC;</font>
    snow                 = Color8(255,250,250), /// <font color=snow>&#x25FC;</font>
    springGreen          = Color8(0,255,127),   /// <font color=springGreen>&#x25FC;</font>
    steelBlue            = Color8(70,130,180),  /// <font color=steelBlue>&#x25FC;</font>
    tan                  = Color8(210,180,140), /// <font color=tan>&#x25FC;</font>
    teal                 = Color8(0,128,128),   /// <font color=teal>&#x25FC;</font>
    thistle              = Color8(216,191,216), /// <font color=thistle>&#x25FC;</font>
    tomato               = Color8(255,99,71),   /// <font color=tomato>&#x25FC;</font>
    turquoise            = Color8(64,224,208),  /// <font color=turquoise>&#x25FC;</font>
    violet               = Color8(238,130,238), /// <font color=violet>&#x25FC;</font>
    wheat                = Color8(245,222,179), /// <font color=wheat>&#x25FC;</font>
    white                = Color8(255,255,255), /// <font color=white>&#x25FC;</font>
    whiteSmoke           = Color8(245,245,245), /// <font color=whiteSmoke>&#x25FC;</font>
    yellow               = Color8(255,255,0),   /// <font color=yellow>&#x25FC;</font>
    yellowGreen          = Color8(154,205,50)   /// <font color=yellowGreen>&#x25FC;</font>
}

