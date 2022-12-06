/// Utilities to work with C bindings (e.g. OpenGL, SDL)
module sily.clang;

// TODO replace with template mixin csizeof!(Type, Size) => csizeof(Type[][][]...)
/// Returns C style size
template csizeof(T) {
    /// Returns C style size
    uint csizeof(int var) {
        return (var * int.sizeof).to!uint;
    }
    /// Ditto
    uint csizeof(T[] var) {
        return (var.length * T.sizeof).to!uint;
    }
    /// Ditto
    uint csizeof(T[][] var) {
        return (var[0].length * var.length * T.sizeof).to!uint;
    }
    /// Ditto
    uint csizeof(T[][][] var) {
        return (var[0][0].length * var[0].length * var.length * T.sizeof).to!uint;
    }
}
