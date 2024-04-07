/// Custom templated math
module sily.math;

import std.math;
import std.traits: isFloatingPoint;

// https://github.com/godotengine/godot/blob/master/core/math/math_funcs.cpp

const double degtorad = PI / 180.0;
const double radtodeg = 180.0 / PI;

alias deg2rad = degtorad;
alias rad2deg = radtodeg;

/// Linearly interpolates value
T lerp(T)(T from, T to, T weight) if (isFloatingPoint!T) {
    from += (weight * (to - from));
    return from;
}

/// Snaps value to step
T snap(T)(T p_val, T p_step) if (isFloatingPoint!T) {
    if (p_step != 0) {
        p_val = floor(p_val / p_step + 0.5) * p_step;
    }
    return p_val;
}

/// Snaps value to step, if T is not float, then explicit casts are used
/// and it may cause data loss
T snap(T)(T p_val, T p_step) if (!isFloatingPoint!T) {
    if (p_step != 0) {
        p_val = cast(T) (floor(cast(double) p_val / cast(double) p_step + 0.5) * cast(double) p_step);
    }
    return p_val;
}

// FIXME: cubic_interpolate
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
