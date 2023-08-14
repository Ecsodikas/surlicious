module helpers.websockethandler;

import std.json;

import vibe.vibe;
import models.toast;

public class WebSocketHandler
{
    public void getWS(scope WebSocket socket)
    {
        JSONValue toast = ["status": "Error", "message": "This is an error message!"];
        socket.send(toast.toJSON());
	}
}
