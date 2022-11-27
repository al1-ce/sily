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

/** 
* Fills array with values `val` up to `size` if it's not 0
* Params:
*   arr = array to fill
*   val = values to fill with
*   size = amount of pos to fill
* Returns: filled array
*/
T[] fill(T)(T[] arr, T val){

    arr = arr.dup;

    for (int i = 0; i < arr.length; i ++) {
        arr[i] = val;
    }

    return arr;
}
