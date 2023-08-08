module models.connection;

import vibe.vibe;

public struct Connection
{
    BsonObjectID _id;
    string name;
    long heartbeat;
    bool isActive = false;
}

public struct Connections
{
    BsonObjectID user_id;
    BsonObjectID api_key = BsonObjectID();
    Connection[] connections = [];
}

