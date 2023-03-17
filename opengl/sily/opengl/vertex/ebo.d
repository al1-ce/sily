module sily.opengl.vertex.ebo;

import bindbc.opengl;

import sily.clang;
import sily.ptr;

struct EBO {
    private uint _id;
    private uint _len = 1;

    this(uint* indices, uint size, uint len = 1) {
        glGenBuffers(len, &_id);
        bind();
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, indices, GL_STATIC_DRAW);
        unbind();
        _len = len;
    }

    @disable this();
    
    this(uint len) {
        _len = len;
        glGenBuffers(_len, &_id);
    }

    public uint id() {
        return _id;
    }

    public void linkData(uint size, float* data, GLenum mode = GL_STATIC_DRAW) {
        bind();
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, data, mode);
        unbind();
    }

    public void linkSubData(uint size, uint offset, float* data) {
        bind();
        glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, size, data);
        unbind();
    }

    public void bind() {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _id);
    }

    public void unbind() {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    public void dispose() {
        glDeleteBuffers(_len, &_id);
    }
}
