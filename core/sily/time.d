// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/// Datetime utils
module sily.time;

import std.datetime: Clock;
import std.conv: to;

private const long _second = 10_000_000L;

/// Returns amount of seconds in current time
double currTime()	{
    return Clock.currStdTime().to!double / _second;
}


