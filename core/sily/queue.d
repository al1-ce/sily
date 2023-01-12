module sily.queue;

import std.array: popFront;
import std.conv: to;

/// FCFS container
struct Queue(T) {
    /// First element
    private Node!T* _root = null;
    
    /// Is queue empty
    @property public bool empty() { return _root == null; }
    /// Returns first value without removing it from queue
    @property public T front() { return (*_root).value; }
    
    /// Creates queue filled with vals
    public this(T[] vals...) {
        push(vals);
    }
    
    /// Adds vals at end of queue
    public void push(T[] vals...) {
        if (vals.length == 0) return;
        
        Node!T* last;
        
        if (_root == null) {
            _root = new Node!T(vals[0]);
            last = _root;
            vals.popFront();
        } else {
            last = _root;
            while(true) {
                if ((*last).next == null) break;
                last = (*last).next;
            }
        }
        
        foreach (val; vals) {
            Node!T* _new = new Node!T(val);
            (*last).next = _new;
            last = _new;
        }

    }
    
    /// Returns first value and removes it from queue
    public T pop() {
        if (_root == null) { return T.init; }
        T val = (*_root).value;
        if ((*_root).next != null) {
            _root = (*_root).next;
        } else {
            _root = null;
        }
        return val;
    }
    
    /// Removes all elements from queue
    public void clear() {
        _root = null;
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
