module sily.dlib.vector;

import dlib.math.matrix;
import dlib.math.vector;
import dlib.math.transformation;
import dlib.math.quaternion;
import dlib.math.utils;

import std.math;

// LINK https://gecko0307.github.io/dlib/docs/dlib.html

/** 
* Rotates `vec` around `axis` by `theta`
* Params:
*   v = Vector to rotate
*   x = Rotation axis
*   theta = Angle to rotate in radians
* Returns: Rotated vector
*/
Vector!(T, 3) rotated(T: float)(Vector!(T, 3) v, Vector!(T, 3) x, T theta) {
    T cos_theta = cos(theta);
    T sin_theta = sin(theta);
    Vector!(T, 3) rot = (v * cos_theta) + (cross(x, v) * sin_theta) + (x * dot(x, v)) * (1 - cos_theta);
    return rot;
}

/** 
* Rotates `vec` around `axis` by `theta`
* Params:
*   v = Vector to rotate
*   x = Rotation axis
*   theta = Angle to rotate in degrees
* Returns: Rotated vector
*/
Vector!(T, 3) rotatedDegrees(T: float)(Vector!(T, 3) vec, Vector!(T, 3) axis, T deg) {
    return rotated(vec, axis, degtorad(deg));
}