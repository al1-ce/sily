module sily.math;

import std.math;
import std.random;
import std.algorithm.comparison;
import std.conv;
import std.traits;

// https://github.com/godotengine/godot/blob/master/core/math/math_funcs.cpp

// float degToRad(float deg) {
//     return deg * (PI / 180.0f);
// }

// float radToDeg(float rad) {
//     return rad * (180.0f / PI);
// }

// alias deg2rad = degToRad;
// alias rad2deg = radToDeg;

alias lerp = lerpT!float;
alias lerp = lerpT!real;
alias lerp = lerpT!double;

T lerpT(T: float)(T from, T to, T weight) {
    from += (weight * (to - from));
    return from;
}

alias snapped = snappedT!float;
alias snapped = snappedT!real;
alias snapped = snappedT!double;

T snappedT(T: float)(T p_val, T p_step) {
    if (p_step != 0) {
        p_val = floor(p_val / p_step + 0.5) * p_step;
    }
    return p_val;
}

class RNG {
    private Random _rnd;
    private uint _seed;
    private ulong _calls;

    this() { this(RNG.defaultSeed); }

    this(uint p_seed) {
        _seed = p_seed;
        _rnd = Random(_seed);
    }

    public void randomize() {
        _seed = randomSeed;
        setSeed(_seed);
    }
    alias randomise = randomize;

    public void setSeed(uint p_seed) {
        _seed = p_seed;
        _rnd.seed(_seed);
    }

    public uint seed() { return _seed; }

    public static alias defaultSeed = Random.defaultSeed;
    public static alias randomSeed = unpredictableSeed;

    alias randf = randT!float;
    alias randr = randT!real;
    alias randd = randT!double;
    alias randi = randT!int;
    alias randl = randT!long;

    template randT(T: float) {
        static if(isFloatingPoint!T) {
            T randT() {
                return random / _rnd.max.to!T;
            }

            T randT(T min, T max) {
                return min + (randT!T * (max - min));
            }
        } else {
            T randT() {
                return (randr * T.max).to!T;
            }

            T randT(T min, T max) {
                return round(min + (randr * (max - min))).to!T;
            }
        }
    }

    public uint random() {
        uint r = _rnd.front;
        skip();
        return r;
    }

    public void skip() {
        _rnd.popFront();
        _calls ++;
    }

    public void skipTo(ulong numCalls) {
        while(_calls < numCalls) {
            skip();
        }
    }
}

// FIXME cubic_interpolate
/*
static _ALWAYS_INLINE_ float cubic_interpolate(float p_from, float p_to, float p_pre, float p_post, float p_weight) {
    return 0.5f *
            ((p_from * 2.0f) +
                    (-p_pre + p_to) * p_weight +
                    (2.0f * p_pre - 5.0f * p_from + 4.0f * p_to - p_post) * (p_weight * p_weight) +
                    (-p_pre + 3.0f * p_from - 3.0f * p_to + p_post) * (p_weight * p_weight * p_weight));
}

static _ALWAYS_INLINE_ float lerp_angle(float p_from, float p_to, float p_weight) {
    float difference = fmod(p_to - p_from, (float)Math_TAU);
    float distance = fmod(2.0f * difference, (float)Math_TAU) - difference;
    return p_from + distance * p_weight;
}

static _ALWAYS_INLINE_ float smoothstep(float p_from, float p_to, float p_s) {
    if (is_equal_approx(p_from, p_to)) {
        return p_from;
    }
    float s = CLAMP((p_s - p_from) / (p_to - p_from), 0.0f, 1.0f);
    return s * s * (3.0f - 2.0f * s);
}
static _ALWAYS_INLINE_ double wrapf(double value, double min, double max) {
    double range = max - min;
    return is_zero_approx(range) ? min : value - (range * Math::floor((value - min) / range));
}
*/