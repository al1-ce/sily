/// Partial alternative to std.uni
module sily.uni;

import std.traits: isSomeChar;

/**
Checks if `c` is letter
Params:
  c = char
Returns: isAlpha
*/
bool isAlpha(T)(T c) if (isSomeChar!T) {
    return  (c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z');
}

/**
Checks if `c` is letter or digit
Params:
  c = char
Returns: isAlphaNumeric
 */
bool isAlphaNumeric(T)(T c) if (isSomeChar!T) {
    return isAlpha(c) || isDigit(c);
}

/**
Checks if `c` is digit
Params:
  c = char
Returns: isDigit
 */
bool isDigit(T)(T c) if (isSomeChar!T) {
    return c >= '0' && c <= '9';
}

/**
Checks if `c` is hexadecimal (all digits & letters from A to F)
Params:
  c = char
Returns: isHex
 */
bool isHex(T)(T c) if (isSomeChar!T) {
    return (c >= '0' && c <= '9') ||
           (c >= 'a' && c <= 'f') ||
           (c >= 'A' && c <= 'F');
}

/**
Checks if `c` is octal number (0 <= c <= 7)
Params:
  c = char
Returns: isOct
 */
bool isOct(T)(T c) if (isSomeChar!T) {
    return (c >= '0' && c <= '7');
}

