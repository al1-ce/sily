/**
Package containing many different utilities for general programming

More specific needs, like dlib, sdl or opengl are outlined in their
own subpackages, like sily:dlib, sily:sdl...

Authors: al1-ce (Alisa Lain)
*/
module sily;

/// sily.core import
public import sily.array;
/// Ditto
public import sily.clang;
/// Ditto
public import sily.color;
/// Ditto
public import sily.conv;
/// Ditto
public import sily.file;
/// Ditto
public import sily.getopt;
/// Ditto
public import sily.math;
/// Ditto
public import sily.path;
/// Ditto
public import sily.ptr;
/// Ditto
public import sily.queue;
/// Ditto
public import sily.stdio;
/// Ditto
public import sily.stdio;
/// Ditto
public import sily.string;
/// Ditto
public import sily.time;
/// Ditto
public import sily.uni;
/// Ditto
public import sily.vector;
/// Ditto
public import sily.matrix;
/// Ditto
public import sily.quat;
/// Optional sily.dyaml import
version (Have_sily_dyaml) public import sily.dyaml;
/// Optional sily.unit import
version (Have_sily_unit) public import sily.unit;

version (Have_sily_terminal) {
    /// Optional sily.terminal import
    public import sily.terminal;
    /// Ditto
    public import sily.terminal.input;
    /// Ditto
    public import sily.bashfmt;
}
/// Optional sily.terminal.logger import
version (Have_sily_terminal_logger) public import sily.terminal.logger;
/// Optional sily.terminal.tui import
version (Have_sily_terminal_tui) public import sily.terminal.tui;
/// Optional sily.raylib import
version (Have_sily_raylib) public import sily.raylib;

/// Optional sily.gamelib import
version (Have_sily_gamelib_bindbc) public import sily.bindbc;
/// Ditto
version (Have_sily_gamelib_dlib) public import sily.dlib;
/// Ditto
version (Have_sily_gamelib_opengl) public import sily.opengl;
/// Ditto
version (Have_sily_gamelib_sdl) public import sily.sdl;
/// Ditto
version (Have_sily_gamelib_sfml) public import sily.sfml;
/// Ditto
version (Have_sily_gamelib) public import sily.gamelib;


