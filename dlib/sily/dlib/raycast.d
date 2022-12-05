module sily.dlib.raycast;

// TODO raycast

import dlib.math.vector;
import dlib.geometry.triangle;

struct RayIntersection {
    vec3 collisionPoint = vec3(0.0f, 0.0f, 0.0f);
    bool isColliding = false;
}

/** 
Params:
  origin = origin point of collision vector
  target = target point of collision vector
  triangle = triangle to intersect
Returns: `RayIntersection` struct containing intersection results
 */
RayIntersection rayIntersectTriangle(vec3 origin, vec3 target, Triangle triangle) {
    const float eps = float.epsilon;

    vec3 v0 = triangle.v[0];
    vec3 v1 = triangle.v[1];
    vec3 v2 = triangle.v[2];

    vec3 edge1, edge2, h, s, q;
    float a, f, u, v;

    edge1 = v1 - v0;
    edge2 = v2 - v0;

    h = target.cross(edge2);
    a = edge1.dot(h);

    if (a > -eps && a < eps) {
        // ray is parallel
        return RayIntersection();
    }

    f = 1.0 / a;
    s = origin - v0;
    u = f * s.dot(h);

    if (u < 0.0f || u > 1.0f) {
        return RayIntersection();
    }

    q = s.cross(edge1);
    v = f * target.dot(q);

    if (v < 0.0 || u + v > 1.0f) {
        return RayIntersection();
    }

    float t = f * edge2.dot(q);

    if (t > eps) {
        return RayIntersection(origin + target * t, true);
    }

    return RayIntersection();
}

RayStaticResult rayCast(vec3 origin, vec3 normal, float dist, bool doDraw = false) {
    bool isBlock = false;
    // TODO ask world for block
    float step = 0.1f;
    vec3 pos = origin;
    for (int i = 0; i < dist; i++) {
        // TODO ask for block here 
        if (isBlock) {
            return RayStaticResult(
                pos, pos, 
                vec3(1.0f, 1.0f, 1.0f),
                normal, true
            );
        }
        pos += normal * step;
    }
    
    return RayStaticResult();
}

struct RayStaticResult {
    vec3 point;
    vec3 blockCenter;
    vec3 blockSize;
    vec3 hitNormal;
    bool isHit = false;
}

RayStaticResult rayIntersectStatic(vec3 origin, vec3 normal, float dist, bool doDraw = false) {
    return RayStaticResult();
}

RayStaticResult doStaticRaycast(vec3 origin, vec3 normal, float dist, vec3 corner, vec3 step, bool doDraw = false) {
    vec3 blockCenter = corner - (vec3(0.5f) * step);
    if (doDraw) {
        // TODO draw
    } 

    return RayStaticResult();
}

// LINK https://github.com/codingminecraft/StreamMinecraftClone
// LINK https://github.com/codingminecraft/StreamMinecraftClone/blob/master/Minecraft/src/physics/Physics.cpp

