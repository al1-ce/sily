module sily.html;

import sily.html.lexer;

public import sily.html.token: HTMLTag;

/// Parses HTML string and returns array of tags
HTMLTag[] parseHTML(string html) {
    Lexer l = Lexer(html);

    HTMLTag[] tags = [];

    while (!l.eof) {
        tags ~= l.nextToken();
    }

    return tags;
}

/// toPlainText?
