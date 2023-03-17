module sily.sfml.window;

import bindbc.sfml;

static if (bindSFMLWindow):

import std.string: toStringz;
import std.conv: to;

import sily.logger;

/// sfWindow wrapper
struct Window {
    private sfWindow* _window;
    
    /// Creates window with specified settings
    public void create(VideoMode videoMode, string title, WindowStyle style, ContextSettings ctxSettings) {
        _window = sfWindow_create(videoMode._videoMode, title.toStringz, cast(int) style, ctxSettings._settings);
    }
    
    /// Enables/Disables vertical sync
    public void setVerticalSyncEnabled(bool enabled) {
        sfWindow_setVerticalSyncEnabled(_window, enabled);
    }
    
    /// Sets framerate limit
    public void setFramerateLimit(uint limit) {
        sfWindow_setFramerateLimit(_window, limit);
    }
    
    /// Returns true if window is open
    public bool isOpen() {
        return sfWindow_isOpen(_window) == 1;
    }

    /// Activates/Disables current window context
    public bool setActive(bool active) {
        return sfWindow_setActive(_window, active) == 1;
    }
    
    /// Swap front/back opengl buffers
    public void display() {
        sfWindow_display(_window);
    }
    
    /// Polls latest event
    public bool pollEvent(Event* event) {
        return sfWindow_pollEvent(_window, &((*event)._event)) == 1;
    }
    
    /// Closes window
    public void close() {
        sfWindow_close(_window);
    }

    /// Destroys window
    public void destroy() {
        sfWindow_destroy(_window);
    }
}

/// Wrapper for sfVideoMode
struct VideoMode {
    private sfVideoMode _videoMode;
    this(uint width, uint height, uint bitsPerPixel = 32) {
        _videoMode = sfVideoMode(width, height, bitsPerPixel);
    }
}

/// Wrapper for sfContextSettings
struct ContextSettings {
    private const(sfContextSettings)* _settings = new sfContextSettings();
}

/// Wrapper for sfWindowStyle
enum WindowStyle {
    none = sfWindowStyle.sfNone,
    titlebar = sfWindowStyle.sfTitlebar,
    resize = sfWindowStyle.sfResize,
    close = sfWindowStyle.sfClose,
    fullscreen = sfWindowStyle.sfFullscreen,
    defaultStyle = WindowStyle.titlebar | WindowStyle.resize | WindowStyle.close
}

/// Wrapper for sfEvent
struct Event {
    private sfEvent _event = sfEvent();
    
    public EventType type() {
        return cast(EventType) cast(int) _event.type;
    }
}

/// Wrapper for sfEventType
/// WIP https://bindbc-sfml.dpldocs.info/v1.0.2/source/bindbc.sfml.window.d.html#L83
enum EventType {
    closed = cast(int) sfEventType.sfEvtClosed,
    resized = cast(int) sfEventType.sfEvtResized
}
