/++
UID (Unique IDentifier) generator
+/
module sily.uid;

import std.datetime;
import std.format;

import sily.math;
import sily.random;

private ulong _inc = 0;
private ulong _seed = 0;
private const uint _uintMin = 1_000_000_000u;
private const ulong _ulongMin = 1_000_000_000_000_000_000_0u;
private const ulong _uidMask = 0x7FFFFFFFF;

// TODO: better look up algorithms

static this() {
    seedUID(Clock.currTime.stdTime);
}

/// Sets/Returns current seed
void seedUID(ulong seed) {
    _seed = (((seed & _uidMask) + (seed >> 42 & _uidMask)) + seed + (~seed << 42));
    // _seed = 123456789;
}
/// Ditto
ulong seedUID() {
    return _seed;
}

/// Skips N amount of UID's
void skipUID(size_t count = 1) {
    _inc += count;
}

/// Generates 32 bit uid
uint generateUID() {
    uint _out = 0;
    ulong _tmp = _uintMin + _seed + (_inc * 0x00_10_42_1F);
    // 11_22_33_44 -> 22_44_11_33
    _out += (_tmp & 0x00_00_00_FF) << 16;
    _out += (_tmp & 0x00_00_FF_00) >> 8;
    _out += (_tmp & 0x00_FF_00_00) << 8;
    _out += (_tmp & 0xFF_00_00_00) >> 16;
    if (_out < _uintMin) _out += _uintMin;
    ++_inc;
    return _out;
}

/// Generates 64 bit uid
ulong generateLongUID() {
    ulong _out = 0;
    ulong _tmp = _uintMin + _seed + (_inc * 0x00_00_01_0C_20_10_42_1F);
    // 11_22_33_44_55_66_77_88 -> // 22_44_11_88_66_77_55_33
    _out += (_tmp & 0x00_00_00_00_00_00_00_FF) << 32;
    _out += (_tmp & 0x00_00_00_00_00_00_FF_00) << 8;
    _out += (_tmp & 0x00_00_00_00_00_FF_00_00) << 8;
    _out += (_tmp & 0x00_00_00_00_FF_00_00_00) >> 16;
    _out += (_tmp & 0x00_00_00_FF_00_00_00_00) << 16;
    _out += (_tmp & 0x00_00_FF_00_00_00_00_00) >> 40;
    _out += (_tmp & 0x00_FF_00_00_00_00_00_00) << 8;
    _out += (_tmp & 0xFF_00_00_00_00_00_00_00) >> 16;
    if (_out < _uintMin) _out += _uintMin;
    ++_inc;
    return _out;
}

/// Returns hex string of 32 bit uid (8 letters)
string genStringUID() {
    return format("%x", generateUID());
}

/// Returns hex string of 64 bit uid (16 letters)
string genLongStringUID() {
    return format("%x", generateLongUID());
}

