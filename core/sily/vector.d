/**
Flexible vector template with some math utils.

By default defines glsl style aliases
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
import sily.color;
import sily.matrix;
import sily.quat;

/// GLSL style alias
alias vec(T, size_t N) = Vector!(T, N);
/// Ditto
alias vec(size_t N) = Vector!(float, N);
/// Ditto
alias vec2 = vec!2;
/// Ditto
alias vec3 = vec!3;
/// Ditto
alias vec4 = vec!4;

/// Ditto
alias dvec(size_t N) = Vector!(double, N);
/// Ditto
alias dvec2 = dvec!2;
/// Ditto
alias dvec3 = dvec!3;
/// Ditto
alias dvec4 = dvec!4;

/// Ditto
alias ivec(size_t N) = Vector!(int, N);
/// Ditto
alias ivec2 = ivec!2;
/// Ditto
alias ivec3 = ivec!3;
/// Ditto
alias ivec4 = ivec!4;

/// Ditto
alias uvec(size_t N) = Vector!(uint, N);
/// Ditto
alias uvec2 = uvec!2;
/// Ditto
alias uvec3 = uvec!3;
/// Ditto
alias uvec4 = uvec!4;

/++
Vector structure with data accesible with `[N]` or swizzling.

All operations on Vector (*, +, /, -, etc...) are scalar.

Allows casting to sily.color or sily.matrix.
+/
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
    auto v2 = ivec2(10, 20);
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

    static if (N == 3 && isFloatingPoint!T) {
        /// Construct euler vector from quaternion
        this(in T[4] vals...) {
            T x0 = 2.0 * (vals[3] * vals[0] + vals[1] * vals[2]);
            T x1 = 1.0 - 2.0 * (vals[0] * vals[0] + vals[1] * vals[1]);

            T y0 = 2.0 * (vals[3] * vals[1] - vals[2] * vals[0]);
            y0 = y0.clamp(-1.0, 1.0);

            T z0 = 2.0 * (vals[3] * vals[2] + vals[0] * vals[1]);
            T z1 = 1.0 - 2.0 * (vals[1] * vals[1] + vals[2] * vals[2]);

            data = [
                atan2(x0, x1),
                asin(y0),
                atan2(z0, z1)
            ];
        }
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
        VecType ret;
        foreach (i; 0 .. size) { mixin( "ret[i] = b " ~ op ~ " data[i];" ); }
        return ret;
    }

    /// opEquals x == y
    bool opEquals(R)(in Vector!(R, size) b) const if ( isNumeric!R ) {
        // assert(/* this !is null && */ b !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        bool eq = true;
        foreach (i; 0 .. size) {
            eq = eq && data[i] == b.data[i];
            if (!eq) break;
        }
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
    VecType opUnary(string op)() if (op == "-" || op == "+") {
        // assert(this !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        VecType ret;
        if (op == "-")
            foreach (i; 0 .. size) { ret[i] = -data[i]; }
        if (op == "+")
            foreach (i; 0 .. size) { ret[i] = data[i]; }
        return ret;
    }

    /// Invert vector
    VecType opUnary(string op)() if (op == "~" && isFloatingPoint!T) {
        // assert(this !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        VecType ret;
        foreach (i; 0 .. size) { ret[i] = 1.0 / data[i]; }
        return ret;
    }

    /// Ditto
    dvec!N opUnary(string op)() if (op == "~" && !isFloatingPoint!T) {
        // assert(this !is null, "\nOP::ERROR nullptr Vector!" ~ size.to!string ~ ".");
        dvec!N ret;
        foreach (i; 0 .. size) { ret[i] = 1.0 / data[i]; }
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

    // TODO: opAssign?

    /// opCast cast(x) y
    R opCast(R)() const if (isVector!(R, N) && R.size == N){
        R ret;
        foreach (i; 0 ..  N) {
            ret[i] = cast(R.dataType) data[i];
        }
        return ret;
    }

    /// Ditto
    R opCast(R)() const if (is(R == quat) && N == 4){
        R ret;
        foreach (i; 0 ..  N) {
            ret[i] = cast(float) data[i];
        }
        return ret;
    }

    /// Cast to matrix (column/row matrix)
    R opCast(R)() const if (isMatrix!(R, N, 1)) {
        R ret;
        foreach (i; 0 ..  N) {
            ret[i][0] = cast(R.dataType) data[i];
        }
        return ret;
    }

    /// Ditto
    R opCast(R)() const if (isMatrix!(R, 1, N)) {
        R ret;
        foreach (i; 0 ..  N) {
            ret[0][i] = cast(R.dataType) data[i];
        }
        return ret;
    }

    /// Cast to color
    Color opCast(R)() const if (is(R == Color) && (N == 3 || N == 4) && isFloatingPoint!T){
        Color ret;
        foreach (i; 0 ..  N) {
            ret[i] = cast(float) data[i];
        }
        if (N == 3) ret[3] = 1.0f;
        return ret;
    }

    /// Ditto
    Color opCast(R)() const if (is(R == Color) && (N == 3 || N == 4) && !isFloatingPoint!T){
        Color ret;
        foreach (i; 0 ..  N) {
            ret[i] = cast(float) (data[i] / 255.0f);
        }
        if (N == 3) ret[3] = 1.0f;
        return ret;
    }

    /// Cast to bool
    bool opCast(T)() const if (is(T == bool)) {
        return !lengthSquared.isClose(0, float.epsilon);
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

    /// Returns vector length
    public double length() const {
        return sqrt(cast(double) lengthSquared);
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
    public double distanceTo(VecType b) {
        return sqrt(cast(double) distanceSquaredTo(b));
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
        T q = lengthSquared;
        if (q == 0 || q.isClose(0, float.epsilon)) return this;
        VecType ret;
        double l = sqrt(cast(double) lengthSquared);
        foreach (i; 0 .. size) { ret[i] = cast(T) (data[i] / l); }
        return ret;
    }
    /// Ditto
    alias normalised = normalized;

    /// Normalises vector in place
    public VecType normalize() {
        T q = lengthSquared;
        if (q == 0 || q.isClose(0, float.epsilon)) return this;
        double l = sqrt(cast(double) lengthSquared);
        foreach (i; 0 .. size) { data[i] = cast(T) (data[i] / l); }
        return this;
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
    public double dot(VecType b) {
        double d = 0;
        foreach (i; 0 .. size) { d += cast(double) data[i] * cast(double) b.data[i]; }
        return d;
    }

    /// Signs current vector
    public VecType sign() {
        VecType ret;
        foreach (i; 0 .. size) { ret[i] = data[i].sgn(); }
        return ret;
    }

    // Opearations that only make sense on floats
    static if (isFloatingPoint!T) {
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

        /**
        Linear interpolates vector
        Params:
          to = Vector to interpolate to
          weight = Interpolation weight in range [0.0, 1.0]
        */
        public VecType lerp(VecType to, double weight) {
            VecType ret;
            foreach (i; 0 .. size) { ret[i] = data[i] + (weight * (to.data[i] - data[i])); }
            return ret;
        }

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

    /**
    Clamps vector values in place
    Params:
      b = Minimal Vector
      b = Maximal Vector
    */
    public VecType clamped(VecType p_min, VecType p_max) {
        foreach (i; 0 .. size) { data[i] = data[i].clamp(p_min.data[i], p_max.data[i]); }
        return this;
    }

    /**
    Clamps vector values
    Params:
      b = Minimal value
      b = Maximal value
    */
    public VecType clamp(T p_min, T p_max) {
        VecType ret;
        foreach (i; 0 .. size) { ret[i] = data[i].clamp(p_min, p_max); }
        return ret;
    }

    /**
    Clamps vector values in place
    Params:
      b = Minimal value
      b = Maximal value
    */
    public VecType clamped(T p_min, T p_max) {
        foreach (i; 0 .. size) { data[i] = data[i].clamp(p_min, p_max); }
        return this;
    }

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

    /**
    Snaps vector values in place
    Params:
      p_step = Vector to snap to
    */
    public VecType snapped(VecType p_step) {
        foreach (i; 0 .. size) {
            data[i] = data[i].snap(p_step[i]);
        }
        return this;
    }

    /**
    Snaps vector values
    Params:
      p_step = value to snap to
    */
    public VecType snap(T p_step) {
        VecType ret;
        foreach (i; 0 .. size) {
            ret[i] = data[i].snap(p_step);
        }
        return ret;
    }

    /**
    Snaps vector values in place
    Params:
      p_step = value to snap to
    */
    public VecType snapped(T p_step) {
        foreach (i; 0 .. size) {
            data[i] = data[i].snap(p_step);
        }
        return this;
    }

    /// Calculates reflected vector to normal
    public VecType reflect(VecType normal) {
        double d = dot(normal);
        VecType ret;
        foreach (i; 0..size) {
            ret[i] = cast(T) (data[i] - (2.0 * normal.data[i]) * d);
        }
        return ret;
    }

    /++
    Calculates direction of refracted ray where this is incoming ray,
    n is normal vector and r is refractive ratio
    +/
    public VecType refract(VecType n, double r) {
        double dt = dot(n);
        double d = 1.0 - r * r * (1.0 - dt * dt);
        VecType ret = 0;
        if (d >= 0) {
            foreach (i; 0..size) {
                ret[i] = cast(T) (r * data[i] - (r * dt + d) * n.data[i]);
            }
        }
        return ret;
    }


    /// Moves vector toward target
    public VecType moveTowards(VecType to, double maxDist) {
        double[size] d;
        double val = 0;

        foreach (i; 0..size) {
            d[i] = to[i] - data[i];
            val += d[i] * d[i];
        }

        if (val == 0 || (maxDist >= 0 && val <= maxDist * maxDist)) return to;

        VecType ret;
        double dist = sqrt(val);

        foreach (i; 0..size) {
            ret[i] = cast(T) (data[i] + d[i] / dist * maxDist);
        }

        return ret;
    }

    /// Limits length of vector and returns resulting vector
    public VecType limitLength(double p_min, double p_max) {
        VecType ret = VecType(data);
        double len = length;

        if (len > 0.0) {
            len = sqrt(len);

            if (len < p_min) {
                double scale = p_min / len;
                foreach (i; 0..size) {
                    ret[i] = cast(T) (ret[i] * scale);
                }
            }

            if (len > p_max) {
                double scale = p_max / len;
                foreach (i; 0..size) {
                    ret[i] = cast(T) (ret[i] * scale);
                }
            }
        }

        return ret;
    }

    static if (N == 2) {
        /// Calculates angle between this vector and v2 from [0, 0]
        public double angle(VecType v2) {
            static if (isFloatingPoint!T) {
                return atan2(v2.y - data[1], v2.x - data[0]);
            } else {
                return atan2(cast(double) v2.y - data[1], cast(double) v2.x - data[0]);
            }
        }

        /// Calculates angle between line this->to and X ordinate
        public double angleTo(VecType to) {
            return acos(dot(to).clamp(-1.0, 1.0));
        }

        /// Calculates cross product of this and b, assumes that Z = 0
        public double cross(VecType b) {
            return data[0] * b.y - data[1] * b.x;
        }

        /// Rotates vector by angle
        public VecType rotate(double angle) {
            double sina = sin(angle);
            double cosa = cos(angle);
            return VecType( cast(T) (data[0] * cosa - data[1] * sina), cast(T) (data[0] * sina + data[1] * cosa) );
        }
    }

    static if (N == 3) {
        /// Calculates angle between this vector and v2 from [0, 0]
        public double angle(VecType v2) {
            VecType cr = cross(v2);
            double len = cr.length();
            double dot = dot(v2);
            return atan2(len, dot);
        }


        /// Calculates cross product of this and b
        public VecType cross(VecType b) {
            VecType cr = VecType();
            T ax = data[0],
              ay = data[1],
              az = data[2];
            T bx = b.data[0],
              by = b.data[1],
              bz = b.data[2];
            cr.data[0] = ay * bz - az * by;
            cr.data[1] = az * bx - ax * bz;
            cr.data[2] = ax * by - ay * bx;
            return cr;
        }

        /// Returns vector perpendicular to this
        public VecType perpendicular() {
            double p_min = cast(double) data[0].abs;
            VecType cardinal = VecType(1, 0, 0);

            if (data[1].abs < p_min) {
                p_min = cast(double) data[1].abs;
                cardinal = VecType(0, 1, 0);
            }

            if (data[2].abs < p_min) {
                cardinal = VecType(0, 0, 1);
            }

            return VecType(
                data[1] * cardinal.z - data[2] * cardinal.y,
                data[2] * cardinal.x - data[0] * cardinal.z,
                data[0] * cardinal.y - data[1] * cardinal.x
            );
        }

        /// Projects vector3 from screen space into object space
        public VecType unproject(mat4 proj, mat4 view) {
            mat4 vpnorm = (view * proj);
            mat4 vpinv = ~vpnorm;
            quat qt = [data[0], data[1], data[2], 1.0f];
            quat qtrs = qt * vpinv;

            return VecType( cast(T) qtrs.x, cast(T) qtrs.y, cast(T) qtrs.z ) / cast(T) qtrs.w;
        }

        // todo project(mat4 proj, mat4 view) {}
    }

    static if (N == 4) {
        /// Calculates cross product of this and b,
        /// W is multiplication of a.w and b.w
        public VecType cross(VecType b) {
            VecType cr = VecType();
            T ax = data[0],
              ay = data[1],
              az = data[2],
              aw = data[3];
            T bx = b.data[0],
              by = b.data[1],
              bz = b.data[2],
              bw = b.data[3];
            cr.data[0] = ay * bz - az * by;
            cr.data[1] = az * bx - ax * bz;
            cr.data[2] = ax * by - ay * bx;
            cr.data[3] = aw * bw;
            return cr;

        }
    }
}

/// Is V a vector with any size and any type
template isVector(V) {
    enum isVector = is(Unqual!V == Vector!(U, n), size_t n, U);
}

/// Is V a vector with size n and any type
template isVector(V, size_t n) {
    static if(is(Unqual!V == Vector!(U, n2), size_t n2, U)) {
        enum isVector = n == n2;
    } else {
        enum isVector = false;
    }
}

/// Is V a vector with any size and type T
template isVector(V, T) {
    static if(is(Unqual!V == Vector!(U, n), size_t n, U)) {
        enum isVector = is(T == U);
    } else {
        enum isVector = false;
    }
}

/// Is V a vector with size N and type T
template isVector(V, T, size_t N) {
    enum isVector = is(Unqual!V == Vector!(T, N));
}

