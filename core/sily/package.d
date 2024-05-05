// SPDX-FileCopyrightText: (C) 2022 Alisa Lain <al1-ce@null.net>
// SPDX-License-Identifier: GPL-3.0-or-later

/**
Package containing many different utilities for general programming

Core sily module (`import sily;`) automatically imports subpackages
if they have been detected as a dependency
*/
module sily;

/// core library import
public import sily.array;
/// Ditto
public import sily.async;
/// Ditto
public import sily.clang;
/// Ditto
public import sily.color;
/// Ditto
public import sily.conv;
/// Ditto
public import sily.curl;
/// Ditto
public import sily.file;
/// Ditto
public import sily.getopt;
/// Ditto
public import sily.math;
/// Ditto
public import sily.matrix;
/// Ditto
public import sily.path;
/// Ditto
public import sily.property;
/// Ditto
public import sily.ptr;
/// Ditto
public import sily.quat;
/// Ditto
public import sily.queue;
/// Ditto
public import sily.random;
/// Ditto
public import sily.stack;
/// Ditto
public import sily.string;
/// Ditto
public import sily.thread;
/// Ditto
public import sily.time;
/// Ditto
public import sily.uid;
/// Ditto
public import sily.uni;
/// Ditto
public import sily.uri;
/// Ditto
public import sily.vector;

/// Optional sily.sdl import
version (Have_sily_sdl) public import sily.sdl;

version (Have_sily_term) {
    /// Optional sily.term import
    public import sily.term;
    /// Ditto
    public import sily.term.input;
    /// Ditto
    public import sily.bash;
    /// Ditto
    public import sily.tui;
    /// Ditto
    public import sily.log;
}
/// Ditto
version (Have_sily_web) public import sily.web;

