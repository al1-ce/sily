// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/// Quaternion
module sily.quat;

import std.math;
import std.numeric;
import std.conv;
import std.traits;
import std.typetuple;
import std.algorithm;
import std.stdio;
import std.string;
import std.format;

import sily.meta.swizzle;
import sily.math;
import sily.array;
import sily.color;
import sily.matrix;
import sily.vector;

alias quat = Quaternion;

/++
Struct repesentation of quaterion
+/
struct Quaternion {
    /// Quat data
    public float[4] data = 0;

    /// Alias to allow easy `data` access
    alias data this;

    /**
    Constructs quaternion from single value or array of values
    */
    this(in float val) {
        foreach (i; 0 .. 4) { data[i] = val; }
    }
    /// Ditto
    this(in float[4] vals...) {
        data = vals;
    }

    /// Construct quaternion from euler angles
    this(in float[3] vals...) {
        float x0 = cos(vals[0] * 0.5f);
        float x1 = sin(vals[0] * 0.5f);
        float y0 = cos(vals[1] * 0.5f);
        float y1 = sin(vals[1] * 0.5f);
        float z0 = cos(vals[2] * 0.5f);
        float z1 = sin(vals[2] * 0.5f);

        data = [
            x1 * y0 * z0 - x0 * y1 * z1,
            x0 * y1 * z0 + x1 * y0 * z1,
            x0 * y0 * z1 - x1 * y1 * z0,
            x0 * y0 * z0 + x1 * y1 * z1
        ];
    }

    /// Constructs quaterion from rotation matrix
    this(in mat4 m) {
        float fW = m[0][0] + m[1][1] + m[2][2];
        float fX = m[0][0] - m[1][1] - m[2][2];
        float fY = m[1][1] - m[0][0] - m[2][2];
        float fZ = m[2][2] - m[0][0] - m[1][1];

        int big = 0;
        float fB = fW;

        if (fX > fB) {
            fB = fX;
            big = 1;
        }
        if (fY > fB) {
            fB = fY;
            big = 2;
        }
        if (fZ > fB) {
            fB = fZ;
            big = 3;
        }

        float bV = sqrt(fB + 1.0) * 0.5f;
        float mult = 0.25f / bV;
        switch (big) {
            case 0:
                data[0] = (m[2][1] - m[1][2]) * mult;
                data[1] = (m[0][2] - m[2][0]) * mult;
                data[2] = (m[1][0] - m[0][1]) * mult;
                data[3] = bV;
            break;
            case 1:
                data[0] = bV;
                data[1] = (m[1][0] + m[0][1]) * mult;
                data[2] = (m[0][2] - m[2][0]) * mult;
                data[3] = (m[2][1] - m[1][2]) * mult;
            break;
            case 2:
                data[0] = (m[1][0] + m[0][1]) * mult;
                data[1] = bV;
                data[2] = (m[2][1] + m[1][2]) * mult;
                data[3] = (m[0][2] - m[2][0]) * mult;
            break;
            case 3:
                data[0] = (m[0][2] + m[2][0]) * mult;
                data[1] = (m[2][1] + m[1][2]) * mult;
                data[2] = bV;
                data[3] = (m[1][0] - m[0][1]) * mult;
            break;
            default: break;
        }
    }

    /// Constructs quaternion from axis angle
    this(vec3 axis, float angle) {
        data = identity().data;
        float axisLen = axis.length;
        if (axisLen != 0.0) {
            angle *= 0.5f;
            if (!axis.isNormalized) axis.normalize();
            float sina = sin(angle);
            float cosa = cos(angle);

            data = [
                axis.x * sina,
                axis.y * sina,
                axis.z * sina,
                cosa
            ];

            normalize();
        }
    }

    /// private size alias
    private enum size = 4;

    /* -------------------------------------------------------------------------- */
    /*                         UNARY OPERATIONS OVERRIDES                         */
    /* -------------------------------------------------------------------------- */

    /// opBinary x [+, -, *, /, %] y
    quat opBinary(string op, R)(in Vector!(R, 4) b) const if ( isNumeric!R ) {
        quat ret;
        foreach (i; 0 .. size) { mixin( "ret[i] = data[i] " ~ op ~ " b.data[i];" ); }
        return ret;
    }

    /// Ditto
    quat opBinaryRight(string op, R)(in Vector!(R, 4) b) const if ( isNumeric!R ) {
        quat ret;
        foreach (i; 0 .. size) { mixin( "ret[i] = b.data[i] " ~ op ~ " data[i];" ); }
        return ret;
    }

    /// opBinary x [+, -, *, /, %] y
    quat opBinary(string op)(in quat b) const if (op == "*") {
        quat q1 = this;
        quat q2 = b;
        return quat(
            q1.x * q2.w + q1.w * q2.x + q1.y * q2.z - q1.z * q2.y,
            q1.y * q2.w + q1.w * q2.y + q1.z * q2.x - q1.x * q2.z,
            q1.z * q2.w + q1.w * q2.z + q1.x * q2.y - q1.y * q2.x,
            q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z
        );
    }

    // /// Ditto
    // quat opBinaryRight(string op)(in quat b) const if (op == "*") {
    //     quat q2 = this;
    //     quat q1 = b;
    //     return quat(
    //         q1.x * q2.w + q1.w * q2.x + q1.y * q2.z - q1.z * q2.y,
    //         q1.y * q2.w + q1.w * q2.y + q1.x * q2.x - q1.x * q2.z,
    //         q1.z * q2.w + q1.w * q2.z + q1.z * q2.y - q1.y * q2.x,
    //         q1.w * q2.w + q1.w * q2.x + q1.y * q2.y - q1.z * q2.z
    //     );
    // }

    /// Ditto
    quat opBinary(string op)(in quat b) const if ( op != "*" ) {
        quat ret;
        foreach (i; 0 .. size) { mixin( "ret[i] = data[i] " ~ op ~ " b.data[i];" ); }
        return ret;
    }

    // /// Ditto
    // quat opBinaryRight(string op)(in quat b) const if ( op != "*" ) {
    //     quat ret;
    //     foreach (i; 0 .. size) { mixin( "ret[i] = b.data[i] " ~ op ~ " data[i];" ); }
    //     return ret;
    // }

    /// Ditto
    quat opBinary(string op, R)(in R b) const if ( isNumeric!R ) {
        quat ret;
        foreach (i; 0 .. size) { mixin( "ret[i] = data[i] " ~ op ~ " b;" ); }
        return ret;
    }

    /// Ditto
    quat opBinaryRight(string op, R)(in R b) const if ( isNumeric!R ) {
        quat ret;
        foreach (i; 0 .. size) { mixin( "ret[i] = b " ~ op ~ " data[i];" ); }
        return ret;
    }

    /// opEquals x == y
    bool opEquals(R)(in Vector!(R, size) b) const if ( isNumeric!R ) {
        bool eq = true;
        foreach (i; 0 .. size) {
            eq = eq && data[i] == b.data[i];
            if (!eq) break;
        }
        return eq;
    }

    /// Ditto
    bool opEquals()(in quat b) const {
        bool eq = true;
        foreach (i; 0 .. size) {
            eq = eq && data[i] == b.data[i];
            if (!eq) break;
        }
        return eq;
    }

    /// opCmp x [< > <= >=] y
    int opCmp(R)(in Vector!(R, size) b) const if ( isNumeric!R ) {
        double al = cast(double) length();
        double bl = cast(double) b.length();
        if (al == bl) return 0;
        if (al < bl) return -1;
        return 1;
    }

    int opCmp()(in quat b) const {
        double al = cast(double) length();
        double bl = cast(double) b.length();
        if (al == bl) return 0;
        if (al < bl) return -1;
        return 1;
    }

    /// opUnary [-, +, --, ++] x
    quat opUnary(string op)() if (op == "-" || op == "+") {
        quat ret;
        if (op == "-")
            foreach (i; 0 .. size) { ret[i] = -data[i]; }
        if (op == "+")
            foreach (i; 0 .. size) { ret[i] = data[i]; }
        return ret;
    }

    /// Invert quaternion
    quat opUnary(string op)() if (op == "~") {
        quat ret = data;
        double len = lengthSquared;
        if (len != 0) {
            len = 1.0 / len;
            ret[0] *= -len;
            ret[1] *= -len;
            ret[2] *= -len;
            ret[3] *= len;
        }
        return ret;
    }

    /// opOpAssign x [+, -, *, /, %]= y
    quat opOpAssign(string op, R)( in Vector!(R, 4) b ) if ( isNumeric!R ) {
        foreach (i; 0 .. size) { mixin( "data[i] = data[i] " ~ op ~ " b.data[i];" ); }
        return this;
    }

    quat opOpAssign(string op)( in quat b ) {
        foreach (i; 0 .. size) { mixin( "data[i] = data[i] " ~ op ~ " b.data[i];" ); }
        return this;
    }

    /// Ditto
    VecType opOpAssign(string op, R)( in R b ) if ( isNumeric!R ) {
        foreach (i; 0 .. size) { mixin( "data[i] = data[i] " ~ op ~ " b;" ); }
        return this;
    }

    /// opCast cast(x) y
    R opCast(R)() const if (isVector!(R, 4) && isFloatingPoint!(R.dataType)) {
        R ret;
        foreach (i; 0 .. size) {
            ret[i] = cast(R.dataType) data[i];
        }
        return ret;
    }

    // /// Cast to matrix (column/row matrix)
    // R opCast(R)() const if (isMatrix!(R, N, 1)) {
    //     R ret;
    //     foreach (i; 0 ..  N) {
    //         ret[i][0] = cast(R.dataType) data[i];
    //     }
    //     return ret;
    // }
    //
    // /// Ditto
    // R opCast(R)() const if (isMatrix!(R, 1, N)) {
    //     R ret;
    //     foreach (i; 0 ..  N) {
    //         ret[0][i] = cast(R.dataType) data[i];
    //     }
    //     return ret;
    // }

    /// Cast to bool
    bool opCast(T)() const if (is(T == bool)) {
        return !lengthSquared.isClose(0, float.epsilon);
    }

    /// Returns hash
    size_t toHash() const @safe nothrow {
        return typeid(data).getHash(&data);
    }

    private enum AS = "x y z w";
    /// Mixes in swizzle
    mixin accessByString!(float, 4, "data", AS);

    /// Returns copy of quaterion
    public quat copyof() {
        return quat(data);
    }

    /// Returns string representation of quaternion: `[1.00, 1.00,... , 1.00]`
    public string toString() const {
        import std.conv : to;
        string s;
        s ~= "[";
        foreach (i; 0 .. size) {
            s ~= format("%.2f", data[i]);
            if (i != size - 1) s ~= ", ";
        }
        s ~= "]";
        return s;
    }

    /// Returns pointer to data
    public float* ptr() return {
        return data.ptr;
    }

    /* -------------------------------------------------------------------------- */
    /*                         STATIC GETTERS AND SETTERS                         */
    /* -------------------------------------------------------------------------- */

    /// Constructs quaternion identity
    static alias identity = () => quat(0, 0, 0, 1);

    /* -------------------------------------------------------------------------- */
    /*                                    MATH                                    */
    /* -------------------------------------------------------------------------- */

    /// Returns quaternion length
    public double length() const {
        return sqrt(cast(double) lengthSquared);
    }

    /// Returns squared quaternion length
    public float lengthSquared() const {
        float l = 0;
        foreach (i; 0 .. size) { l += data[i] * data[i]; }
        return l;
    }

    /**
    Is quaternion approximately close to `v`
    Params:
      v = Quaternion to compare
    Returns:
    */
    public bool isClose(quat v) {
        bool eq = true;
        foreach (i; 0 .. size) { eq = eq && data[i].isClose(v[i], float.epsilon); }
        return eq;
    }

    /// Normalises quaternion
    public quat normalized() {
        double len = length();
        if (len == 0.0) len = 1.0;
        double ilen = 1.0 / len;
        quat ret;
        foreach (i; 0..size) {
            ret[i] = data[i] * ilen;
        }
        return ret;
    }

    /// Ditto
    alias normalised = normalized;

    /// Normalises quaternion in place
    public quat normalize() {
        double len = length();
        if (len == 0.0) len = 1.0;
        double ilen = 1.0 / len;
        foreach (i; 0..size) {
            data[i] = data[i] * ilen;
        }
        return this;
    }
    /// Ditto
    alias normalise = normalize;

    /**
    Linearly interpolates quaternion
    Params:
      to = Quaternion to interpolate to
      weight = Interpolation weight in range [0.0, 1.0]
    */
    public quat lerp(quat to, double weight) {
        quat ret;
        foreach (i; 0 .. size) { ret[i] = data[i] + (weight * (to.data[i] - data[i])); }
        return ret;
    }

    /// Normalized lerp
    public quat nlerp(quat to, double weight) {
        quat ret = lerp(to, weight);
        ret.normalize();
        return ret;
    }

    /// Spherically interpolates quaternion
    public quat slerp(quat to, double weight) {
        double d = dot(to);

        if (d < 0.0) {
            d = -d;
            to = -to;
        }

        if (abs(d) >= 1.0) {
            return this;
        } else
        if (d > 0.95) {
            return nlerp(to, weight);
        } else {
            float hth = acos(d);
            float sht = sqrt(1.0 - d * d);
            if (abs(sht) < 0.001) {
                return quat(
                    data[0] * 0.5 + to.data[0] * 0.5,
                    data[1] * 0.5 + to.data[1] * 0.5,
                    data[2] * 0.5 + to.data[2] * 0.5,
                    data[3] * 0.5 + to.data[3] * 0.5
                );
            } else {
                float ra = sin( (1.0 - weight) * hth ) / sht;
                float rb = sin( weight * hth ) / sht;
                return quat(
                    data[0] * ra + to.data[0] * rb,
                    data[1] * ra + to.data[1] * rb,
                    data[2] * ra + to.data[2] * rb,
                    data[3] * ra + to.data[3] * rb
                );

            }
        }
    }

    /// Calculates quaternion based on rotation between from and to
    public static quat rotation(vec3 from, vec3 to) {
        quat ret = 0;
        double d = from.dot(to);
        vec3 cr = from.cross(to);

        ret = [cr.x, cr.y, cr.z, 1.0 + d];
        ret.normalize();
        return ret;
    }

    /// Returns rotation angle and axis
    public void axisAngle(out vec3 axis, out float angle) {
        if (abs(data[3]) > 1.0f) {
            normalize();
        }

        vec3 rx = 0;
        float ra = 2.0f * cos(data[3]);
        float den = sqrt(1.0f - data[3] * data[3]);

        if (den > 0.0001f) {
            rx = [data[0] / den, data[1] / den, data[2] / den];
        } else {
            rx = [1.0, 0, 0];
        }
        axis = rx;
        angle = ra;
    }

    /**
    Performs dot product
    Params:
      b = Quaternion
    Returns: dot product
    */
    public double dot(quat b) {
        double d = 0;
        foreach (i; 0 .. size) { d += cast(double) data[i] * cast(double) b.data[i]; }
        return d;
    }

    /// Calculates angle between two quaternions
    public double angle(quat b) {
        return acos(dot(b));
    }

}



