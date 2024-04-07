/// Small array utils
module sily.array;

import std.traits: isArray;
import std.algorithm: map, each;
import std.range: ElementType;
import std.array: array;

/**
Returns true if `val` is one of `vals`
Params:
  val = Value to check
  vals = Array or sequence of values to check against
*/
bool isOneOf(T)(T val, T[] vals ...) {
    foreach (T i; vals) {
        if (val == i) return true;
    }
    return false;
}

/**
Fills array with values `val` up to `size` if it's not 0
Params:
  arr = Array to fill
  val = Values to fill with
Returns: Filled array
*/
T[] fill(T)(T[] arr, T val){

    arr = arr.dup;

    for (int i = 0; i < arr.length; i ++) {
        arr[i] = val;
    }

    return arr;
}

/**
Fills and returns new array with values `val` up to `size`
Params:
  val = Values to fill with
  size = Amount of pos to fill
Returns: Filled array
*/
T[] fill(T)(T val, size_t size){
    T[] arr = new T[](size);

    for (int i = 0; i < size; i ++) {
        arr[i] = val;
    }

    return arr;
}
/// Ditto
alias repeat = fill;

/// Returns product of all lengths of array ([[1, 2, 3], [1, 3]].deepLength -> 6)
size_t deepLength(T)(T arr) if (isArray!T) {
    static if (isArray!(ElementType!T)) {
        size_t r = arr.length;
        size_t m = 0;
        // arr.map!(a => a.deepLength).array.each!(n => m = r > m ? r : m);
        foreach (a; arr) {
            size_t s = deepLength(a);
            if (s > m) m = s;
        }
        r = r * m;
        return r;
    } else {
        return arr.length;
    }
}


/// Returns base type of array (int[3][2][5] -> int)
template ArrayBaseType(T) {
    static if (isArray!(ElementType!T)) {
        alias ArrayBaseType = ArrayBaseType!(ElementType!T);
    } else {
        alias ArrayBaseType = ElementType!T;
    }
}
