module sily.array;

/** 
 * 
 * Params:
 *   val = Value to check
 *   vals = Array or sequence of values to check against
 * Returns: if `val` is one of `vals`
 */
bool isOneOf(T)(T val, T[] vals ...) {
    foreach (T i; vals) {
        if (val == i) return true;
    }
    return false;
}