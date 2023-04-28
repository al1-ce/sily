/**
Flexible vector template with some math utils
*/
module sily.vector;

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

/// Alias to vector with set size
alias Vector2(T) = Vector!(T, 2);
/// Ditto
alias Vector3(T) = Vector!(T, 3);
/// Ditto
alias Vector4(T) = Vector!(T, 4);

/// Alias to vector with set size and type
alias Vector2f = Vector2!float;
/// Ditto
alias Vector2d = Vector2!double;
/// Ditto
alias Vector2i = Vector2!int;
/// Ditto
alias Vector2u = Vector2!uint;

/// Ditto
alias Vector3f = Vector3!float;
/// Ditto
alias Vector3d = Vector3!double;
/// Ditto
alias Vector3i = Vector3!int;
/// Ditto
alias Vector3u = Vector3!uint;

/// Ditto
alias Vector4f = Vector4!float;
/// Ditto
alias Vector4d = Vector4!double;
/// Ditto
alias Vector4i = Vector4!int;
/// Ditto
alias Vector4u = Vector4!uint;

/// GLSL style alias
alias vec2 = Vector2f;
/// Ditto
alias vec3 = Vector3f;
/// Ditto
alias vec4 = Vector4f;

/// Ditto
alias dvec2 = Vector2d;
/// Ditto
alias dvec3 = Vector3d;
/// Ditto
alias dvec4 = Vector4d;

/// Ditto
alias ivec2 = Vector2i;
/// Ditto
alias ivec3 = Vector3i;
/// Ditto
alias ivec4 = Vector4i;

/// Ditto
alias uvec2 = Vector2u;
/// Ditto
alias uvec3 = Vector3u;
/// Ditto
alias uvec4 = Vector4u;

/// Vector structure with data accesible with `[N]` or swizzling
struct Vector(T, size_t N) if (isNumeric!T && N > 0)  {
    /// Vector data
    public T[N] data = [ 0 ];

    /// Alias to allow easy `data` access
    alias data this;
    /// Alias to data type (e.g. float, int)
    alias dataType = T;
    /** 
    Alias to vector type. Can be used to contruct vectors
    of same type
    ---
    auto rvec7 = Vector!(real, 7)(10);
    auto rvec7s = rvec7.VecType(20);
    ---
    */
    alias VecType = Vector!(T, N);
    /// Alias to vector size
    enum size_t size = N;

    /**
    Constructs Vector from components. If no components present
    vector will be filled with 0
    Example:
    ---
    // Vector can be constructed manually or with aliases
    auto v1 = Vector!(int, 2)(10, 20);
    auto v2 = ivec2(10, 20);
    auto v3 = Vector2i(10, 20);
    auto v4 = Vector2!int(10, 20);
    // Also vector can be given only one value,
    // in that case it'll be filled with that value
    auto v5 = ivec4(13);
    auto v6 = vec4(0.3f);
    // Vector values can be accessed with array slicing,
    // by using color symbols or swizzling
    float v6x = v6.x;
    float v6z = v6.z;
    float[] v6yzx = v6.yzx;
    float v6y = v6[1];
    // Valid vector accessors are:
    // Vector2 - [x, y], [w, h], [u, v]
    // Vector3 - [x, y, z], [w, h, d], [u, v, t], [r, g, b]
    // Vector4 - [x, y, z, w], [r, g, b, a]
    // Other sizes must be accessed with index
    ---
    */
    this(in T val) {
        foreach (i; 0 .. size) { data[i] = val; }
    }
    /// Ditto
    this(in T[N] vals...) {
        data = vals;
    }

    /* -------------------------------------------------------------------------- */
    /*                         UNARY OPERATIONS OVERRIDES                         */
    /* -------------------------------------------------------------------------- */
    
    /// opBinary x [+, -, *, /, %] y
    VecType opBinary(string op, R)(in Vector!(R, N) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        VecType ret = VecType();
        foreach (i; 0 .. size) { mixin( "ret[i] = data[i] " ~ op ~ " b.data[i];" ); }
        return ret;
    }

    /// Ditto
    VecType opBinaryRight(string op, R)(in Vector!(R, N) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        VecType ret = VecType();
        foreach (i; 0 .. size) { mixin( "ret[i] = b.data[i] " ~ op ~ " data[i];" ); }
        return ret;
    }

    /// Ditto
    VecType opBinary(string op, R)(in R b) const if ( isNumeric!R ) {
        // assert(this !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        VecType ret = VecType();
        foreach (i; 0 .. size) { mixin( "ret[i] = data[i] " ~ op ~ " b;" ); }
        return ret;
    }

    /// Ditto
    VecType opBinaryRight(string op, R)(in R b) const if ( isNumeric!R ) {
        // assert(this !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        VecType ret = VecType();
        foreach (i; 0 .. size) { mixin( "ret[i] = b " ~ op ~ " data[i];" ); }
        return ret;
    }

    /// opEquals x == y
    bool opEquals(R)(in Vector!(R, size) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        bool eq = true;
        foreach (i; 0 .. size) { eq = eq && data[i] == b.data[i]; }
        return eq;
    }

    /// opCmp x [< > <= >=] y
    int opCmp(R)(in Vector!(R, N) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        double al = cast(double) length();
        double bl = cast(double) b.length();
        if (al == bl) return 0;
        if (al < bl) return -1;
        return 1;
    }

    /// opUnary [-, +, --, ++] x
    VecType opUnary(string op)() if(op == "-" || op == "+"){
        // assert(this !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        VecType ret = VecType();
        if (op == "-")
            foreach (i; 0 .. size) { ret[i] = -data[i]; }
        if (op == "+")
            foreach (i; 0 .. size) { ret[i] = data[i]; }
        return ret;
    }
    
    /// opOpAssign x [+, -, *, /, %]= y
    VecType opOpAssign(string op, R)( in Vector!(R, N) b ) if ( isNumeric!R ) { 
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        foreach (i; 0 .. size) { mixin( "data[i] = data[i] " ~ op ~ " b.data[i];" ); }
        return this;
    }
    
    /// Ditto
    VecType opOpAssign(string op, R)( in R b ) if ( isNumeric!R ) { 
        // assert(this !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        foreach (i; 0 .. size) { mixin( "data[i] = data[i] " ~ op ~ " b;" ); }
        return this;
    }

    /// Returns hash 
    size_t toHash() const @safe nothrow {
        return typeid(data).getHash(&data);
    }
    
    static if (N == 2 || N == 3 || N == 4) {
        static if (N == 2) private enum AS = "x y|w h|u v"; 
        else
        static if (N == 3) private enum AS = "x y z|w h d|u v t|r g b"; 
        else
        static if (N == 4) private enum AS = "x y z w|r g b a";
        /// Mixes in swizzle
        mixin accessByString!(T, N, "data", AS);
    }

    /// Returns copy of vector
    public VecType copyof() {
        return VecType(data);
    }

    /// Returns string representation of vector: `[1.00, 1.00,... , 1.00]`
    public string toString() const {
        import std.conv : to;
        string s;
        s ~= "[";
        foreach (i; 0 .. size) {
            s ~= isFloatingPoint!T ? format("%.2f", data[i]) : format("%d", data[i]);
            if (i != size - 1) s ~= ", ";
        }
        s ~= "]";
        return s;
    }

    /// Returns pointer to data
    public T* ptr() return {
        return data.ptr;
    }

    /* -------------------------------------------------------------------------- */
    /*                         STATIC GETTERS AND SETTERS                         */
    /* -------------------------------------------------------------------------- */
    
    /// Constructs predefined vector
    static alias zero  = () => VecType(0);
    /// Ditto
    static alias one   = () => VecType(1);

    static if(isFloatingPoint!T) {
        /// Ditto
        static alias inf   = () => VecType(float.infinity);
    }

    static if(N == 2) {
        /// Ditto
        static alias left  = () => VecType(-1, 0);
        /// Ditto
        static alias right = () => VecType(1, 0);
        /// Ditto
        static alias up    = () => VecType(0, -1);
        /// Ditto
        static alias down  = () => VecType(0, 1);
    }

    static if(N == 3) {
        static alias forward = () => VecType(0, 0, -1);
        /// Ditto
        static alias back    = () => VecType(0, 0, 1);
        /// Ditto
        static alias left    = () => VecType(-1, 0, 0);
        /// Ditto
        static alias right   = () => VecType(1, 0, 0);
        /// Ditto
        static alias up      = () => VecType(0, 1, 0);
        /// Ditto
        static alias down    = () => VecType(0, -1, 0);
    }

    /* -------------------------------------------------------------------------- */
    /*                                    MATH                                    */
    /* -------------------------------------------------------------------------- */
    
    static if(!isFloatingPoint!T) {
        /// Returns vector length
        public double length() const {
            return sqrt(cast(double) lengthSquared);
        }   

        /// Returns squared vector length
        public double lengthSquared() const {
            double l = 0;
            foreach (i; 0 .. size) { l += data[i] * data[i]; }
            return l;
        }

        /** 
        Returns squared distance from vector to `b`
        Params:
          b = Vector to calculate distance to
        Returns: Distance
        */
        public double distanceSquaredTo(VecType b) {
            double dist = 0;
            foreach (i; 0 .. size) { dist += (data[i] - b.data[i]) * (data[i] - b.data[i]); }
            return dist;
        }

        /** 
        Calculates distance to vector `b`
        Params:
          b = Vector
        Returns: Distance
        */
        public double distanceTo(VecType b) {
            return sqrt(distanceSquaredTo(b));
        }
    }


    /* -------------------------------------------------------------------------- */
    /*                             FLOATING POINT MATH                            */
    /* -------------------------------------------------------------------------- */
    // Int math is still might be accessible
    // if I'll need it. All I'd need to do
    // Is to add another `static if` 

    // FLOAT VECTORS
    static if(isFloatingPoint!T) {
        /// Returns vector length
        public T length() const {
            return sqrt(lengthSquared);
        }   

        /// Returns squared vector length
        public T lengthSquared() const {
            T l = 0;
            foreach (i; 0 .. size) { l += data[i] * data[i]; }
            return l;
        }

        /** 
        Returns squared distance from vector to `b`
        Params:
          b = Vector to calculate distance to
        Returns: Distance
        */
        public T distanceSquaredTo(VecType b) {
            T dist = 0;
            foreach (i; 0 .. size) { dist += (data[i] - b.data[i]) * (data[i] - b.data[i]); }
            return dist;
        }

        /** 
        Calculates distance to vector `b`
        Params:
          b = Vector
        Returns: Distance
        */
        public T distanceTo(VecType b) {
            return sqrt(distanceSquaredTo(b));
        }

        /** 
        Is vector approximately close to `v`
        Params:
          v = Vector to compare
        Returns: 
        */
        public bool isClose(VecType v) {
            bool eq = true;
            foreach (i; 0 .. size) { eq = eq && data[i].isClose(v[i], float.epsilon); }
            return eq;
        }

        /// Normalises vector
        public VecType normalized() {
            if (lengthSquared.isClose(0, float.epsilon)) return this;
            VecType ret;
            T l = lengthSquared;
            if (l != 0) {
                l = sqrt(lengthSquared);
                foreach (i; 0 .. size) { ret[i] = data[i] / l; }
            }
            return ret;
        }
        /// Ditto
        alias normalised = normalized;
        
        /// Normalises vector in place
        /// Returns: The length of this vector
        public T normalize() {
            if (lengthSquared.isClose(0, float.epsilon)) return 0;
            T l = lengthSquared;
            if (l != 0) {
                l = sqrt(lengthSquared);
                foreach (i; 0 .. size) { data[i] /= l; }
            }
            return length();
        }
        /// Ditto
        alias normalise = normalize;

        /// Returns true if vector is normalised
        public bool isNormalized() {
            return lengthSquared.isClose(1, float.epsilon);
        }
        /// Ditto
        alias isNormalised = isNormalized;

        /** 
        Performs dot product
        Params:
          b = Vector
        Returns: dot product
        */
        public float dot(VecType b) {
            T d = 0;
            foreach (i; 0 .. size) { d += data[i] * b.data[i]; }
            return d;
        }

        /// Signs current vector
        public VecType sign() {
            VecType ret;
            foreach (i; 0 .. size) { ret[i] = data[i].sgn(); }
            return ret;
        }

        /// Floors vector values
        public VecType floor() {
            VecType ret;
            foreach (i; 0 .. size) { ret[i] = data[i].floor(); }
            return ret;
        }

        /// Ceils vector values
        public VecType ceil() {
            VecType ret;
            foreach (i; 0 .. size) { ret[i] = data[i].ceil(); }
            return ret;
        }

        /// Rounds vector values
        public VecType round() {
            VecType ret;
            foreach (i; 0 .. size) { ret[i] = data[i].round(); }
            return ret;
        }

        /// Abs vector values
        public VecType abs() {
            VecType ret;
            foreach (i; 0 .. size) { ret[i] = data[i].abs(); }
            return ret;
        }

        /** 
        Clamps vector values to min
        Params:
          b = Minimal Vector
        */
        public VecType min(VecType b) {
            VecType ret;
            foreach (i; 0 .. size) { ret[i] = data[i].min(b.data[i]); }
            return ret;
        }

        /** 
        Clamps vector values to max
        Params:
          b = Maximal Vector
        */
        public VecType max(VecType b) {
            VecType ret;
            foreach (i; 0 .. size) { ret[i] = data[i].max(b.data[i]); }
            return ret;
        }
        
        // TODO: clamped?
        /** 
        Clamps vector values
        Params:
          b = Minimal Vector
          b = Maximal Vector
        */
        public VecType clamp(VecType p_min, VecType p_max) {
            VecType ret;
            foreach (i; 0 .. size) { ret[i] = data[i].clamp(p_min.data[i], p_max.data[i]); }
            return ret;
        }
        
        // TODO: snapped?
        /** 
        Snaps vector values
        Params:
          p_step = Vector to snap to
        */
        public VecType snap(VecType p_step) {
            VecType ret;
            foreach (i; 0 .. size) { 
                ret[i] = data[i].snap(p_step[i]);
            }
            return ret;
        }

        // /** 
        // Limits vector length
        // Params:
        //   p_len = Max length
        // */
        // public VecType limitLength(T p_len) {
        //     VecType ret;
        //     T l = length();
        //     if (l > 0 && p_len < l) {
        //         for (int i = 0; i < size; ++i) {
        //             ret[i] = data[i] / l;
        //             ret[i] *= p_len;
        //         }
        //     }
        //     return ret;
        // }

        /** 
        Linear interpolates vector
        Params:
          to = Vector to interpolate to
          weight = Interpolation weight in range [0.0, 1.0]
        */
        public VecType lerp(VecType to, T weight) {
            VecType ret;
            foreach (i; 0 .. size) { ret[i] = data[i] + (weight * (to.data[i] - data[i])); }
            return ret;
        }

        // FIXME
        // TODO
        // it's in math
        // public Vector2!T cubicInterpolate(Vector2!T b, Vector2!T prea, Vector2!T postb, float weight) {
        //     Vector2 res = *this;
        //     res.x = Math::cubic_interpolate(res.x, p_b.x, p_pre_a.x, p_post_b.x, p_weight);
        //     res.y = Math::cubic_interpolate(res.y, p_b.y, p_pre_a.y, p_post_b.y, p_weight);
        //     return res;
        // }
    }

    /* -------------------------------------------------------------------------- */
    /*                                  VECTOR2F                                  */
    /* -------------------------------------------------------------------------- */
    static if(isFloatingPoint!T && N == 2) {
        // public static Vector2!T fromAngle(float p_angle) {
        //     return Vector2!T(cos(p_angle), sin(p_angle));
        // }

        // public float cross(VecType b) {
        //     return this.x * b.y - this.y * b.x;
        // }
        
        // public float angle() {
        //     return atan2(this.y, this.x);
        // }

        // public float angleTo(Vector2!T b) {
        //     return atan2(cross(b), dot(b));
        // }

        // public float angleToPoint(Vector2!T b) {
        //     return (b - data).angle();
        // }

        // public float aspect() {
        //     return this.x / this.y;
        // }

        // public Vector2!T project(Vector2!T b) {
        //     return b * (dot(b) / b.lengthSquared());
        // }

        // public Vector2!T moveToward(Vector2!T p_to, const T p_delta) {
        //     Vector2!T v = copyof();
        //     Vector2!T vd = p_to - v;
        //     T len = vd.length;
        //     return len <= p_delta || len < float.epsilon ? p_to : v + vd / len * p_delta;
        // }

        // public Vector2!T slide(Vector2!T p_normal) {
        //     if (!p_normal.isNormalized) {
        //         writeln("Normal vector must be normalized");
        //         // throw new Error("MATH::ERROR::VECTOR2");
        //         return copyof();
        //     }
        //     return copyof() - p_normal * dot(p_normal);
        // }

        // public Vector2!T bounce(Vector2!T p_normal) {
        //     return -reflect(p_normal);
        // }

        // public Vector2!T reflect(Vector2!T p_normal) {
        //     if (!p_normal.isNormalized) {
        //         writeln("Normal vector must be normalized");
        //         // throw new Error("MATH::ERROR::VECTOR2");
        //         return copyof();
        //     }
        //     return  to!T(2) * p_normal * dot(p_normal) - copyof();
        // }

        // public Vector2!T orthogonal() {
        //     return Vector2!T(this.y, -this.x);
        // }

        // public Vector2!T rotated(float phi) {
        //     T sine = sin(phi);
        //     T cosi = cos(phi);
        //     return Vector2!T(
        //         this.x * cosi - this.y * sine,
        //         this.x * sine + this.y * cosi);
        // }

        // public VecType slerp(VecType to, T weight) {
        //     T stLensq = lengthSquared;
        //     T enLensq = to.lengthSquared;
        //     if (stLensq == 0.0f || enLensq == 0.0f) {
        //         // Zero length vectors have no angle, so the best we can do is either lerp or throw an error.
        //         return lerp(to, weight);
        //     }
        //     T stLen = sqrt(stLensq);
        //     T rsLen = stLen.lerp(sqrt(enLensq), weight);
        //     T angle = angleTo(to);
        //     return rotated(angle * weight) * (rsLen / stLen);
        // }

        // LINK https://glmatrix.net/docs/vec2.js
        // LINK https://github.com/godotengine/godot/blob/master/core/math/vector2.cpp
    }

    /* -------------------------------------------------------------------------- */
    /*                                  VECTOR3F                                  */
    /* -------------------------------------------------------------------------- */
    static if(isFloatingPoint!T && N == 3) {
        // TODO
        // VecType cross(VecType b) {
        //     VecType cr = VecType();            
        //     T ax = data[0],
        //       ay = data[1],
        //       az = data[2];
        //     T bx = b.data[0],
        //       by = b.data[1],
        //       bz = b.data[2];
        //     cr.data[0] = ay * bz - az * by;
        //     cr.data[1] = az * bx - ax * bz;
        //     cr.data[2] = ax * by - ay * bx;
        //     return cr;
        // }

        // TODO

        // LINK https://glmatrix.net/docs/vec3.js.html
        // LINK https://github.com/godotengine/godot/blob/master/core/math/vector3.cpp
    }

    /* -------------------------------------------------------------------------- */
    /*                                  VECTOR4F                                  */
    /* -------------------------------------------------------------------------- */
    // here probably gonna be almost nothing
    // here be dragons?
    static if(isFloatingPoint!T && N == 4) {
        // TODO ?
    }
    
    // Vector2 Vector2::posmod(const real_t p_mod) const {
    //     return Vector2(Math::fposmod(x, p_mod), Math::fposmod(y, p_mod));
    // }

    // Vector2 Vector2::posmodv(const Vector2 &p_modv) const {
    //     return Vector2(Math::fposmod(x, p_modv.x), Math::fposmod(y, p_modv.y));
    // }
}
