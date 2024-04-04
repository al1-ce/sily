/++
`std.curl` wrapper
+/
module sily.curl;

import std.conv: to;
import std.concurrency;
import std.net.curl;
import std.typecons;
import std.datetime: Duration, seconds;

import sily.async;
// TODO: change to more pure version of curl

/// Performs HTTP request
HTTPRequest fetch(string url, FetchConfig conf = FetchConfig()) {
   HTTPRequest req = new HTTPRequest();
    auto http = HTTP(url);

    foreach (key; conf.headers.keys) {
        http.addRequestHeader(key, conf.headers[key]);
    }

    http.postData = conf.data;

    http.verbose = conf.verbose;

    http.method = cast(HTTP.Method) conf.method;

    string result = "";

    http.onReceive((ubyte[] data) {
        // import std.stdio;
        // writeln("Status code: ", http.statusLine.code);
        // writeln("Status reason: ", http.statusLine.reason);

        if (http.statusLine.code >= 300) {
            (cast(HTTPRequest) req).reject(new HTTPStatusException(http.statusLine.code, http.statusLine.reason));
            return data.length;
        }

        result ~= (cast(immutable(char)*)data)[0..data.length];
        // writeln("Result: ", result);

        return data.length;
    });

    http.onProgress = delegate int(size_t dl, size_t dln, size_t ul, size_t uln) {
        if (http.statusLine.code >= 300) return 0;
        // import std.stdio;
        // int dlperc = cast(int) ((cast(float) dl / (cast(float) dln + 0.00000001f)) * 100);
        // int ulperc = cast(int) ((cast(float) ul / (cast(float) uln + 0.00000001f)) * 100);
        // writeln("Downloading: ", dlperc, "% ", dl, "/", dln);
        // writeln("Uploading: ", ulperc, "% ", dl, "/", dln);
        if (dl != 0 && dln != 0 && dl == dln) {
            req.resolve(result);
        }
        if (ul != 0 && uln != 0 && ul == uln) {
            req.resolve(result);
        }
        return 0;
    };

    http.dataTimeout = conf.dataTimeout;
    http.operationTimeout = conf.operationTimeout;
    http.connectTimeout = conf.connectTimeout;
    http.dnsTimeout = conf.dnsTimeout;

    http.authenticationMethod = conf.authMethod;

    http.maxRedirects = conf.redirects;

    if (conf.proxy._isInit) {
        http.proxy = conf.proxy.host;
        http.proxyPort = conf.proxy.port;
        http.proxyType = conf.proxy.type;
    }

    if (conf.netInterface.length) {
        http.netInterface = conf.netInterface;
    }

    if (conf.auth.username.length) {
        http.setAuthentication(conf.auth.username, conf.auth.password, conf.auth.domain);
    }

    if (conf.proxyAuth.username.length) {
        http.setProxyAuthentication(conf.proxyAuth.username, conf.proxyAuth.password);
    }

    if (conf.port != 0) http.localPort = conf.port;
    if (conf.portRange != 0) http.localPortRange = conf.portRange;

    http.tcpNoDelay = conf.noDelay;

    if (conf.userAgent.length) http.setUserAgent = conf.userAgent;
    if (conf.noUserAgent) http.setUserAgent = "";

    string cookies;
    foreach (key; conf.cookie) {
        cookies ~= key ~ "=" ~ conf.cookie[key] ~ ";";
    }

    if (cookies.length) {
        http.setCookie = cookies[0..$-1];
    }

    if (conf.cookieJar.length) http.setCookieJar = conf.cookieJar;

    if (conf.contentLength != 0) http.contentLength = conf.contentLength;

    http.perform(No.throwOnError);
    req.resolve(result);
    // TODO: async

    // void performHttp(shared HTTP p_http) {
    //     (cast(HTTP) p_http).perform(No.throwOnError);
    // }

    // void fn() {
    //     performHttp(cast(shared) http);
    // }

    // spawn(cast(shared) &performHttp, cast(shared) http);
    // Thread t = new Thread(&fn);
    // t.start();
    // t.join(false);
    // new Thread({import std.stdio; writeln("Message from thread"); (cast(HTTPRequest) req).resolve(`{"val"="v"}`);}).start();

    return req;
}

/// Simplified version of fetch GET
HTTPRequest get(string url, string[string] headers = null) {
    return fetch(url, FetchConfig(GET, headers));
}

/// Simplified version of fetch POST
HTTPRequest post(string url, string data, string[string] headers = null) {
    return fetch(url, FetchConfig(POST, headers, data));
}

/// Simplified version of fetch PUT
HTTPRequest put(string url, string data, string[string] headers = null) {
    return fetch(url, FetchConfig(PUT, headers, data));
}

/// Simplified version of fetch DELETE
HTTPRequest del(string url, string[string] headers = null) {
    return fetch(url, FetchConfig(DELETE, headers));
}

/// Simplified version of fetch PATCH
HTTPRequest patch(string url, string data, string[string] headers = null) {
    return fetch(url, FetchConfig(PATCH, headers, data));
}

/// Full fetch configuration
struct FetchConfig {
    /// Fetch method
    FetchMethod method = GET;
    /// Headers to send
    string[string] headers;
    /// Request body
    string data;
    /// Ditto
    alias body_ = data;
    /// Sets curl authorisation method
    AuthMethod authMethod = AuthMethod.basic;
    /// Sets timeout for activity on connection
    Duration dataTimeout = seconds(3600);
    /// Sets maximum time an operation is allowed to take
    Duration operationTimeout = Duration.max;
    /// Sets timeout for connecting
    Duration connectTimeout = Duration.max;
    /// Sets timeout for connecting
    Duration dnsTimeout = Duration.max;
    /// Set max allowed redirections
    uint redirects = uint.max;
    /// Curl proxy
    Proxy proxy;
    /// Network interface to use in ofrm of the IP
    string netInterface;
    /// Outgoing port to use
    ushort port = 0;
    /// Port range (`port` to `port + portRange`)
    ushort portRange = 0;
    /// Sets tcp no-delay socket option on/off
    bool noDelay = true;
    /// Authentification
    Auth auth;
    /// Orixy authentification
    Auth proxyAuth;
    /// User agent request header
    string userAgent;
    /// Passes empty string into user agent if true
    bool noUserAgent = false;
    /// Sets active cookie strings
    string[string] cookie;
    /// Sets file path for cookies to be stored
    string cookieJar;
    /++
    The content length in bytes when using request that has content e.g.
    POST/PUT and not using chunked transfer.
    +/
    ulong contentLength = 0;
    /// Curl verbosity
    bool verbose = false;
}

/++
Curl proxy. Must be init with this(host, port, type), otherwise not valid
+/
struct Proxy {
    /// Proxy
    string host = "";
    /// Proxy port
    ushort port = 0;
    /// Proxy type
    CurlProxy type = CurlProxy.http;

    private bool _isInit = false;

    this(string _host, ushort _port, CurlProxy _type) {
        host = _host;
        port = _port;
        type = _type;
        _isInit = true;
    }
}

/++
Curl auth.
+/
struct Auth {
    /// Username
    string username;
    /// Password
    string password;
    /// Domain (can be none)
    string domain = "";
}

alias AuthMethod = HTTP.AuthMethod;
alias CurlProxy = HTTP.CurlProxy;

alias FetchMethod = int;

enum: FetchMethod {
    HEAD = HTTP.Method.head,
    GET = HTTP.Method.get,
    POST = HTTP.Method.post,
    PUT = HTTP.Method.put,
    DELETE = HTTP.Method.del,
    OPTIONS = HTTP.Method.options,
    TRACE = HTTP.Method.trace,
    CONNECT = HTTP.Method.connect,
    PATCH = HTTP.Method.patch
}

