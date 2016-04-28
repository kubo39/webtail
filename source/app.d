import vibe.core.core : sleep;
import vibe.core.log;
import vibe.http.router : URLRouter;
import vibe.http.server;
import vibe.web.web;
import vibe.http.websockets : WebSocket, handleWebSockets;
import vibe.http.fileserver : serveStaticFiles;

import std.stdio;
import std.file;
import std.string;
import core.time;


class LogProtocol
{
private:
    File file;

public:
    this(string filename)
    {
        file = File(filename);
    }

    string readline()
    {
        return file.readln;
    }
}

class Webtail
{
private:
    LogProtocol logProtocol;

public:
    this(string filename)
    {
        logProtocol = new LogProtocol(filename);
    }

    @path("/") void index()
    {
        render!("index.dt");
    }

    @path("/live") void getWebsockets(scope WebSocket socket)
    {
        while (true)
        {
            sleep(1.seconds);
            if (!socket.connected) break;
            socket.send(logProtocol.readline);
        }
    }
}

shared static this()
{
    auto router = new URLRouter;
    router.registerWebInterface(new Webtail("/var/log/system.log"));
    router.get("*", serveStaticFiles("public/"));

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    listenHTTP(settings, router);

    logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}
