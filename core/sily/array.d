/// Small array utils
module sily.array;

/** 
Params:
  val = Value to check
  vals = Array or sequence of values to check against
Returns: If `val` is one of `vals`
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