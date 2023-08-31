/++
Enum utils
+/
module sily.meta.enums;

/++
Expands enum into single members
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
