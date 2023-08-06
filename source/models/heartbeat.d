module models.heartbeat;

import std.datetime;

public struct Heartbeat
{
    DateTime dateTime;
    string apiKey;
    string connectionId;
}