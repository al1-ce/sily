#!/usr/bin/env dub
/+ dub.sdl:
name "matrixtext"
dependency "sily" path="../"
dependency "sily:term" path="../"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio: writeln, write;
import std.conv: to;
import std.math;
import std.traits;

import sily.quat;
import sily.matrix;
import sily.vector;
// import sily.unit;
import sily.bash: FG, FRESET;
import sily.log: hr, center;

void eq(T, S, int line = __LINE__, string file = "test.d")(T t1, S t2, string message) {
    bool cond = t1 == t2;
    hr('─', message.to!dstring, cond ? (cast(string) FG.RESET) : (cast(string) FG.LT_RED),
                cond ? (cast(string) FG.RESET) : (cast(string) FG.LT_RED));
    if (!cond) writeln(cast(string)(FG.DK_GRAY), "Expected: ", cast(string)(FG.LT_RED));
    static if (isMatrix!T && isArray!S && isArray!(typeof(t2[0]))) {
        if (!cond) {
            write(t2.makePretty);
        }
    } else {
        if (!cond) {
            write(t2.to!string);
        }
    }
    if (!cond) writeln();
    if (!cond) writeln(cast(string)(FG.DK_GRAY), "Got: ", cast(string)(FG.LT_RED));
    write(t1.to!string);
    if (!cond) write(cast(string)(FRESET.ALL));
    writeln();
}

void main() {
    imat!(2, 1) mat2x1const = 2;
    imat!(3, 4) im1 = [[4, -7, 5, 0], [-2, 0, 11, 8], [19, 1, -3, 12]];
    imat!(3, 4) im2 = [ 4, -7, 5, 0,   -2, 0, 11, 8,   19, 1, -3, 12];
    mat2x1const.eq([[2], [2]], "mat2x1 = 2");
    im1.eq([[4, -7, 5, 0], [-2, 0, 11, 8], [19, 1, -3, 12]], "mat3x4 = ?");
    im2.eq(im1, "opEq");
    im1[0][2].eq(5, "opIndex[0][2]");
    mat2(0).eq([[0, 0], [0, 0]], "opEq");

    (mat2(1, 2, 3, 4) + mat2(2, 1, 4, 3)).eq([[3, 3], [7, 7]], "sum");
    (mat2(1, 2, 3, 4) - mat2(2, 1, 4, 3)).eq([[-1, 1], [-1, 1]], "sub");
    (mat2(1) == mat2(1)).eq(true, "opEq");
    (cast(Matrix!(int, 2, 1)) (Matrix!(float, 2, 1)(1.4, 5.4))).eq([[1], [5]], "opCast");
    (mat2(1, 2, 3, 4) * mat2(2, 1, 4, 3)).eq([[10, 7], [22, 15]], "mul 2 by 2");
    (mat2(1, 2, 3, 4).opBinaryRight!"*"(mat2(2, 1, 4, 3))).eq([[5, 8], [13, 20]], "r->l mul 2 by 2");
    (Matrix!(int, 2, 3)(1, 2, 3, 4, 5, 6) * Matrix!(int, 3, 1)(2, 1, 4)).eq([[16], [37]], "mul 2x3 by 3x1");
    (Matrix!(int, 2, 3)(1, 2, 3, 4, 5, 6).opBinaryRight!"*"(Matrix!(int, 1, 2)(1, 2))
     ).eq([[9, 12, 15]], "r->l mul 1x2 by 2x3");
    (+mat2(1, 2, 3, 4)).eq([[1, 2], [3, 4]], "opUnary +");
    (-mat2(1, 2, 3, 4)).eq([[-1, -2], [-3, -4]], "opUnary -");
    (mat2(1, 2, 3, 4) * -1).eq([[-1, -2], [-3, -4]], "opBinary * -1");
    mat2(3, 7, 1, -4).determinant.eq(-19, "determinant2");
    mat3(1, 2, -1, 0, 3, -4, -1, 2, 1).determinant.eq(16, "determinant3");
    mat3(1, 2, 3, 4, 5, 6, 5, 7, 9).determinant.eq(0, "zero determinant3");
    mat4 m4 = mat4(5, -2, 2, 7, 1, 0, 0, 3, -3, 1, 5, 0, 3, -1, -9, 4);
    hr('─', "Matrix adjoint"d);
    writeln(m4.adjoint);
    hr('─', "Matrix inverse"d);
    writeln(~m4);
    hr('─', "Matrix inverse * Matrix"d);
    writeln((~m4) * m4);
    (cast(Matrix!(int, 3, 1)) vec3(2.45f, 4f, 1.02f)).eq(Matrix!(int, 3, 1)(2, 4, 1), "vec opCast(mat)");
    (cast(ivec3) Matrix!(float, 3, 1)(2.45f, 4f, 1.02f)).eq(ivec3(2, 4, 1), "mat opCast(vec)");
    (mat3(1, 2, 3, 4, 5, 6, 7, 8, 9) * vec3(1, 2, 3)).eq(Matrix!(float, 3, 1)(14, 32, 50), "mat * vec");
    (vec3(1, 2, 3) * mat3(1, 2, 3, 4, 5, 6, 7, 8, 9)).eq(Matrix!(float, 1, 3)(30, 36, 42), "vec * mat");
    (mat2(1, 2, 3, 4).scalarMultiply(mat2(2, 1, 4, 3))).eq(mat2(2, 2, 12, 12), "scalar *");
    (mat2(10, 2, 4, 12).scalarDivide(mat2(5, 1, 2, 6))).eq(mat2(2, 2, 2, 2), "scalar /");
    (mat2(10, 2, 4, 12).identity).eq(mat2(1, 0, 0, 1), "identity");
    mat!(2, 3)(1, 2, 3, 4, 5, 6).transpose.eq(mat!(3, 2)(1, 4, 2, 5, 3, 6), "transpose");
    imat3(2, 4, -1, -10, 5, 11, 18, -7, 6).transpose.eq(imat3(2, -10, 18, 4, 5, -7, -1, 11, 6), "transpose");
    mat3.rotation(PI_2).eq(mat3(0, -1, 0, 1, 0, 0, 0, 0, 1), "mat3 rot(pi/2)");
    mat4.rotationX(PI_2).eq(mat4(1, 0, 0, 0, 0, 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1), "mat4 rotX(pi/2)");
    mat4.rotationY(PI_2).eq(mat4(0, 0, 1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1), "mat4 rotY(pi/2)");
    mat4.rotationZ(PI_2).eq(mat4(0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1), "mat4 rotZ(pi/2)");
    hr('─', "Rotation"d);
    mat4.rotation(vec3(1, 0.2, 0.5), 2.5).writeln;
    imat3(1, 2, 3, 4, 5, 6, 7, 8, 9).resize!(4, 4)()
        .eq(imat4(1, 2, 3, 0, 4, 5, 6, 0, 7, 8, 9, 0, 0, 0, 0, 0), "resize up");
    imat3(1, 2, 3, 4, 5, 6, 7, 8, 9).resize!(2, 2)().eq(imat2(1, 2, 4, 5), "resize down");
    (cast(imat!(2, 3)) imat3(1, 2, 3, 4, 5, 6, 7, 8, 9)).eq(imat!(2, 3)(1, 2, 3, 4, 5, 6), "resize down cast");
    hr('─', "Scale"d);
    writeln(mat4.scale(vec3(0.4, 0.5, 2)));
    hr('─', "Translation"d);
    writeln(mat4.translation(vec3(0.4, 0.5, 2)));
    hr('─', "Buffers"d);
    im2.writeln;
    im2.buffer.writeln;
    im2.rowBuffer.writeln;
    hr('─', "Frustum"d);
    mat4.glFrustum(9, 20, 20, 12, 2, 50).writeln;
    hr('─', "Perspective"d);
    mat4.glPerspective(45, 9 / 16.0f, 2, 125).writeln;
    hr('─', "Orthographic"d);
    mat4.glOrtho(9, 20, 20, 12, 2, 50).writeln;
    hr('─', "LookAt"d);
    mat4.glLookAt(vec3(0, 2, 5), vec3(1, 20, 1), vec3(0.5f, 1, 0)).writeln;
    hr('─', "Mat from quat"d);
    mat4(quat(0.25, 2, 4, 0.1)).writeln;
    hr('─', "Mat proj inv"d);
    (~(mat4.glPerspective(45, 9.0f / 16.0f, 2.0f, 125.0f))).writeln;
    hr('─', "View * Proj"d);
    (mat4.glLookAt(vec3(0, 2, 5), vec3(1, 20, 1), vec3(0.5f, 1, 0)) *
    mat4.glPerspective(0.78f, 9 / 16.0f, 2, 125)).writeln;

    // writeln("isMat!(mat2) ", isMatrix!(mat2));
    // writeln("isMat!(float) ", isMatrix!(float));
    // writeln("isMat!(mat2, 2, 2) ", isMatrix!(mat2, 2, 2));
    // writeln("isMat!(mat2, 3, 2) ", isMatrix!(mat2, 3, 2));
    // writeln("isMat!(float, 2, 2) ", isMatrix!(float, 2, 2));
    // writeln("isMat!(mat2, float) ", isMatrix!(mat2, float));
    // writeln("isMat!(mat2, int) ", isMatrix!(mat2, int));
    // writeln("isMat!(float, float) ", isMatrix!(float, float));
    // writeln("isMat!(mat2, float, 2, 2) ", isMatrix!(mat2, float, 2, 2));
    // writeln("isMat!(mat2, float, 3, 2) ", isMatrix!(mat2, float, 3, 2));
    // writeln("isMat!(mat2, int, 2, 2) ", isMatrix!(mat2, int, 2, 2));
    // writeln("isMat!(float, float, 2, 2) ", isMatrix!(float, float, 2, 2));

    // LINK: https://www.andre-gaschler.com/rotationconverter/
}

string makePretty(T)(T[][] data) {
    size_t H = data.length;
    size_t W = data[0].length;
    import std.conv : to;
    import std.traits;
    import std.format;
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



