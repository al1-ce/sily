#!/usr/bin/env dub
/+ dub.sdl:
name "vectortest"
dependency "sily" path="../"
targetType "executable"
targetPath "../bin/"
+/

import std.stdio: writeln;
import sily.color;
import sily.vector;
import sily.matrix;
import sily.quat;

void main() {
    // Vector can be constructed manually or with aliases
    auto v1 = Vector!(int, 2)(10, 20);
    writeln("Vector!(int, 2)(10, 20): ", v1);
    auto v2 = ivec2(10, 20);
    writeln("ivec2(10, 20): ", v2);
    auto v3 = Vector!(int, 2)(10, 20);
    writeln("Vector!(int, 2)(10, 20): ", v3);
    auto v4 = Vector!(int, 2)(10, 20);
    writeln("Vector!(int, 2)(10, 20): ", v4);
    // Also vector can be given only one value,
    // in that case it'll be filled with that value
    auto v5 = ivec4(13);
    writeln("ivec4(13): ", v5);
    auto v6 = vec4(0.3f, 0.2f, 0.1f, 0.0f);
    writeln("vec4(0.3f, 0.2f, 0.1f, 0.0f): ", v6);
    // Vector values can be accessed with array slicing,
    // by using color symbols or swizzling
    float v6x = v6.x;
    writeln("v6.x: ", v6x);
    float v6z = v6.z;
    writeln("v6.z: ", v6z);
    float[] v6yzx = v6.yzx;
    writeln("v6.yzx: ", v6yzx);
    auto rvec7 = Vector!(real, 7)(10);
    writeln("Vector!(real, 7)(10): ", rvec7);
    auto rvec7s = rvec7.VecType(20);
    writeln("rvec7.VecType(20): ", rvec7s);
    col c = col(3, 4, 1, 2);
    writeln("col(3, 4, 1, 2): ", c);
    col d = c.brg;
    writeln("c.brg: ", d);
    col g = Colors.aquamarine;
    writeln("Colors.aquamarine: ", g);
    vec4 v = d;
    writeln("d: ", v);
    vec4 e = v.xyyz;
    writeln("v.xyyz: ", e);
    auto v7 = v2 + v3 * v1 / v1 - v4 * 0 + v4 / 2 - -v4 + (v2 + 1) + (v2 - 1);
    writeln("v2 + v3 * v1 / v1 - v4 * 0 + v4 / 2 - -v4 + (v2 + 1) + (v2 - 1): ", v7);
    writeln("v7 > v4: ", v7 > v4);
    writeln("v7 >= v4: ", v7 >= v4);
    writeln("v7 < v4: ", v7 < v4);
    writeln("v7 <= v4: ", v7 <= v4);
    writeln("v7 == v4: ", v7 == v4);
    writeln("v7 != v4: ", v7 != v4);
    writeln("vec2(-1.0f).abs: ", vec2(-1.0f).abs);
    writeln("vec2(-1.2f).ceil: ", vec2(-1.2f).ceil);
    writeln("vec2(-1.0f).clamp(vec2(-0.5f), vec2(0.0f)): ", vec2(-1.0f).clamp(vec2(-0.5f), vec2(0.0f)));
    writeln("vec2(-1.0f).copyof: ", vec2(-1.0f).copyof);
    writeln("vec2(-1.0f).distanceSquaredTo(vec2(1.0f)): ", vec2(-1.0f).distanceSquaredTo(vec2(1.0f)));
    writeln("vec2(-1.0f).distanceTo(vec2(1.0f)): ", vec2(-1.0f).distanceTo(vec2(1.0f)));
    writeln("vec2(-1.0f).dot(vec2(-0.5f)): ", vec2(-1.0f).dot(vec2(-0.5f)));
    writeln("vec2(-1.5f).floor: ", vec2(-1.5f).floor);
    writeln("vec2(-1.0f).isClose(vec2(-1.00000002f)): ", vec2(-1.0f).isClose(vec2(-1.00000002f)));
    writeln("vec2(-1.0f).isNormalized: ", vec2(-1.0f).isNormalized);
    writeln("vec2(-1.0f).length: ", vec2(-1.0f).length);
    writeln("vec2(-1.0f).data.length: ", vec2(-1.0f).data.length);
    writeln("vec2(-1.0f).lengthSquared: ", vec2(-1.0f).lengthSquared);
    writeln("vec2(-1.0f).lerp(vec2(1.0f), 0.5f): ", vec2(-1.0f).lerp(vec2(1.0f), 0.5f));
    // writeln("vec2(-1.0f).limitLength(0.5f): ", vec2(-1.0f).limitLength(0.5f));
    writeln("vec2(-1.0f).max(vec2(1.0f)): ", vec2(-1.0f).max(vec2(1.0f)));
    writeln("vec2(-1.0f).min(vec2(-2.0f)): ", vec2(-1.0f).min(vec2(-2.0f)));
    writeln("vec2(-1.0f).normalize: ", vec2(-1.0f).normalize);
    writeln("vec2(-1.0f).normalized: ", vec2(-1.0f).normalized);
    writeln("vec2(-1.5f).round: ", vec2(-1.5f).round);
    writeln("vec2(-15.0f).sign: ", vec2(-15.0f).sign);
    writeln("vec2(-1.19f).snap(vec2(0.25f)): ", vec2(-1.19f).snap(vec2(0.25f)));
    writeln("cast(ivec2) vec2(-15.0f): ", cast(ivec2) vec2(-15.0f));
    writeln("cast(ivec3) dvec3(-15.0, 10.0, 0.0): ", cast(ivec3) dvec3(-15.0, 10.0, 0.0));
    writeln("cast(dvec3) ivec3(-15, 10, 0): ", cast(dvec3) ivec3(-15, 10, 0));
    writeln("cast(bool) vec2(-15.0f): ", cast(bool) vec2(-15.0f));
    writeln("cast(bool) ivec2(-15): ", cast(bool) ivec2(-15));
    writeln("cast(bool) ivec2(0): ", cast(bool) ivec2(0));
    writeln("cast(col) vec3(0.2f, 0.5f, 0.3f): ", cast(col) vec3(0.2f, 0.5f, 0.3f));
    writeln("cast(col) vec4(0.2f, 0.5f, 0.3f, 0.2f): ", cast(col) vec4(0.2f, 0.5f, 0.3f, 0.2f));
    writeln("cast(col) ivec3(12, 10, 200): ", cast(col) ivec3(12, 10, 200));
    writeln("cast(col) ivec4(12, 10, 200, 125): ", cast(col) ivec4(12, 10, 200, 125));
    writeln("cast(col) ivec3(12, 10, 200): ", cast(col) ivec3(12, 10, 200));
    writeln("cast(col) ivec4(12, 10, 200, 125): ", cast(col) ivec4(12, 10, 200, 125));
    writeln("cast(ivec3) Color8(12, 10, 200): ", cast(ivec3) Color8(12, 10, 200));
    writeln("cast(vec4) Color8(12, 10, 200, 125): ", cast(vec4) Color8(12, 10, 200, 125));
    writeln("cast(vec4) col(0.2f, 0.5f, 0.3f): ", cast(vec4) col(0.2f, 0.5f, 0.3f));
    writeln("cast(vec3) col(0.2f, 0.5f, 0.3f): ", cast(vec3) col(0.2f, 0.5f, 0.3f));
    writeln("cast(vec3) col(0.2f, 0.5f, 0.3f, 0.2f): ", cast(vec3) col(0.2f, 0.5f, 0.3f, 0.2f));
    writeln("cast(ivec4) col(0.2f, 0.5f, 0.3f, 0.2f): ", cast(ivec4) col(0.2f, 0.5f, 0.3f, 0.2f));
    writeln("cast(bool) col(0.2f, 0.5f, 0.3f, 0.2f): ", cast(bool) col(0.2f, 0.5f, 0.3f, 0.2f));
    writeln("cast(bool) col(0, 0): ", cast(bool) col(0, 0));
    writeln("isVector!(vec2): ", isVector!(vec2));
    writeln("isVector!(float): ", isVector!(float));
    writeln("isVector!(vec2, float): ", isVector!(vec2, float));
    writeln("isVector!(vec2, int): ", isVector!(vec2, int));
    writeln("isVector!(float, float): ", isVector!(float, float));
    writeln("isVector!(vec2, 2): ", isVector!(vec2, 2));
    writeln("isVector!(vec2, 3): ", isVector!(vec2, 3));
    writeln("isVector!(float, 3): ", isVector!(float, 3));
    writeln("isVector!(vec2, float, 2): ", isVector!(vec2, float, 2));
    writeln("isVector!(vec2, float, 3): ", isVector!(vec2, float ,3));
    writeln("isVector!(vec2, int, 2): ", isVector!(vec2, int, 2));
    writeln("isVector!(float, float 2): ", isVector!(float, float, 2));
    writeln("ivec3(1, 2, 3).cross(ivec3(1, 5, 7)): ", ivec3(1, 2, 3).cross(ivec3(1, 5, 7)));
    writeln("~vec3(1, 2, 3): ", ~vec3(1, 2, 3));
    writeln("~ivec3(1, 2, 3): ", ~ivec3(1, 2, 3));
    writeln(mat4.glPerspective(45, 9.0f / 16.0f, 2.0f, 125.0f).toStringPretty);
    writeln();
    writeln(mat4.glLookAt(vec3(0, 2, 5), vec3(1, 20, 1), vec3(0.5f, 1, 0)).toStringPretty);
    writeln("quat * quat: ", quat(1, 2, 3, 4) * quat(1, 5, 2, 1));
    writeln("quat mat X: ", quat(mat4.rotationX(0.25f)));
    writeln("quat mat Y: ", quat(mat4.rotationY(0.25f)));
    writeln("quat mat Z: ", quat(mat4.rotationZ(0.25f)));
    writeln("quat mat A: ", quat(mat4.rotation(vec3(0.2, 0, 1.4), 0.25f)));
    writeln("quat inv : ", ~quat(0.2, 0, 1.4, 0.5));
    writeln("unproj: ", vec3(1, 2, 3)
            .unproject(
                mat4.glPerspective(45, 9.0f / 16.0f, 2.0f, 125.0f), 
                mat4.glLookAt(vec3(0, 2, 5), vec3(1, 20, 1), vec3(0.5f, 1, 0))
                ), " == [-2.47, 0.02, 5.00]");
    
    mat4 proj = mat4.glPerspective(45, 9.0f / 16.0f, 2.0f, 125.0f);
    mat4 view = mat4.glLookAt(vec3(0, 2, 5), vec3(1, 20, 1), vec3(0.5f, 1, 0));
    mat4 vpnorm = (view * proj);
    mat4 vpinv = ~vpnorm;
    quat qt = [1.0f, 2.0f, 3.0f, 1.0f];
    quat qtrs = qt * vpinv;

    proj.writeln("\n");
    view.writeln("\n");
    vpnorm.writeln("\n");
    vpinv.writeln("\n");
    (vpnorm * vpinv).writeln("\n");
    qt.writeln("\n");
    qtrs.writeln("\n");

    writeln(vec3(quat(vec3(10, 12, 5))));
    writeln(vec3(1, 10, -1) * vpinv);
    writeln(vec4(1, 10, -1, 1) * vpinv);
    writeln(vpinv * vec3(1, 10, -1));
    writeln(vpinv * vec4(1, 10, -1, 1));

    writeln(col(1, 2, 3, 4).rgaabargb);

    writeln("limitlen(vec, 0, 2)", vec3(1, 12, 2).limitLength(0, 2));
    writeln("limitlen(vec, 0, 2)", vec3(1, 12, 2).limitLength(0, 2).length());
    writeln("limitlen(vec, 16, 9999)", vec3(1, 12, 2).limitLength(2, 0));
    writeln("limitlen(vec, 16, 9999)", vec3(1, 16, 2).limitLength(2, 0).length());

    writeln("Completed");
}
