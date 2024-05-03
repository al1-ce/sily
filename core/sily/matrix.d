// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/++
Flexible templated matrix with some math utils

To use mat.perspective/mat.frustum/..etc without prefix MUST define
version for either Vulkan (SILY_CONFIG_VULKAN) or OpenGL (SILY_CONFIG_OPENGL).

For commandline - `-version=SILY_CONFIG_VULKAN`.
For dub.sdl - `versions "SILY_CONFIG_VULKAN"`
+/
module sily.matrix;

import std.math;
import std.numeric;
import std.conv;
import std.traits;
import std.typetuple;
import std.algorithm;
import std.stdio;
import std.string;
import std.format;

import sily.math;
import sily.array;
import sily.vector;
import sily.quat;

/// GLSL style aliases
alias mat(T, size_t H, size_t W) = Matrix!(T, H, W);
/// Ditto
alias mat(size_t H, size_t W) = Matrix!(float, H, W);
/// Ditto
alias mat4 = mat!(4, 4);
/// Ditto
alias mat3 = mat!(3, 3);
/// Ditto
alias mat2 = mat!(2, 2);

/// Ditto
alias imat(size_t H, size_t W) = Matrix!(int, H, W);
/// Ditto
alias imat4 = imat!(4, 4);
/// Ditto
alias imat3 = imat!(3, 3);
/// Ditto
alias imat2 = imat!(2, 2);

// mat2x3 // mat[row][col] // mat[1][2] = b
// data def = data[row][col] aka T[col][row]
// [ [a], [b], [c] ]
// [ [d], [e], [f] ]
/++
Matrix implementation, row-major right handed
Basic operations:
---
// Scalar operations, any of *, /, +, -, % with number
m1 + 1;
m1 * 2;
// etc...
// Matrix/Matrix scalar op (on each element)
m1 + m2;
m1 - m2;
m1.scalarMultiply(m2);
m1.scalarDivide(m2);
// Unary operations
-m1; // invert all numbers
~m1; // invert matrix, aka m1^-1, where ~m1*m1=m1.identity
// Binary operations
m1 * m2; // matrix multiplication
vec1x2 * m2x1; // vector by matrix
m3x4 * vec4x1; // matrix by vector
// Casting
cast(vec1x3) mat1x3; // cast to column vector
cast(vec3x1) mat1x3; // or row vector
cast(mat1x3) vec3x1; // or event vector to mat
cast(imat2) fmat2; // and type changing casts
cast(imat2) imat4; // changing size (keeps top left)
cast(imat4) imat2; // fills new cells with zeros
// Data access:
m1[1][2]; // access to row 1 column 2
m1.data[1][2]; // or explicit access to data
---
+/
struct Matrix(T, size_t H, size_t W) if (isNumeric!T && W > 0 && H > 0) {
    /// Matrix data
    T[W][H] data = 0;

    /// Alias to allow data access
    alias data this;
    /// Alias to data type
    alias dataType = T;

    /// Is matrix square (W == H)
    enum bool isSquare = W == H;

    /++
    Alias to matrix type. Can be used to construct matrices
    of same type
    ---
    auto rmat7x2 = Matrix!(real, 7, 2);
    auto rmat7x2_2 = rmat7x2.MatType;
    +/
    alias MatType = Matrix!(T, H, W);
    /// Matrix size (h*w)
    enum size_t size = H * W;
    /// Matrix size (h)
    enum size_t rows = H;
    /// Matrix size (w)
    enum size_t columns = W;

    /++
    Constructs Matrix from components. If no components present
    matrix will be filled with 0
    Example:
    ---
    // Matrix can be constructed manually or with aliases
    // Fills int matrix 2x2 with 1
    auto m0 = Matrix!(int, 2, 2)(1);
    // Fills int matrix 2x2 with [[1, 2], [3, 4]]
    auto m1 = Matrix!(int, 2, 2)(1, 2, 3, 4);
    // Same
    auto m2 = Matrix!(int, 2, 2)([[1, 2], [3, 4]]);
    // Same
    mat2 m3 = [1, 2, 3, 4];
    // Same
    mat2 m4 = [[1, 2], [3, 4]];
    // Also you can construct matrix by
    // assigning values directly
    mat!(2, 3) m5 = [[1, 2, 3], [4, 5, 6]];
    +/
    this(in T val) {
        foreach (i; 0..H) {
            foreach (j; 0..W) {
                data[i][j] = val;
            }
        }
    }
    /// Ditto
    this(in T[size] vals...) {
        foreach (i; 0..H) {
            foreach (j; 0..W) {
                data[i][j] = vals[i * W + j];
            }
        }
    }
    /// Ditto
    this(in T[W][H] vals...) {
        data = vals;
    }

    static if (isSquare && W == 4 && isFloatingPoint!T) {
        /// Construct matrix from quaternion
        this(in quat q) {
            T x2 = 2.0 * q.x * q.x;
            T y2 = 2.0 * q.y * q.y;
            T z2 = 2.0 * q.z * q.z;
            T xy = 2.0 * q.x * q.y;
            T xz = 2.0 * q.x * q.z;
            T xw = 2.0 * q.x * q.w;
            T yz = 2.0 * q.y * q.z;
            T yw = 2.0 * q.y * q.w;
            T zw = 2.0 * q.z * q.w;

            data = [
                [1.0 - y2 - z2, xy - zw, xz + yw, 0],
                [xy + zw, 1.0 - x2 - z2, yz - xw, 0],
                [xz - yw, yz + xw, 1.0 - x2 - y2, 0],
                [0.0, 0.0, 0.0, 1.0]
            ];
        }
    }


    /* -------------------------------------------------------------------------- */
    /*                         UNARY OPERATIONS OVERRIDES                         */
    /* -------------------------------------------------------------------------- */

    /// Scalar matrix addition and subtraction
    MatType opBinary(string op, R)(in Matrix!(R, H, W) b) const if ( op == "+" || op == "-" ) {
        MatType ret = MatType();
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                mixin( "ret[i][j] = data[i][j] " ~ op ~ " b.data[i][j];" );
            }
        }
        return ret;
    }

    /// Ditto
    MatType opBinaryRight(string op, R)(in Matrix!(R, H, W) b) const if ( op == "+" || op == "-" ) {
        MatType ret = MatType();
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                mixin( "ret[i][j] = b.data[i][j] " ~ op ~ " data[i][j];" );
            }
        }
        return ret;
    }

    /// Matrix multiplication
    Matrix!(T, H, U) opBinary(string op, R, size_t U)(in Matrix!(R, W, U) b) const if ( op == "*" ) {
        Matrix!(T, H, U) ret = Matrix!(T, H, U)(0);
        foreach (i; 0 .. H) {
            foreach (j; 0..U) {
                foreach (k; 0.. W) {
                    ret[i][j] += data[i][k] * b.data[k][j];
                    if (abs(ret[i][j]) <= float.epsilon * 2.0f) ret[i][j] = 0;
                }
            }
        }
        return ret;
    }

    /// Ditto
    Matrix!(T, U, W) opBinaryRight(string op, R, size_t U)(in Matrix!(R, U, H) b) const if ( op == "*" ) {
        Matrix!(T, U, W) ret = Matrix!(T, U, W)(0);
        foreach (i; 0..U) {
            foreach (j; 0..W) {
                foreach (k; 0..H) {
                    ret[i][j] += b.data[i][k] * data[k][j];
                    if (abs(ret[i][j]) <= float.epsilon * 2.0f) ret[i][j] = 0;
                }
            }
        }
        return ret;
    }

    /// Vector transformation
    Vector!(R, H) opBinary(string op, R)(in Vector!(R, W) b) const if ( op == "*" ) {
        Vector!(R, H) ret = 0;
        foreach (i; 0 .. H) {
            foreach (k; 0.. W) {
                ret[i] += data[i][k] * b.data[k];
                if (abs(ret[i]) <= float.epsilon * 2.0f) ret[i] = 0;
            }
        }
        return ret;
    }

    /// Ditto
    Vector!(R, W) opBinaryRight(string op, R)(in Vector!(R, H) b) const if ( op == "*" ) {
        Vector!(R, W) ret = 0;
        foreach (j; 0..W) {
            foreach (k; 0..H) {
                ret[j] += b.data[k] * data[k][j];
                if (abs(ret[j]) <= float.epsilon * 2.0f) ret[j] = 0;
            }
        }
        return ret;
    }

    /// Vector3 transformation
    Vector!(R, 3) opBinary(string op, R)(in Vector!(R, 3) b) const if ( op == "*" && W == 4 ) {
        Vector!(R, 3) ret = 0;
        foreach (i; 0 .. 3) {
            foreach (k; 0.. W) {
                if (k == 3) {
                    ret[i] += data[i][k];
                } else {
                    ret[i] += data[i][k] * b.data[k];
                }
                if (abs(ret[i]) <= float.epsilon * 2.0f) ret[i] = 0;
            }
        }
        return ret;
    }

    /// Ditto
    Vector!(R, 3) opBinaryRight(string op, R)(in Vector!(R, 3) b) const if ( op == "*" && H == 4 ) {
        Vector!(R, 3) ret = 0;
        foreach (j; 0..3) {
            foreach (k; 0..H) {
                if (k == 3) {
                    ret[j] += data[k][j];
                } else {
                    ret[j] += b.data[k] * data[k][j];
                }
                if (abs(ret[j]) <= float.epsilon * 2.0f) ret[j] = 0;
            }
        }
        return ret;
    }

    /// Quaternion transformation
    quat opBinary(string op)(in quat b) const if ( op == "*" && W == 4) {
        quat ret = 0;
        foreach (i; 0 .. H) {
            foreach (k; 0.. W) {
                ret[i] += data[i][k] * b.data[k];
                if (abs(ret[i]) <= float.epsilon * 2.0f) ret[i] = 0;
            }
        }
        return ret;
    }

    /// Ditto
    quat opBinaryRight(string op)(in quat b) const if ( op == "*" && H == 4) {
        quat ret = 0;
        foreach (j; 0..W) {
            foreach (k; 0..H) {
                ret[j] += b.data[k] * data[k][j];
                if (abs(ret[j]) <= float.epsilon * 2.0f) ret[j] = 0;
            }
        }
        return ret;
    }

    /// Scalar number operations
    MatType opBinary(string op, R)(in R b) const if ( isNumeric!R ) {
        MatType ret = MatType();
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                mixin( "ret[i][j] = data[i][j] " ~ op ~ " b;" );
            }
        }
        return ret;
    }

    /// Ditto
    MatType opBinaryRight(string op, R)(in R b) const if ( isNumeric!R ) {
        MatType ret = MatType();
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                mixin( "ret[i][j] = b " ~ op ~ " data[i][j];" );
            }
        }
        return ret;
    }

    /// opEquals x == y
    bool opEquals(R)(in Matrix!(R, H, W) b) const {
        bool eq = true;
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                eq = eq && data[i][j] == b.data[i][j];
                if (!eq) break;
            }
        }
        return eq;
    }

    /// Ditto
    bool opEquals(R, size_t V, size_t U)(in Matrix!(R, V, U) b) const if (V != H || U != W) {
        return false;
    }

    /// Ditto
    bool opEquals(R)(in R[][] b) const if ( isNumeric!R ){
        bool eq = true;
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                eq = eq && data[i][j] == b[i][j];
                if (!eq) break;
            }
        }
        return eq;
    }

    /// Ditto
    bool opEquals(R)(in R[] b) const if ( isNumeric!R ){
        bool eq = true;
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                eq = eq && data[i][j] == b[i * W + j];
                if (!eq) break;
            }
        }
        return eq;
    }

    // Cannot compare matrices
    // opCmp x [< > <= >=] y

    /// opUnary [-, +, --, ++, *, ~] x
    MatType opUnary(string op)() if(op == "-" || op == "+"){
        MatType ret = MatType();
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                mixin( "ret[i][j] = " ~ op ~ " data[i][j];" );
            }
        }
        return ret;
    }

    /// Invert matrix
    Matrix!(float, W, W) opUnary(string op)() if(op == "~" && isSquare) {
        T det = determinant;
        if (det == 0) throw new Error("Cannot invert single matrix.");
        Matrix!(float, W, W) inv = 0;
        T[W][W] adj = adjoint();
        foreach (i; 0..W) {
            foreach (j; 0..H) {
                inv[i][j] = adj[i][j] / cast(float) det;
                if (abs(inv[i][j]) <= float.epsilon * 2.0f) inv[i][j] = 0;
            }
        }
        return inv;
    }

    /// Scalar addition and subtraction in place
    MatType opOpAssign(string op, R)( in Matrix!(R, H, W) b ) if ( op == "+" || op == "-" ) {
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                mixin( "data[i] " ~ op ~ "= b.data[i][j];" );
            }
        }
        return this;
    }

    // no OpAssign for mat * mat coz this size is constant

    /// Ditto
    MatType opOpAssign(string op, R)( in R b ) if ( isNumeric!R ) {
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                mixin( "data[i] " ~ op ~ "= b" );
            }
        }
        return this;
    }

    /// Matrix type conversion
    R opCast(R)() const if (isMatrix!(R, H, W)){
        R ret;
        foreach (i; 0 .. H) {
            foreach (j; 0 ..W) {
                ret[i][j] = cast(R.dataType) data[i][j];
            }
        }
        return ret;
    }

    /// Matrix resizing
    R opCast(R)() const if (isMatrix!(R) && (R.rows != H || R.columns != W)) {
        size_t V = R.rows;
        size_t U = R.columns;
        R ret = 0;
        size_t _h = V < H ? V : H;
        size_t _w = U < W ? U : W;
        foreach (i; 0.._h) {
            foreach (j; 0.._w) {
                ret[i][j] = data[i][j];
            }
        }
        return ret;
    }

    /// Matrix to vector cast (column)
    R opCast(R)() const if (isVector!(R, H) && W == 1) {
        R ret;
        foreach (i; 0..H) {
            ret[i] = cast(ret.dataType) data[i][0];
        }
        return ret;
    }

    /// Matrix to vector cast (row)
    R opCast(R)() const if (isVector!(R, W) && H == 1) {
        R ret;
        foreach (i; 0..W) {
            ret[i] = cast(ret.dataType) data[0][i];
        }
        return ret;
    }

    /// Boolean cast
    bool opCast(T)() const if (is(T == bool)) {
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                if (data[i][j] != 0) return true;
            }
        }
        return false;
    }

    /// Returns hash
    size_t toHash() const @safe nothrow {
        return typeid(data).getHash(&data);
    }

    /// Returns copy of matrix
    public MatType copyof() {
        return MatType(data);
    }

    /// Returns string representation of matrix: `[1.00, 1.00,... , 1.00]`
    public string toString() const {
        import std.conv : to;
        string s;
        s ~= "[";
        foreach (i; 0..H) {
            foreach (j; 0..W) {
                s ~= isFloatingPoint!T ? format("%.2f", data[i][j]) : format("%d", data[i][j]);
                if (!(i == H - 1 && j == W - 1)) s ~= ", ";
            }
        }
        s ~= "]";
        return s;
    }

    /// Returns string representation of matrix: `1.00, 1.00,... |\n|1.00, ... , 1.00|`
    public string toStringPretty() const {
        import std.conv : to;
        size_t biggest = 1;
        foreach (i; 0..H) {
            foreach (j; 0..W) {
                string s = isFloatingPoint!T ? format("%.2f", data[i][j]) : format("%d", data[i][j]);
                if (s.length > biggest) biggest = s.length;
            }
        }

        string s;
        foreach (i; 0..H) {
            s ~= "|";
            foreach (j; 0..W) {
                string _s = isFloatingPoint!T ? format("%.2f", data[i][j]) : format("%d", data[i][j]);
                s ~= _s ~ format("%-*s", (biggest + 1) - _s.length, " ");
            }
            if (i != H - 1) s ~= "|\n";
        }
        s ~= "|";
        return s;
    }


    /// Returns pointer to data
    public T[W]* ptr() return {
        return data.ptr;
    }

    static if (isSquare) {
        /// Returns determinant of matrix
        public T determinant() const {
            return getDeterminant!(W)(data.to!(T[][]));
        }

        private T getDeterminant(size_t S)(T[][] _mat) const if (S > 0) {
            static if (S == 1) {
                return _mat[0][0];
            } else {
                T d = 0;
                T[][] temp = new T[][](S, S);
                T sign = 1;
                foreach (f; 0..S) {
                    getCofactor!S(_mat, temp, 0, f);
                    d += sign * _mat[0][f] * getDeterminant!(S - 1)(temp);
                    sign = -sign;
                }
                return d;
            }
        }

        private void getCofactor(size_t S)(T[][] _mat, ref T[][] _temp, size_t y, size_t x) const {
            int i = 0;
            int j = 0;
            foreach (r; 0..S) {
                foreach (c; 0..S) {
                    if (r != y && c != x) {
                        _temp[i][j++] = _mat[r][c];
                        if (j == S - 1) {
                            j = 0;
                            ++i;
                        }
                    }
                }
            }
        }

        /// Returns ajdoint matrix
        public MatType adjoint() const {
            static if (W == 1) {
                return data[0][0];
            } else {
                MatType ret = 0;
                int sign = 1;
                T[][] temp = new T[][](W, W);
                T[][] tdata = data.to!(T[][]);
                foreach (i; 0..W) {
                    foreach (j; 0..W) {
                        getCofactor!W(tdata, temp, i, j);
                        sign = ((i + j) % 2 == 0) ? 1 : -1;
                        ret[j][i] = sign * getDeterminant!(W - 1)(temp);
                    }
                }
                return ret;
            }
        }

        /// Returns identity matrix for size
        public static MatType identity() {
            MatType ret = 0;
            foreach (i; 0..W) {
                ret[i][i] = 1;
            }
            return ret;
        }

        static if (isFloatingPoint!T) {
            /// Inverts current matrix, alias to `data = ~matrix`
            public MatType invert() {
                MatType m = copyof;
                data = (~m).data;
                return this;
            }
            /// Ditto
            alias inverse = invert;
        }

        /// Returns inverted, alias to `return ~matrix`
        public mat!(H, W) inverted() {
            MatType m = copyof;
            return (~m);
        }

        /// Ditto
        alias inversed = inverted;

    }

    /// Multiplies each element by each element of matrices
    public MatType scalarMultiply(R)(in Matrix!(R, W, H) b) {
        MatType ret = 0;
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                ret[i][j] = data[i][j] * b.data[i][j];
            }
        }
        return ret;
    }

    /// Divides each element by each element of matrices
    public MatType scalarDivide(R)(in Matrix!(R, W, H) b) {
        MatType ret = 0;
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                ret[i][j] = data[i][j] / b.data[i][j];
            }
        }
        return ret;
    }

    /// Transpose of matrix (swaps rows and columns)
    public Matrix!(T, W, H) transpose() {
        Matrix!(T, W, H) ret = 0;
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                ret[j][i] = data[i][j];
            }
        }
        return ret;
    }

    /// Resize matrix (keep left top). Alias to cast(Matrix!(T, V, U)) Matrix!(T, H, W)
    public Matrix!(T, V, U) resize(size_t V, size_t U)() if (V > 0 && U > 0) {
        return cast(Matrix!(T, V, U)) this;
    }

    static if (isSquare && W == 2 && isFloatingPoint!T) {
    } else
    static if (isSquare && W == 3 && isFloatingPoint!T) {
        /// Constructs 2d rotation matrix
        static MatType rotation(T angle) {
            return MatType(cos(angle), -sin(angle), 0, sin(angle), cos(angle), 0, 0, 0, 1).fixNegativeZero;
        }

        /// Constructs 2d scale matrix
        static MatType scale(T[2] s...) {
            return MatType(s[0], 0, 0, 0, s[1], 0, 0, 0, 1);
        }

        /// Constructs 2d shear matrix
        static MatType shear(T[2] s...) {
            return MatType(1, s[0], 0, s[1], 1, 0, 0, 0, 1);
        }

        /// Constructs 2d translation matrix
        static MatType translation(T[2] s...) {
            return MatType(1, 0, s[0], 0, 1, s[1], 0, 0, 1);
        }
    } else
    static if (isSquare && W == 4 && isFloatingPoint!T) {
        /// Constructs 3d rotation matrix from axis and angle
        static MatType rotation(T[3] axis, T angle) {
            if (!vec3(axis).isNormalized) axis = vec3(axis).normalize();
            T x = axis[0];
            T y = axis[1];
            T z = axis[2];

            float sina = sin(angle);
            float cosa = cos(angle);
            float t = 1.0f - cosa;

            MatType ret = MatType(
                x * x * t + cosa,     x * y * t - z * sina, x * z * t + y * sina, 0,
                y * x * t + z * sina, y * y * t + cosa,     y * z * t - x * sina, 0,
                z * x * t - y * sina, z * y * t + x * sina, z * z * t + cosa, 0,
                0, 0, 0, 1
            ).fixNegativeZero;

            return ret;
        }

        /// Constructs 3d rotation matrix from angle on X axis
        static MatType rotationX(T angle) {
            return MatType(
                1, 0, 0, 0,
                0, cos(angle), -sin(angle), 0,
                0, sin(angle), cos(angle), 0,
                0, 0, 0, 1
            ).fixNegativeZero;
        }

        /// Constructs 3d rotation matrix from angle on Y axis
        static MatType rotationY(T angle) {
            return MatType(
                cos(angle), 0, sin(angle), 0,
                0, 1, 0, 0,
                -sin(angle), 0, cos(angle), 0,
                0, 0, 0, 1
            ).fixNegativeZero;
        }

        /// Constructs 3d rotation matrix from angle on Z axis
        static MatType rotationZ(T angle) {
            return MatType(
                cos(angle), -sin(angle), 0, 0,
                sin(angle), cos(angle), 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
            ).fixNegativeZero;
        }

        /// Constructs 3d scale matrix
        static MatType scale(T[3] v...) {
            return MatType(
                v[0], 0, 0, 0,
                0, v[1], 0, 0,
                0, 0, v[2], 0,
                0, 0, 0, 1
            );
        }

        /// Constructs 3d translation matrix
        static MatType translation(T[3] v...) {
            return MatType(
                1, 0, 0, v[0],
                0, 1, 0, v[1],
                0, 0, 1, v[2],
                0, 0, 0, 1
            );
        }

        /// Constructs frustum matrix
        static MatType glFrustum(T left, T right, T bottom, T top, T near, T far) {
            MatType m;
            m[0][0] = (2.0 * near) / (right - left);
            m[1][1] = (2.0 * near) / (top - bottom);
            m[0][2] = (right + left) / (right - left);
            m[1][2] = (top + bottom) / (top - bottom);
            m[2][2] = far / (near - far);
            m[3][2] = -1.0;
            m[2][3] = -(far * near) / (far - near);
            return m;
        }

        /// Ditto
        static MatType vkFrustum(T left, T right, T bottom, T top, T near, T far) {
            MatType m;
            m[0][0] = (2.0 * near) / (right - left);
            m[1][1] = (2.0 * near) / (top - bottom);
            m[0][2] = -(right + left) / (right - left);
            m[1][2] = -(top + bottom) / (top - bottom);
            m[2][2] = far / (far - near);
            m[3][2] = 1.0;
            m[2][3] = -(far * near) / (far - near);
            return m;
        }

        version(SILY_CONFIG_VULKAN) {
            /// Ditto
            alias frustum = vkFrustum;
        }
        version(SILY_CONFIG_OPENGL) {
            /// Ditto
            alias frustum = glFrustum;
        }

        // TODO: spherical perspective
        // LINK: http://www.songho.ca/opengl/gl_projectionmatrix.html
        /++
        Construct perspective matrix
        Params:
            fovy = vertical fov in degrees (int) or radians (double)
            aspect = screen.width / screen.height
            near = near cutoff plane
            fat = far cutoff plane
        +/
        static MatType glPerspective(int fovy, T aspect, T near, T far) {
            return glPerspective( fovy * deg2rad, aspect, near, far );
        }

        /++ Ditto +/
        static MatType glPerspective(T fovy, T aspect, T near, T far) {
            MatType m;
            T tanHalfFovy = tan(fovy / 2.0);
            m[0][0] = 1.0 / (aspect * tanHalfFovy);
            m[1][1] = 1.0 / tanHalfFovy;
            m[2][2] = far / (near - far);
            m[2][3] = -(far * near) / (far - near);
            m[3][2] = -1.0;
            return m;
        }

        /++ Ditto +/
        static MatType vkPerspective(int fovy, T aspect, T near, T far) {
            return vkPerspective( fovy * deg2rad, aspect, near, far );
        }

        /++ Ditto +/
        static MatType vkPerspective(T fovy, T aspect, T near, T far) {
            MatType m;
            T tanHalfFovy = tan(fovy / 2.0);
            m[0][0] = 1.0 / (aspect * tanHalfFovy);
            m[1][1] = 1.0 / tanHalfFovy;
            m[2][2] = far / (far - near);
            m[2][3] = -(far * near) / (far - near);
            m[3][2] = 1.0;
            return m;
        }

        version(SILY_CONFIG_VULKAN) {
            /// Ditto
            alias perspective = vkPerspective;
        }
        version(SILY_CONFIG_OPENGL) {
            /// Ditto
            alias perspective = glPerspective;
        }

        /// Constructs orthographic matrix
        static MatType glOrtho(T left, T right, T bottom, T top, T near, T far) {
            MatType m;
            m[0][0] = 2.0 / (right - left);
            m[1][1] = 2.0 / (top - bottom);
            m[2][2] = -1.0 / (far - near);
            m[0][3] = -(right + left) / (right - left);
            m[1][3] = -(top + bottom) / (top - bottom);
            m[2][3] = -near / (far - near);
            return m;
        }

        /// Ditto
        static MatType vkOrtho(T left, T right, T bottom, T top, T near, T far) {
            MatType m;
            m[0][0] = 2.0 / (right - left);
            m[1][1] = 2.0 / (top - bottom);
            m[2][2] = 1.0 / (far - near);
            m[0][3] = -(right + left) / (right - left);
            m[1][3] = -(top + bottom) / (top - bottom);
            m[2][3] = -near / (far - near);
            return m;
        }

        version(SILY_CONFIG_VULKAN) {
            /// Ditto
            alias ortho = vkOrtho;
        }
        version(SILY_CONFIG_OPENGL) {
            /// Ditto
            alias ortho = glOrtho;
        }

        /// Constructs lookAt matrix
        static MatType glLookAt(vec!(T, 3) eye, vec!(T, 3) target, vec!(T, 3) up) {
            vec3 vz = eye - target;
            vz.normalize;

            vec3 vx = up.cross(vz);
            vx.normalize;

            vec3 vy = vz.cross(vx);

            return MatType(
                vx.x, vx.y, vx.z, -vx.dot(eye),
                vy.x, vy.y, vy.z, -vy.dot(eye),
                vz.x, vz.y, vz.z, -vz.dot(eye),
                0, 0, 0, 1
            );
        }

        /// Ditto
        static MatType vkLookAt(vec!(T, 3) eye, vec!(T, 3) target, vec!(T, 3) up) {
            vec3 vz = target - eye;
            vz.normalize;

            vec3 vx = vz.cross(up);
            vx.normalize;

            vec3 vy = vx.cross(vz);

            return MatType(
                vx.x,   vx.y,  vx.z, -vx.dot(eye),
                vy.x,   vy.y,  vy.z, -vy.dot(eye),
                -vz.x, -vz.y, -vz.z, -vz.dot(eye),
                0, 0, 0, 1
            );
        }

        version(SILY_CONFIG_VULKAN) {
            /// Ditto
            alias lookAt = vkLookAt;
        }
        version(SILY_CONFIG_OPENGL) {
            /// Ditto
            alias lookAt = glLookAt;
        }
    }

    /// Removes negative sign from numbers less then float.epsilon*2
    public MatType fixNegativeZero() {
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                if (abs(data[i][j]) <= float.epsilon * 2.0f) data[i][j] = 0;
            }
        }
        return this;
    }

    /++
    Construct row-major one dimentional array from matrix.

    **Do not pass to OpenGL or Vulkan, use** `buffer()` **instead**
    +/
    public T[W*H] rowBuffer() {
        T[W*H] ret;
        foreach (i; 0 .. H) {
            foreach (j; 0..W) {
                ret[i * W + j] = data[i][j];
            }
        }
        return ret;
    }

    /++
    Construct column-major one dimentional array from matrix.

    **OpenGL and Vulkan is column-major, please use this method for it.**
    +/
    public T[W*H] columnBuffer() {
        T[W*H] ret;
        foreach (j; 0..W) {
            foreach (i; 0 .. H) {
                ret[j * H + i] = data[i][j];
            }
        }
        return ret;
    }

    /// Ditto
    alias buffer = columnBuffer;
}

/// Is V a matrix with any size and any type
template isMatrix(M) {
    enum isMatrix = is(Unqual!M == Matrix!(T, H, W), T, size_t H, size_t W);
}

/// Is V a vector with size H2xW2 and any type
template isMatrix(M, size_t H2, size_t W2) {
    static if(is(Unqual!M == Matrix!(T, H, W), T, size_t H, size_t W)) {
        enum isMatrix = H2 == H && W2 == W;
    } else {
        enum isMatrix = false;
    }
}

/// Is V a vector with any size and type T
template isMatrix(M, T) {
    static if(is(Unqual!M == Matrix!(U, H, W), U, size_t H, size_t W)) {
        enum isMatrix = is(T == U);
    } else {
        enum isMatrix = false;
    }
}

/// Is V a vector with size H2xW2 and type T
template isMatrix(M, T, size_t H, size_t W) {
    enum isMatrix = is(Unqual!M == Matrix!(T, H, W));
}

