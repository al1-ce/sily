module sily.opengl.vertex.vao;

import bindbc.opengl;

import sily.opengl.vertex;

import sily.clang;
import sily.ptr;

struct VAO {
    private uint _id;
    private uint _len = 1;

    @disable this();

    this(uint len) {
        _len = len;
        glGenVertexArrays(_len, &_id);
    }

    public uint id() {
        return _id;
    }

    /** 
     * 
     * Params:
     *   vbo = VBO to link attribute of
     *   layout = Position of attribute in array. `layout (location = %layout%)` in shader
     *   numComponents = Number of elements of array to use for attribute (e.g. 3 for vec3)
     *   dataType = Type of data in array
     *   stride = How much elements will be in the end (e.g. pos + col + uv = 3 + 3 + 2)
     *   offset = How much array elements preceeds this attribute. Recommended to use `csizeof!T(len).vptr`
     */
    public void linkAttribute(VBO vbo, uint layout, int numComponents, 
                              GLenum dataType, int stride, const void* offset) {
        bind();
        vbo.bind();
        glVertexAttribPointer(layout, numComponents, dataType, GL_FALSE, stride, offset);
        glEnableVertexAttribArray(layout); 
        unbind();
        vbo.unbind();
    }

    private const int attrSize = 3 + 3 + 2 + 3;
    // For 2D textures it's always should be:
    // XYZ RGB UV
    public void linkTex2Dpos(VBO vbo) {
        linkAttribute(vbo, 0, 3, GL_FLOAT, csizeof!float(attrSize), csizeof!float(0).vptr);
    }

    public void linkTex2Dcol(VBO vbo) {
        linkAttribute(vbo, 1, 3, GL_FLOAT, csizeof!float(attrSize), csizeof!float(3).vptr);
    }

    public void linkTex2DtexPos(VBO vbo) {
        linkAttribute(vbo, 2, 2, GL_FLOAT, csizeof!float(attrSize), csizeof!float(6).vptr);
    }

    public void linkTex2Dnorm(VBO vbo) {
        linkAttribute(vbo, 3, 3, GL_FLOAT, csizeof!float(attrSize), csizeof!float(8).vptr);
    }

    // public void linkTex2DtexIdx(VBO vbo) {
    //     linkAttribute(vbo, 3, 1, GL_FLOAT, csizeof!float(9), csizeof!float(7).vptr);
    // }

    public void linkTex2Ddefault(VBO vbo) {
        linkTex2Dpos(vbo);
        linkTex2Dcol(vbo);
        linkTex2DtexPos(vbo);
        linkTex2Dnorm(vbo);
        // linkTex2DtexIdx(vbo);
    }

    public void bind() {
        glBindVertexArray(_id);
    }

    public void unbind() {
        glBindVertexArray(0);
    }

    public void dispose() {
        glDeleteVertexArrays(_len, &_id);
    }

    public void disableAttribute(uint layout) {
        glEnableVertexAttribArray(layout); 
    }

    public void bindBuffer(VBO vbo) {
        bind();
        vbo.bind();
        unbind();
        vbo.unbind();
    }

    public void bindBuffer(EBO ebo) {
        bind();
        ebo.bind();
        unbind();
        ebo.unbind();
    }

    public void bindBuffer(VBO vbo, EBO ebo) {
        bind();
        ebo.bind();
        vbo.bind();

        unbind();
        ebo.unbind();
        vbo.unbind();
    }
}
