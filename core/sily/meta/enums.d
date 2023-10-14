/++
Enum utils
+/
module sily.meta.enums;

import std.uni: isUpper, toUpper, isAlphaNum;

/++
Expands enum into single members, keeps case
Example:
---
enum Elements {
    One,
    Two,
    Three,
    Four
}
mixin(expandEnum!Elements);
/// Is going to be turned into
enum {
    One = Elements.One,
    Two = Elements.Two,
    Three = Elements.Three,
    Four = Elements.Four
}
/// And can be used as single value
void main() {
    import std.stdio;
    /// Both are valid
    writeln(One);
    writeln(Elements.One);
}
---
+/
enum expandEnum(EnumType, string fqnEnumType = EnumType.stringof) = (){
    string expandEnum = "enum {";
    foreach(m;__traits(allMembers, EnumType)) {
        expandEnum ~= m ~ " = " ~ fqnEnumType ~ "." ~ m ~ ",";
    }
    expandEnum  ~= "}";
    return expandEnum;
}();

/++
Expands enum into single members, transforms members to CAMEL_CASE with "_" on case change, see example
Example:
---
enum Elements {
    One,
    Two,
    Three,
    Four,
    FifthElement,
    ELEMENT_FIVE,
    ElementWith_Separation,
    E1emen7Number,
    E1emen7number,
}
mixin(expandEnumUpper!Elements);
/// Is going to be turned into
enum {
    ONE = Elements.One,
    TWO = Elements.Two,
    THREE = Elements.Three,
    FOUR = Elements.Four
    FIFTH_ELEMENT = Elements.FifthElement,
    ELEMENT_FIVE = Elements.ELEMENT_FIVE,
    ELEMENT_WITH_SEPARATION = Elements.ElementWith_Separation,
    E1EMEN7_NUMBER = Elements.E1emen7Number,
    E1EMEN7NUMBER = Elements.E1emen7number,
}
/// And can be used as single value
void main() {
    import std.stdio;
    /// Both are valid
    writeln(One);
    writeln(Elements.One);
}
---
+/
enum expandEnumUpper(EnumType, string fqnEnumType = EnumType.stringof) = (){
    string expandEnum = "enum {";
    foreach(string member; __traits(allMembers, EnumType)) {
        string newMember = "";
        bool prevUpper = false;
        for (int i = 0; i < member.length; ++i) {
            if (member[i].isUpper && !prevUpper && i != 0) {
                newMember ~= "_";
            }
            newMember ~= member[i].toUpper();
            prevUpper = member[i].isUpper || !member[i].isAlphaNum;
        }
        expandEnum ~= newMember ~ " = " ~ fqnEnumType ~ "." ~ member ~ ",";
    }
    expandEnum  ~= "}";
    return expandEnum;
}();