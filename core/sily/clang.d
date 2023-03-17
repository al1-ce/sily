/// Utilities to work with C bindings (e.g. OpenGL, SDL)
module sily.clang;

// TODO replace with template mixin csizeof!(Type, Size) => csizeof(Type[][][]...)
/// Returns C style size
template csizeof(T, alias S = uint) {
    /// Returns C style size
    S csizeof(int var) {
        return cast(S) (var * int.sizeof);
    }
    /// Ditto
    S csizeof(T[] var) {
        return cast(S) (var.length * T.sizeof);
    }
    /// Ditto
    S csizeof(T[][] var) {
        return cast(S) (var[0].length * var.length * T.sizeof);
    }
    /// Ditto
    S csizeof(T[][][] var) {
        return cast(S) (var[0][0].length * var[0].length * var.length * T.sizeof);
    }
}
