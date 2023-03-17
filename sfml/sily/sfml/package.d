module sily.sfml;

import sily.logger;
import sily.bindbc;

import bindbc.sfml;

static if (bindSFMLWindow) {
    /// Loads SFML Window library
    bool loadLibraryWindow(int L = __LINE__, string F = __FILE__)() {
        return loadBindbcLib!(bindbc.sfml, SFMLSupport, loadSFMLWindow, sfmlSupport, "SFML Window", L, F);
    }
}
static if (bindSFMLGraphics) {
    /// Loads SFML Graphics library !NOT READY!
    bool loadLibraryGraphics() {
        return false;
    }
}

public import sily.sfml.window;

