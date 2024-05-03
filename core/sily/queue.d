/// FCFS container
module sily.queue;

import std.array: popFront;
import std.conv: to;

/// FCFS container
struct Queue(T) {
    /// First element
    private Node!T* _root = null;
    /// Last element
    private Node!T* _end = null;
    /// Length
    private size_t _length = 0;
    /// Length limit
    private size_t _lengthLimit = -1;

    /// Length of queue
    @property public size_t length() { return _length; }
    /// Is queue empty
    @property public bool empty() { return _root == null; }
    /// Returns first value without removing it from queue
    @property public T front() { return (*_root).value; }

    /// Creates queue filled with vals
    public this(T[] vals...) {
        push(vals);
    }

    /// opOpAssign x ~= y == x.push(y)
    Queue!T opOpAssign(string op: "~")( in T b ) {
        push(b);
        return this;
    }

    /++
    Limits length of queue, default is -1 which is limitless.
    If length is limited and new element is attempted to be
    pushed when Queue is overfilled nothing will happen.
    +/
    void limitLength(size_t len) {
        _lengthLimit = len;
        clearUntil(_lengthLimit);
    }

    /// Adds vals at end of queue
    public void push(T[] vals...) {
        if (vals.length == 0) return;
        if (_length >= _lengthLimit) return;


        if (_root == null && _length < _lengthLimit) {
            _root = new Node!T(vals[0]);
            _end = _root;
            vals.popFront();
            ++_length;
        }

        foreach (val; vals) {
            if (_length >= _lengthLimit) break;
            Node!T* _new = new Node!T(val);
            (*_end).next = _new;
            _end = _new;
            ++_length;
        }
    }

    /// Returns first value and removes it from queue
    public T pop() {
        if (_root == null) { return T.init; }
        T val = (*_root).value;
        --_length;
        if ((*_root).next != null) {
            _root = (*_root).next;
        } else {
            _root = null;
            _end = null;
        }
        return val;
    }

    /// Removes all elements after pos (used in limitLength)
    private void clearUntil(size_t pos) {
        if (_root == null) return;
        if (pos >= _length) return;
        Node!T* _node = _root;
        for (int i = 0; i < pos; ++i) {
            if (i != pos - 1) {
                _node = (*_node).next;
            } else {
                (*_node).next = null;
                _end = _node;
            }
        }
    }

    /// Removes all elements from queue
    public void clear() {
        _root = null;
        _end = null;
        _length = 0;
    }

    public string toString() const {
        if (_root == null) return "[]";

        string _out = "[";

        Node!T* last = cast(Node!T*) _root;

        while(true) {
            _out ~= (*last).value.to!string;
            if ((*last).next == null) break;
            last = (*last).next;
            _out ~= ", ";
        }
        _out ~= "]";
        return _out;
    }

    public T[] toArray(){
        if (_root == null) return T[].init;

        T[] arr = [];

        Node!T* last = cast(Node!T*) _root;

        while(true) {
            arr ~= (*last).value;
            if ((*last).next == null) break;
            last = (*last).next;
        }
        return arr;
    }
}

private struct Node(T) {
    private T _value;
    private Node!T* _next = null;

    @property public void value(T value) { _value = value; }
    @property public T value() { return _value; }

    @property public void next(Node!T* next) { _next = next; }
    @property public Node!T* next() { return _next; }

    @disable this();

    public this(T value) {
        _value = value;
    }
}
