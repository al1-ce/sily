// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/++
Random number generation utils
+/
module sily.random;

import std.math;
import std.random: StdRandom = Random, unpredictableSeed;
import std.algorithm.comparison;
import std.conv: to;
import std.datetime: Clock;
import std.traits: isFloatingPoint;


/++
Random number generator
Example:
---
// Creates rng with default seed
RNG rng = RNG();
// Creates rng with custom seed
rng = RNG(2511244);
// Assigns random seed to seed
rng.randomize();
// Returns random uint
rnd.random();
// Returns random float in range of 0..float.max
randf();
// Returns random float in rangle of 4..20
randf(4, 20);
// Returns random ulong in range of 0..ulong.max
rand!ulong();
---
+/
struct Random {
    private uint _seed = defaultSeed;
    private StdRandom _rnd;
    private size_t _calls;

    /// Creates RNG with set seed
    this(uint p_seed) {
        _seed = p_seed;
        _rnd = StdRandom(_seed);
    }

    /// Randomizes seed
    public void randomize() {
        seed = randomSeed;
    }
    /// Ditto
    alias randomise = randomize;

    /// Sets custom seed `p_seed`
    @property public void seed(uint p_seed) {
        _seed = p_seed;
        _rnd.seed(_seed);
        _calls = 0;
    }

    /// Returns current seed
    @property public uint seed() { return _seed; }

    /// Alias to std.random default seed
    public static alias defaultSeed = StdRandom.defaultSeed;
    /// Alias to std.random unpredictable seed
    public static alias randomSeed = unpredictableSeed;

    /// Typed alias to get random value between 0 and T.max or custom min and max
    alias randf = rand!float;
    /// Ditto
    alias randr = rand!real;
    /// Ditto
    alias randd = rand!double;
    /// Ditto
    alias randi = rand!int;
    /// Ditto
    alias randl = rand!long;

    template rand(T) {
        static if(isFloatingPoint!T) {
            /// Returns random value between 0 and T.max or custom min and max
            T rand() {
                return random / _rnd.max.to!T;
            }

            /// Ditto
            T rand(T min, T max) {
                return min + (rand!T * (max - min));
            }
        } else {
            /// Ditto
            T rand() {
                return (randr * T.max).to!T;
            }

            /// Ditto
            T rand(T min, T max) {
                return round(min + (randr * (max - min))).to!T;
            }
        }
    }

    /// Returns random uint
    public uint random() {
        uint r = _rnd.front;
        skip();
        return r;
    }

    /// Skips current random value
    public void skip(size_t amount = 1) {
        while (amount > 0) {
            _rnd.popFront();
            ++_calls;
            --amount;
        }
    }

    /// Skips N amount of random values
    public void skipTo(size_t numCalls) {
        while(_calls < numCalls) {
            skip();
        }
    }
}

