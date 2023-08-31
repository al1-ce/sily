module sily.bindbc;

import std.string: toStringz;
import std.traits;

import bindbc.loader;

import sily.logger;

/**
Loads generic bindbc library.
Example:
---
loadBindbcLib!(bindbc.opengl, GLSupport, loadOpenGL, glSupport, "OpenGL");
loadBindbcLib!(bindbc.sfml, SFMLSupport, loadSFMLWindow, sfmlSupport, "SFML Window");
---
*/
bool loadBindbcLib
    (alias moduleName, alias support, alias loader, alias supportSuccess, string name,
     int L = __LINE__, string F = __FILE__)(Log p_logger = Log()) {
    const string supn = __traits(identifier, support);
    const string lodn = __traits(identifier, loader);
    const string sucn = __traits(identifier, supportSuccess);
    const string modn = __traits(identifier, moduleName);
    import sily.logger: info, error;
    mixin(
    `import bindbc.` ~ modn ~ `;` ~
    supn ~ ` ret = ` ~ lodn ~`();
    if (ret != ` ~ sucn ~ `) {
        if (ret == ` ~ supn ~ `.noLibrary) {
            p_logger.error!(L, F)("Failed to load ` ~ name ~ ` library");
        } else 
        if (ret == ` ~ supn ~ `.badLibrary) {
            p_logger.error!(L, F)("Failed to load one or more ` ~ name ~ `  symbols");
        } else {
            p_logger.error!(L, F)("Unknown error. Failed to load ` ~ name ~ ` library");
        }
        return false;
    }
    p_logger.info!(L, F)("` ~ name ~ ` library successfully loaded");
    `);
    return true;
}

/++
Sets search path for bindbc dll libraries.
Windows only, has no effect on linux
+/
void setBindbcLibPath(string path) {
    version(Windows) setCustomLoaderSearchPath(path.toStringz);
}

/++
Resets search path for bindbc dll libraries.
Windows only, has no effect on linux
+/
void resetBindbcLibPath() {
    version(Windows) setCustomLoaderSearchPath(null);
}
