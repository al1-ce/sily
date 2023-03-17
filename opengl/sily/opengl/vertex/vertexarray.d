module sily.opengl.vertex.vertexarray;

import bindbc.opengl;

import sily.opengl.vertex;

import sily.clang;
import sily.ptr;

struct VertexArray {
    private VBO _vbo;
    private VAO _vao;
    private EBO _ebo;

    this(float* vertices, uint vertSize, uint* indices, uint indSize) {
        _vao = VAO(1);
        _vbo = VBO(vertices, vertSize);
        _ebo = EBO(indices, indSize);
        _vao.bindBuffer(_vbo, _ebo);
    }

    this(float[] vertices, uint[] indices) {
        _vao = VAO(1);
        _vbo = VBO(vertices.ptr, csizeof!float(vertices));
        _ebo = EBO(indices.ptr, csizeof!uint(indices));
        _vao.bindBuffer(_vbo, _ebo);
    }

    public void linkAttribute(uint layout, int numComponents, GLenum dataType, int stride, void* offset) {
        _vao.bind();
        _vao.linkAttribute(_vbo, layout, numComponents, dataType, stride, offset);
        _vao.unbind(); 
    }

    public void linkTex2Ddefault() {
        _vao.linkTex2Ddefault(_vbo);
    }

    public void render(GLenum type, int vertAmmount) {
        _vao.bind();

        // last 0 is used if ebo is not in use 
        glDrawElements(type, vertAmmount, GL_UNSIGNED_INT, cast(GLvoid*) 0);
        _vao.unbind();
    }

    // public void renderTexture2D(GLenum type, int vertAmmount, Texture2D tex) {
    //     glEnable(GL_BLEND);
    //     glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //
    //     _vao.bind();
    //     tex.bind();
    //
    //     // last 0 is used if ebo is not in use 
    //     glDrawElements(type, vertAmmount, GL_UNSIGNED_INT, cast(GLvoid*) 0);
    //
    //     _vao.unbind();
    //     tex.unbind();
    // }

    public void dispose() {
        _vbo.dispose();
        _vao.dispose();
        _ebo.dispose();
    }

    public VBO vbo() { return _vbo; }
    public VAO vao() { return _vao; }
    public EBO ebo() { return _ebo; }
}

