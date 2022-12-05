module sily.dlib.transform;

import dlib.math.matrix;
import dlib.math.vector;
import dlib.math.transformation;
import dlib.math.quaternion;
import dlib.math.utils;

class Transform {
    private Matrix4f _transformMat;

    private vec3 _position;
    private vec3 _scaling;
    private Quaternionf _rotation;

    this() {
        _transformMat = Matrix4f().identity();

        _position = vec3(0, 0, 0);
        _scaling = vec3(1, 1, 1);
        _rotation = Quaternionf().identity();
    }

    public void parent(Transform tr) {

    }

    public void update() {
        // always scale -> rotation -> translation
        // _transformMat = _scaleMat * _rotationMat * _translationMat;
    }

    public void position(vec3 pos) {
        _position = pos;
    }

    public vec3 position() {
        return _position;
    }

    public void scaling(vec3 p_scale) {
        _scaling = p_scale;
    }

    public vec3 scaling() {
        return _scaling;
    }

    public void rotation(Quaternionf rot) {
        _rotation = rot;
    }

    public Quaternionf rotation() {
        return _rotation;
    }

    // public Matrix4f generateMat4() {
    //     // _translationMat = translationMatrix(_position);
    //     // _rotationMat = rotationMatrix(Axis.y, 0.0f);
    //     // _transformMat = _translationMat * _scaleMat * _rotationMat;
    //     // return _transformMat;
    // }

    void updateTransformation() {
        // prevTransformation = transformation;

        _transformMat =
            translationMatrix(_position) *
            _rotation.toMatrix4x4 *
            scaleMatrix(_scaling);
        
        // updateAbsoluteTransformation();
    }

    vec3 direction() {
        return forward(_transformMat);
    }

    // vec3 right() {
    //     return right(_transformMat);
    // }

    // vec3 up() {
    //     return right(_transformMat);
    // }

    public final void translate(vec3 offset) {
        _position += offset;
    }

    public final void scale(vec3 offset) {
        // transform.position = transform.position + offset;
    }
    
    /** 
    Set rotation
    Params:
      v = Vector (degrees)
     */
    void setRotation(vec3 v) {
        _rotation =
            rotationQuaternion!float(Axis.x, degtorad(v.x)) *
            rotationQuaternion!float(Axis.y, degtorad(v.y)) *
            rotationQuaternion!float(Axis.z, degtorad(v.z));
    }

    /** 
    Set rotation
    Params:
      x = x angle degrees
      y = y angle degrees
      z = z angle degrees
     */
    void setRotation(float x, float y, float z) {
        setRotation(vec3(x, y, z));
    }

    /** 
    Rotate by Vector
    Params:
      v = Vector (degrees)
     */
    void rotate(vec3 v) {
        auto r =
            rotationQuaternion!float(Axis.x, degtorad(v.x)) *
            rotationQuaternion!float(Axis.y, degtorad(v.y)) *
            rotationQuaternion!float(Axis.z, degtorad(v.z));
        _rotation *= r;
    }

    /** 
    Rotate by Vector
    Params:
      x = x angle degrees
      y = y angle degrees
      z = z angle degrees
     */
    void rotate(float x, float y, float z) {
        rotate(vec3(x, y, z));
    }

    /** 
    Look up/down
    Params:
      angle = angle in degrees
     */
    void pitch(float angle) {
        _rotation *= rotationQuaternion!float(Axis.x, degtorad(angle));
    }

    /** 
    Look left/right
    Params:
      angle = angle in degrees
     */
    void turn(float angle) {
        _rotation *= rotationQuaternion!float(Axis.y, degtorad(angle));
    }

    /** 
    Tilt left/right
    Params:
      angle = angle in degrees
     */
    void roll(float angle) {
        _rotation *= rotationQuaternion!float(Axis.z, degtorad(angle));
    }

    // TODO do full transform class
    // LINK https://github.com/gecko0307/dagon/blob/master/src/dagon/graphics/entity.d
    // LINK https://learnopengl.com/Getting-started/Transformations
}
