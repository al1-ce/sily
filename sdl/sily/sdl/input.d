module sily.sdl.input;

import std.traits;
import std.algorithm;
import std.range;
import std.conv;

import bindbc.sdl;

// FIXME: window
// import terramatter.render.window;
import sily.vector;

static class Input {
    private static KeyState[KeyCode] s_keyStates;
    private static KeyState[MouseCode] s_mbStates;
    private static KeyCode[SDL_Scancode] s_keyConv;
    private static MouseCode[ubyte] s_mbConv;

    private static Vector2i s_mouseMotion;
    private static Vector2i s_mousePosition;

    private static KeyCode s_lastKey;

    public static void update() {
        SDL_Event e;

        foreach (skey; s_keyStates.keys) {
            if (s_keyStates[skey] == KeyState.justPressed) s_keyStates[skey] = KeyState.pressed;
            if (s_keyStates[skey] == KeyState.justReleased) s_keyStates[skey] = KeyState.released;
        }
        
        foreach (skey; s_mbStates.keys) {
            if (s_mbStates[skey] == KeyState.justPressed) s_mbStates[skey] = KeyState.pressed;
            if (s_mbStates[skey] == KeyState.justReleased) s_mbStates[skey] = KeyState.released;
        }
        
        s_mouseMotion.x = 0;
        s_mouseMotion.y = 0;

        while (SDL_PollEvent(&e)) {
            switch (e.type) {
                case SDL_EventType.SDL_KEYDOWN:
                    KeyCode key = getKeyCodeSDL(e.key.keysym.scancode);
                    // TODO fire up key repeat event
                    s_lastKey = key;
                    if (s_keyStates[key] == KeyState.pressed) break;
                    s_keyStates[key] = KeyState.justPressed;
                break; 
                case SDL_EventType.SDL_KEYUP:
                    KeyCode key = getKeyCodeSDL(e.key.keysym.scancode);
                    s_keyStates[key] = KeyState.justReleased;
                break; 
                case SDL_EventType.SDL_MOUSEBUTTONDOWN:
                    MouseCode key = getMouseCodeSDL(e.button.button);
                    s_mbStates[key] = KeyState.justPressed;
                    // TODO emit event on e.button.clicks == 2
                break; 
                case SDL_EventType.SDL_MOUSEBUTTONUP:
                    MouseCode key = getMouseCodeSDL(e.button.button);
                    s_mbStates[key] = KeyState.justReleased;
                break; 
                case SDL_EventType.SDL_MOUSEMOTION:
                    s_mouseMotion.x = e.motion.xrel;
                    s_mouseMotion.y = e.motion.yrel;
                    s_mousePosition.x = e.motion.x;
                    s_mousePosition.y = e.motion.y;
                break; 
                case SDL_EventType.SDL_MOUSEWHEEL:
                    if(e.wheel.y> 0) { // scroll up
                        // TODO scroll up
                    } else 
                    if(e.wheel.y < 0) { // scroll down
                        // TODO scroll down
                    }

                    if(e.wheel.x > 0) { // scroll right
                        // TODO scroll right
                    } else 
                    if(e.wheel.x < 0) { // scroll left
                        // TODO scroll left
                    }
                break;
                // Close application button
                case SDL_EventType.SDL_QUIT:
                    // Window.setRequestedClose(true);
                break;
                default:
                    //
            }
        }
    }

    public static Vector2i getMouseRelative() {
        return s_mouseMotion;
    }

    public static Vector2i getMousePosition() {
        return s_mousePosition;
    }

    public static void setRelativeMouseMode(bool enabled) {
        SDL_SetRelativeMouseMode(enabled.to!SDL_bool);
    }

    public static bool getRelativeMouseMode() {
        return SDL_GetRelativeMouseMode().to!bool;
    }

    public static void setMousePosition(int[2] pos ...) {
        // SDL_WarpMouseInWindow(Window.getWindow, pos[0], pos[1]);
    }

    public static void setMousePositionScreen(int[2] pos ...) {
        SDL_WarpMouseGlobal(pos[0], pos[1]);
    }

    public static bool isKeyJustPressed(KeyCode p_key){ 
		return s_keyStates[p_key] == KeyState.justPressed;
	}

    public static bool isKeyPressed(KeyCode p_key){ 
		return s_keyStates[p_key] == KeyState.justPressed ||
               s_keyStates[p_key] == KeyState.pressed;
	}

    public static bool isKeyJustReleased(KeyCode p_key){ 
		return s_keyStates[p_key] == KeyState.justReleased;
	}

    public static bool isKeyReleased(KeyCode p_key){ 
		return s_keyStates[p_key] == KeyState.justReleased ||
               s_keyStates[p_key] == KeyState.released;
	}

    public static bool isMouseJustPressed(MouseCode p_key){ 
		return s_mbStates[p_key] == KeyState.justPressed;
	}

    public static bool isMousePressed(MouseCode p_key){ 
		return s_mbStates[p_key] == KeyState.justPressed ||
               s_mbStates[p_key] == KeyState.pressed;
	}

    public static bool isMouseJustReleased(MouseCode p_key){ 
		return s_mbStates[p_key] == KeyState.justReleased;
	}

    public static bool isMouseReleased(MouseCode p_key){ 
		return s_mbStates[p_key] == KeyState.justReleased ||
               s_mbStates[p_key] == KeyState.released;
	}

    static this() {
        foreach (skey; EnumMembers!KeyCode) {
            s_keyStates[skey] = KeyState.released;
        }
        
        foreach (skey; EnumMembers!KeyCode) {
            s_keyConv[skey.to!SDL_Scancode] = skey;
        }
        
        foreach (skey; EnumMembers!MouseCode) {
            s_mbConv[skey.to!ubyte] = skey;
        }

        s_mouseMotion = Vector2i(0, 0);
        s_mousePosition = Vector2i(0, 0);
    }

    public static int keyCodeLength() {
        return EnumMembers!KeyCode.length;
    }

    private static KeyCode getKeyCodeSDL(SDL_Scancode p_code) {
        return s_keyConv[p_code];
    }

    private static MouseCode getMouseCodeSDL(ubyte p_code) {
        return s_mbConv[p_code];
    }

    static enum MouseCode {
        mbLeft = SDL_BUTTON_LEFT,
        mbRight = SDL_BUTTON_RIGHT,
        mbMiddle = SDL_BUTTON_MIDDLE,
        mbX1 = SDL_BUTTON_X1,
        mbX2 = SDL_BUTTON_X2,
    }

    static enum KeyState {
        justPressed,
        pressed, 
        justReleased, 
        released
    }

    static enum KeyCode {
        // LETTERS
        keyA = SDL_Scancode.SDL_SCANCODE_A,
        keyB = SDL_Scancode.SDL_SCANCODE_B,
        keyC = SDL_Scancode.SDL_SCANCODE_C,
        keyD = SDL_Scancode.SDL_SCANCODE_D,
        keyE = SDL_Scancode.SDL_SCANCODE_E,
        keyF = SDL_Scancode.SDL_SCANCODE_F,
        keyG = SDL_Scancode.SDL_SCANCODE_G,
        keyH = SDL_Scancode.SDL_SCANCODE_H,
        keyI = SDL_Scancode.SDL_SCANCODE_I,
        keyJ = SDL_Scancode.SDL_SCANCODE_J,
        keyK = SDL_Scancode.SDL_SCANCODE_K,
        keyL = SDL_Scancode.SDL_SCANCODE_L,
        keyM = SDL_Scancode.SDL_SCANCODE_M,
        keyN = SDL_Scancode.SDL_SCANCODE_N,
        keyO = SDL_Scancode.SDL_SCANCODE_O,
        keyP = SDL_Scancode.SDL_SCANCODE_P,
        keyQ = SDL_Scancode.SDL_SCANCODE_Q,
        keyR = SDL_Scancode.SDL_SCANCODE_R,
        keyS = SDL_Scancode.SDL_SCANCODE_S,
        keyT = SDL_Scancode.SDL_SCANCODE_T,
        keyU = SDL_Scancode.SDL_SCANCODE_U,
        keyV = SDL_Scancode.SDL_SCANCODE_V,
        keyW = SDL_Scancode.SDL_SCANCODE_W,
        keyX = SDL_Scancode.SDL_SCANCODE_X,
        keyY = SDL_Scancode.SDL_SCANCODE_Y,
        keyZ = SDL_Scancode.SDL_SCANCODE_Z,
        
        // NUMBERS
        key0 = SDL_Scancode.SDL_SCANCODE_0,
        key1 = SDL_Scancode.SDL_SCANCODE_1,
        key2 = SDL_Scancode.SDL_SCANCODE_2,
        key3 = SDL_Scancode.SDL_SCANCODE_3,
        key4 = SDL_Scancode.SDL_SCANCODE_4,
        key5 = SDL_Scancode.SDL_SCANCODE_5,
        key6 = SDL_Scancode.SDL_SCANCODE_6,
        key7 = SDL_Scancode.SDL_SCANCODE_7,
        key8 = SDL_Scancode.SDL_SCANCODE_8,
        key9 = SDL_Scancode.SDL_SCANCODE_9,
        
        // FUNCTION KEYS
        keyF1 = SDL_Scancode.SDL_SCANCODE_F1,
        keyF2 = SDL_Scancode.SDL_SCANCODE_F2,
        keyF3 = SDL_Scancode.SDL_SCANCODE_F3,
        keyF4 = SDL_Scancode.SDL_SCANCODE_F4,
        keyF5 = SDL_Scancode.SDL_SCANCODE_F5,
        keyF6 = SDL_Scancode.SDL_SCANCODE_F6,
        keyF7 = SDL_Scancode.SDL_SCANCODE_F7,
        keyF8 = SDL_Scancode.SDL_SCANCODE_F8,
        keyF9 = SDL_Scancode.SDL_SCANCODE_F9,
        keyF10 = SDL_Scancode.SDL_SCANCODE_F10,
        keyF11 = SDL_Scancode.SDL_SCANCODE_F11,
        keyF12 = SDL_Scancode.SDL_SCANCODE_F12,
        keyF13 = SDL_Scancode.SDL_SCANCODE_F13,
        keyF14 = SDL_Scancode.SDL_SCANCODE_F14,
        keyF15 = SDL_Scancode.SDL_SCANCODE_F15,
        keyF16 = SDL_Scancode.SDL_SCANCODE_F16,
        keyF17 = SDL_Scancode.SDL_SCANCODE_F17,
        keyF18 = SDL_Scancode.SDL_SCANCODE_F18,
        keyF19 = SDL_Scancode.SDL_SCANCODE_F19,
        keyF20 = SDL_Scancode.SDL_SCANCODE_F20,
        keyF21 = SDL_Scancode.SDL_SCANCODE_F21,
        keyF22 = SDL_Scancode.SDL_SCANCODE_F22,
        keyF23 = SDL_Scancode.SDL_SCANCODE_F23,
        keyF24 = SDL_Scancode.SDL_SCANCODE_F24,
        
        // NUMBER ROW (1ST ROW)
        keyESC = SDL_Scancode.SDL_SCANCODE_ESCAPE,
        keyGrave = SDL_Scancode.SDL_SCANCODE_GRAVE,
        keyMinus = SDL_Scancode.SDL_SCANCODE_MINUS,
        keyEquals = SDL_Scancode.SDL_SCANCODE_EQUALS,
        keyBackspace = SDL_Scancode.SDL_SCANCODE_BACKSPACE,
        
        // 2ND ROW
        keyTab = SDL_Scancode.SDL_SCANCODE_TAB,
        keyLeftBracket = SDL_Scancode.SDL_SCANCODE_LEFTBRACKET,
        keyRightBracket = SDL_Scancode.SDL_SCANCODE_RIGHTBRACKET,
        keyBackslash = SDL_Scancode.SDL_SCANCODE_BACKSLASH,

        // 3RD ROW
        keyCapsLock = SDL_Scancode.SDL_SCANCODE_CAPSLOCK,
        keySemicolon = SDL_Scancode.SDL_SCANCODE_SEMICOLON,
        keyApostrophe = SDL_Scancode.SDL_SCANCODE_APOSTROPHE,
        keyReturn = SDL_Scancode.SDL_SCANCODE_RETURN,

        // 4RTH ROW
        keyLeftShift = SDL_Scancode.SDL_SCANCODE_LSHIFT,
        keyComma = SDL_Scancode.SDL_SCANCODE_COMMA,
        keyPeriod = SDL_Scancode.SDL_SCANCODE_PERIOD,
        keySlash = SDL_Scancode.SDL_SCANCODE_SLASH,
        keyRightShift = SDL_Scancode.SDL_SCANCODE_RSHIFT,

        // BOTTOM ROW
        keyLeftControl = SDL_Scancode.SDL_SCANCODE_LCTRL,
        keyApplication = SDL_Scancode.SDL_SCANCODE_APPLICATION,
        keyLeftAlt = SDL_Scancode.SDL_SCANCODE_LALT,
        keySpace = SDL_Scancode.SDL_SCANCODE_SPACE,
        keyRightAlt = SDL_Scancode.SDL_SCANCODE_RALT,
        keyLeftGUI = SDL_Scancode.SDL_SCANCODE_LGUI,
        keyRightGUI = SDL_Scancode.SDL_SCANCODE_RGUI,
        keyRightControl = SDL_Scancode.SDL_SCANCODE_RCTRL,

        // KEYPAD
        keyLeft = SDL_Scancode.SDL_SCANCODE_LEFT,
        keyRight = SDL_Scancode.SDL_SCANCODE_RIGHT,
        keyUp = SDL_Scancode.SDL_SCANCODE_UP,
        keyDown = SDL_Scancode.SDL_SCANCODE_DOWN,

        // HOME
        keyHome = SDL_Scancode.SDL_SCANCODE_HOME,
        keyEnd = SDL_Scancode.SDL_SCANCODE_END,
        keyPageUp = SDL_Scancode.SDL_SCANCODE_PAGEUP,
        keyPageDown = SDL_Scancode.SDL_SCANCODE_PAGEDOWN,
        keyInsert = SDL_Scancode.SDL_SCANCODE_INSERT,
        keyDelete = SDL_Scancode.SDL_SCANCODE_DELETE,

        // SCROLL LOCK
        keyScrollLock = SDL_Scancode.SDL_SCANCODE_SCROLLLOCK,
        keyPrintScreen = SDL_Scancode.SDL_SCANCODE_PRINTSCREEN,
        keyPause = SDL_Scancode.SDL_SCANCODE_PAUSE
        
        // TODO NUMPAD
    }
}

class InputEvent {
    
}
