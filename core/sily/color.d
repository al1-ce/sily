module sily.color;

import std.algorithm : canFind;
import std.algorithm.comparison;
import std.array : replace;
import std.conv;
import std.math;
import std.regex;
import std.stdio;
import std.string;
import std.uni : toLower;
import std.traits: isNumeric;

import sily.vector;
import sily.meta;
import sily.array;

alias col = Color;

struct Color {
    public float[4] data = fill!float(1, 4);

    alias data this;
    alias arrayof = data;

    this(in float val) {
        foreach (i; 0 .. 4) { data[i] = val; }
    }

    this(in float r, in float g, in float b) {
        data = [r, g, b, 1];
    }

    this(in float[4] vals...) {
        data = vals;
    }


    /* -------------------------------------------------------------------------- */
    /*                         UNARY OPERATIONS OVERRIDES                         */
    /* -------------------------------------------------------------------------- */
    
    // opBinary x [+, -, *, /, %] y
    auto opBinary(string op, R)(in Color!(R, N) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        VecType ret = VecType();
        foreach (i; 0 .. 4) { mixin( "ret.data[i] = data[i] " ~ op ~ " b.data[i];" ); }
        return ret;
    }

    // opBinaryRight y [+, -, *, /, %] x
    auto opBinaryRight(string op, R)(in Color!(R, N) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        VecType ret = VecType();
        foreach (i; 0 .. 4) { mixin( "ret[i] = b.data[i] " ~ op ~ " data[i];" ); }
        return ret;
    }

    auto opBinary(string op, R)(in R b) const if ( isNumeric!R ) {
        // assert(this !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        VecType ret = VecType();
        foreach (i; 0 .. 4) { mixin( "ret.data[i] = data[i] " ~ op ~ " b;" ); }
        return ret;
    }

    auto opBinaryRight(string op, R)(in R b) const if ( isNumeric!R ) {
        // assert(this !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        VecType ret = VecType();
        foreach (i; 0 .. 4) { mixin( "ret[i] = b " ~ op ~ " data[i];" ); }
        return ret;
    }

    // opEquals x == y
    bool opEquals(R)(in Color!(R, 4) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        bool eq = true;
        foreach (i; 0 .. 4) { eq = eq && data[i] == b.data[i]; }
        return eq;
    }

    // opCmp x [< > ==] y
    int opCmp(R)(in Color!(R, N) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        float al = length;
        float bl = b.length;
        if (al == bl) return 0;
        if (al < bl) return -1;
        return 1;
    }

    // opUnary [-, +, --, ++] x
    auto opUnary(string op)() if(op == "-"){
        // assert(this !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        VecType ret = VecType();
        if (op == "-")
            foreach (i; 0 .. 4) { ret.data[i] = -data[i]; }
        return ret;
    }
    
    // opOpAssign x [+, -, *, /, %]= y
    auto opOpAssign(string op, R)( in Color!(R, N) b ) if ( isNumeric!R ) { 
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        foreach (i; 0 .. 4) { mixin( "data[i] = data[i] " ~ op ~ " b.data[i];" ); }
        return this;
    }
    
    auto opOpAssign(string op, R)( in R b ) if ( isNumeric!R ) { 
        // assert(this !is null, "\nOP::ERROR nullptr Color!" ~ 4.to!string ~ ".");
        foreach (i; 0 .. 4) { mixin( "data[i] = data[i] " ~ op ~ " b;" ); }
        return this;
    }

    size_t toHash() const @nogc @safe pure nothrow {
        float s = 0;
        foreach (i; 0 .. 4) { s += data[i]; }
        return cast(size_t) s;
    }
    
    // incredible magic from terramatter.meta.meta
    // idk how it works but it works awesome
    // and im not going to touch it at all
    enum AccessString = "r g b a";
    mixin accessByString!(float, 4, "data", AccessString);
    

    public Vector4f asVector4f() {
        return Vector4f(data);
    }

    public Vector3f asVector3f() {
        return Vector3f(data[0..3]);
    }

    public Color copyof() {
        return Color(data);
    }

    public string toString() const {
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

    /* -------------------------------------------------------------------------- */
    /*                                 PROPERTIES                                 */
    /* -------------------------------------------------------------------------- */

    public void invert() {
        data[0] = 1.0f - data[0];
        data[1] = 1.0f - data[1];
        data[2] = 1.0f - data[2];
        data[3] = 1.0f - data[3];
    }

    public Color inverted() {
        Color col = Color(data);
        col.invert();
        return col;
    }

    public float luminance() {
        return 0.2126f * data[0] + 0.7152f * data[1] + 0.0722f * data[2];
    }

	public Color lerp(const Color p_to, float p_weight) {
		Color res = copyof();
		res.data[0] += (p_weight * (p_to.data[0] - data[0]));
		res.data[1] += (p_weight * (p_to.data[1] - data[1]));
		res.data[2] += (p_weight * (p_to.data[2] - data[2]));
		res.data[3] += (p_weight * (p_to.data[3] - data[3]));
		return res;
	}

	public Color darkened(float p_amount) {
		Color res = copyof();
		res.data[0] = res.data[0] * (1.0f - p_amount);
		res.data[1] = res.data[1] * (1.0f - p_amount);
		res.data[2] = res.data[2] * (1.0f - p_amount);
		return res;
	}

	public Color lightened(float p_amount) {
		Color res = copyof();
		res.data[0] = res.data[0] + (1.0f - res.data[0]) * p_amount;
		res.data[1] = res.data[1] + (1.0f - res.data[1]) * p_amount;
		res.data[2] = res.data[2] + (1.0f - res.data[2]) * p_amount;
		return res;
	}

    private alias fClamp = (T, M, A) => clamp(to!float(T), to!float(M), to!float(A));

    Color clamped() {
        this.r = fClamp(this.r, 0, 1);
        this.g = fClamp(this.g, 0, 1);
        this.b = fClamp(this.b, 0, 1);
        return this;
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

    // public uint toargb32() { return tocolbit(8, 3, 0, 1, 2); }
    // public uint toabgr32() { return tocolbit(8, 3, 2, 1, 0); }
    // public uint torgba32() { return tocolbit(8, 0, 1, 2, 3); }
    // public uint toargb64() { return tocolbit(16, 3, 0, 1, 2); }
    // public uint toabgr64() { return tocolbit(16, 3, 2, 1, 0); }
    // public uint torgba64() { return tocolbit(16, 0, 1, 2, 3); }

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

    public string toHTML(bool p_alpha) const {
        string txt;
        txt ~= _to_hex(data[0]);
        txt ~= _to_hex(data[1]);
        txt ~= _to_hex(data[2]);
        if (p_alpha) {
            txt ~= _to_hex(data[3]);
        }
        return txt;
    }

    public uint toHex() {
        int r = rint(data[0] * 255);
        int g = rint(data[1] * 255);
        int b = rint(data[2] * 255);
        return ((r & 0xff) << 16) + ((g & 0xff) << 8) + (b & 0xff);
    }

    /* -------------------------------------------------------------------------- */
    /*                                   SETTERS                                  */
    /* -------------------------------------------------------------------------- */

    private void setHex(uint p_hex, uint c_mask, uint c_bits, bool c_hasAlpha) {
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

        data = [r, g, b, a];
    }

    public void setHex(uint p_hex, bool p_hasAlpha = false) { setHex(p_hex, 0xFF, 8, p_hasAlpha); }
    // public void setHex64(uint p_hex, bool p_hasAlpha = false) { setHex(p_hex, 0xFFFF, 16, p_hasAlpha); }

    public void setFromName(string name) {
        name = name.replace(" ", "");
        name = name.replace("-", "");
        name = name.replace("_", "");
        name = name.replace("'", "");
        name = name.replace(".", "");
        name = name.toLower();

        if (_colorStringValues.keys.canFind(name)) {
            setHex(_colorStringValues[name], false);
        } else {
            writefln("Cannot find matching color for '%s'.", name);
        }
    }

    public void setHSV(float p_h, float p_s, float p_v, float p_alpha) {
        int i;
        float f, p, q, t;
        data[3] = p_alpha;

        if (p_s == 0) {
            // Achromatic (grey)
            data[0] = data[1] = data[2] = p_v;
            return;
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
                data[0] = p_v;
                data[1] = t;
                data[2] = p;
                break;
            case 1: // Green is the dominant color
                data[0] = q;
                data[1] = p_v;
                data[2] = p;
                break;
            case 2:
                data[0] = p;
                data[1] = p_v;
                data[2] = t;
                break;
            case 3: // Blue is the dominant color
                data[0] = p;
                data[1] = q;
                data[2] = p_v;
                break;
            case 4:
                data[0] = t;
                data[1] = p;
                data[2] = p_v;
                break;
            default: // (5) Red is the dominant color
                data[0] = p_v;
                data[1] = p;
                data[2] = q;
                break;
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                               STATIC GETTERS                               */
    /* -------------------------------------------------------------------------- */

    public static Color fromName(string name) {
        Color col = Color();
        col.setFromName(name);
        return col;
    }

    public static Color fromHex(uint hex) {
        Color col = Color();
        col.setHex(hex);
        return col;
    }

    public static Color fromHex(string hex) {
        auto rg = regex(r"/^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i");
        auto m = matchAll(hex, rg);
        m.popFront();
        float _r = to!int(m.front.hit, 16) / 255; m.popFront();
        float _g = to!int(m.front.hit, 16) / 255; m.popFront();
        float _b = to!int(m.front.hit, 16) / 255; m.popFront();
        return Color(to!float(_r), to!float(_g), to!float(_b));
    }

    /* -------------------------------------------------------------------------- */
    /*                               HSV PROPERTIES                               */
    /* -------------------------------------------------------------------------- */

    public float hue() const {
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

    public float saturation() const {
        float cmin = data[0].min(data[1]);
        cmin = cmin.min(data[2]);
        float cmax = data[0].max(data[1]);
        cmax = cmax.min(data[2]);

        float delta = cmax - cmin;

        return (cmax != 0) ? (delta / cmax) : 0;
    }

    public float value() const {
        float cmax = data[0].max(data[1]);
        cmax = cmax.max(data[2]);
        return cmax;
    }

    /* -------------------------------------------------------------------------- */
    /*                                BASH GETTERS                                */
    /* -------------------------------------------------------------------------- */

    static Color fromAnsi8(int ansi) {
        if (ansi > 100) ansi -= 92;
        if (ansi > 90) ansi -= 82;
        if (ansi > 40) ansi -= 40;
        if (ansi > 30) ansi -= 30;
        if (ansi >= lowHEX.length) ansi = lowHEX.length.to!int - 1;
        if (ansi < 0) ansi = 0;
        // write(ansi);
        return fromHex(lowHEX[ansi]);
    }

    static Color fromAnsi(int ansi) {
        if (ansi < 0 || ansi > 255) return Color(0, 0, 0);
        if (ansi < 16) return Color.fromHex(Color.lowHEX[ansi]);

        if (ansi > 231) {
            const int s = (ansi - 232) * 10 + 8;
            return Color(s, s, s);
        }

        const int n = ansi - 16;
        int _b = n % 6;
        int _g = (n - _b) / 6 % 6;
        int _r = (n - _b - _g * 6) / 36 % 6;
        _b = _b ? _b * 40 + 55 : 0;
        _r = _r ? _r * 40 + 55 : 0;
        _g = _g ? _g * 40 + 55 : 0;

        return Color(_r / 255.0, _g / 255.0, _b / 255.0);
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
        return sqrt((2 + rmean / 256) * r * r + 4 * g * g + (2 + (255 - rmean) / 256) * b * b + 0.0f);
    }
    
    int toAnsi8(bool isBackground = false) {
        /*
        * 39 - default foreground, 49 - default backgound
        * Main colors are from 30 - 39, light variant is 90 - 97.
        * 97 is white, 30 is black. to get background - add 10 to color code
        * goes like:
        * black, red, green, yellow, blue, magenta, cyan, lgray
        * then repeat with lighter variation
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

    int toAnsi() {
        /*
        * 256 ANSI color coding is:
        * 0 - 14 Special colors, probably check by hand
        * goes like:
        * black, red, green, yellow, blue, magenta, cyan, lgray
        * then repeat with lighter variation
        * 16 - 231 RGB colors with color coding like this:
        * Pure R component is on 16, 52, 88, 124, 160, 196. Aka map(r, comp)
        * B component is r +0..5
        * G component is rb +0,6,12,18,24,30 (but not 36 coz it's next red)
        * in end rgb coding, considering mcol = floor(col*5)
        * rgbansi = 16 + (16 * r) + (6 * g) + b;
        * 232 - 255 Grayscale from dark to light
        * refer to https://misc.flogisoft.com/_media/bash/colors_format/256-colors.sh-v2.png
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

    string toAnsi8String(bool isBackground = false) {
        return "\033[" ~ toAnsi8(isBackground).to!string ~ "m";
    }

    string toAnsiString(bool isBackground = false) {
        return (isBackground ? "\033[48;5;" : "\033[38;5;") ~ 
            toAnsi().to!string ~ "m";
    }

    string toTrueColorString(bool isBackground = false) {
        return (isBackground ? "\033[48;2;" : "\033[38;2;") ~ 
            rint(data[0] * 255).to!string ~ ";" ~ 
            rint(data[1] * 255).to!string ~ ";"  ~ 
            rint(data[2] * 255).to!string  ~ "m";
        
    }


    // TODO add colours from godot
    // LINK https://github.com/godotengine/godot/blob/master/core/math/color.cpp
    static this() {
        _colorStringValues = [
            "white": 0xffffff,
            "black": 0x000000,
            "red": 0xff0000,
            "green": 0x00ff00,
            "blue": 0x0000ff
        ];
    }
    
    static const uint[] lowHEX = [
    0x000000, 0x800000, 0x008000, 0x808000, 0x000080, 0x800080, 0x008080, 0xc0c0c0,
    0x808080, 0xff0000, 0x00ff00, 0xffff00, 0x0000ff, 0xff00ff, 0x00ffff, 0xffffff
    ];

    static const ushort[] lowRGB = [
        0, 0, 0,  128, 0, 0,  0, 128, 0,  128, 128, 0,  0, 0, 128,  128, 0, 128,  0, 128, 128,  192, 192, 192,
        128, 128, 128,  255, 0, 0,  0, 255, 0,  255, 255, 0,  0, 0, 255,  255, 0, 255,  0, 255, 255,  255, 255, 255
    ];

    private static uint[string] _colorStringValues;
}
