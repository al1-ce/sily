module sily.color;

import std.math;
import std.algorithm.comparison;
import std.algorithm: canFind;
import std.conv;
import std.string;
import std.uni: toLower;
import std.array: replace;
import std.stdio;

import sily.vector;
import sily.meta;

alias col = Color;

struct Color {
    public float[4] data;

    alias data this;
    alias arrayof = data;

    this(in float val) {
        foreach (i; 0 .. 4) { data[i] = val; }
    }

    this(in float[4] vals...) {
        data = vals;
    }
    
    // incredible magic from terramatter.meta.meta
    // idk how it works but it works awesome
    // and im not going to touch it at all
    enum AccessString = "r g b a";
    mixin accessByString!(4, float, "data", AccessString);
    

    public Vector4f toVec4() {
        return Vector4f(data);
    }

    public Color copyof() {
        return Color(data);
    }

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

    public uint tocolbit(uint c_bits, int[4] c_order ...) {
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

    public uint toargb32() { return tocolbit(8, 3, 0, 1, 2); }
    public uint toabgr32() { return tocolbit(8, 3, 2, 1, 0); }
    public uint torgba32() { return tocolbit(8, 0, 1, 2, 3); }
    public uint toargb64() { return tocolbit(16, 3, 0, 1, 2); }
    public uint toabgr64() { return tocolbit(16, 3, 2, 1, 0); }
    public uint torgba64() { return tocolbit(16, 0, 1, 2, 3); }

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

    public string tohtml(bool p_alpha) const {
        string txt;
        txt ~= _to_hex(data[0]);
        txt ~= _to_hex(data[1]);
        txt ~= _to_hex(data[2]);
        if (p_alpha) {
            txt ~= _to_hex(data[3]);
        }
        return txt;
    }

    public void sethex(uint p_hex, uint c_mask, uint c_bits, bool c_hasAlpha) {
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

    public void sethex32(uint p_hex, bool p_hasAlpha = true) { return sethex(p_hex, 0xFF, 8, p_hasAlpha); }
    public void sethex64(uint p_hex, bool p_hasAlpha = true) { return sethex(p_hex, 0xFFFF, 16, p_hasAlpha); }

    public void setFromString(string name) {
        name = name.replace(" ", "");
        name = name.replace("-", "");
        name = name.replace("_", "");
        name = name.replace("'", "");
        name = name.replace(".", "");
        name = name.toLower();

        if (_colorStringValues.keys.canFind(name)) {
            sethex32(_colorStringValues[name], false);
        } else {
            writefln("Cannot find matching color for '%s'.", name);
        }
    }

    public static Color fromString(string name) {
        Color col = Color();
        col.setFromString(name);
        return col;
    }

    public float getHue() const {
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

    public float getSaturation() const {
        float cmin = data[0].min(data[1]);
        cmin = cmin.min(data[2]);
        float cmax = data[0].max(data[1]);
        cmax = cmax.min(data[2]);

        float delta = cmax - cmin;

        return (cmax != 0) ? (delta / cmax) : 0;
    }

    public float getValue() const {
        float cmax = data[0].max(data[1]);
        cmax = cmax.max(data[2]);
        return cmax;
    }

    public void sethsv(float p_h, float p_s, float p_v, float p_alpha) {
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

    private static uint[string] _colorStringValues;
}
