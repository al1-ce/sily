/// Datetime utils
module sily.time;

import std.datetime: Clock;
import std.conv: to;


static class Time {
	public static const double SECOND = 10_000_000L;

	public static double currTime()	{
		return Clock.currStdTime().to!double / SECOND;
	}
}

