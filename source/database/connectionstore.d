module database.connectionstore;

import vibe.vibe;
import models.connection;
import models.heartbeat;

public class ConnectionStore
{
    private MongoClient mongoClient;
    private string databaseName;

    public this(MongoClient mc, string databaseName = "Surlicious")
    {
        this.mongoClient = mc;
        this.databaseName = databaseName;
    }

    private MongoCollection getUserConnectionsCollection()
    {
        return this.mongoClient.getDatabase(this.databaseName)["UserConnections"];
    }

    public MongoCollection getFlatLineConnections()
    {
        import std;

        MongoCollection connections = this.getUserConnectionsCollection();

        long hnsecs = Clock.currStdTime();
        long fiveMinutes = dur!"minutes"(5).total!"hnsecs";
        auto diff = hnsecs - fiveMinutes;
  
        return connections;
    }

    public void setConnectionStatus(string isActive, string userId, string connectionId)
    {
        MongoCollection connections = this.getUserConnectionsCollection();
        BsonObjectID userIdBson = BsonObjectID.fromString(userId);
        BsonObjectID connectionIdBson = BsonObjectID.fromString(connectionId);

        connections.replaceOne([
            "user_id": userIdBson,
            "connections._id": connectionIdBson
        ], [
            "$set": ["connections.$.isActive": (isActive == "true")]
        ]);
    }

    public void getConnectionsByHeartbeat(Heartbeat heartbeat)
    {
        import std.datetime.systime;

        long hnsecs = Clock.currStdTime();

        MongoCollection connections = this.getUserConnectionsCollection();
        auto result = connections.replaceOne([
            "api_key": BsonObjectID.fromString(heartbeat.apiKey),
            "connections._id": BsonObjectID.fromString(heartbeat.connectionId)
        ], [
            "$set": [
                "connections.$.heartbeat": hnsecs
            ]
        ]);
    }

    public Connections getConnections(string userId)
    {
        MongoCollection connections = this.getUserConnectionsCollection();
        auto result = connections.findOne([
            "user_id": BsonObjectID.fromString(userId),
        ], FindOptions.init);

        if (result.isNull)
        {
            return Connections.init;
        }

        return result.deserializeBson!Connections();
    }

    public void removeConnection(BsonObjectID connectionId, string userId)
    {
        MongoCollection connections = this.getUserConnectionsCollection();

        auto r = connections.replaceOne([
            "user_id": BsonObjectID.fromString(userId),
            "connections._id": connectionId
        ],
        ["$pull": ["connections": ["_id": connectionId]]]);
    }

    public void addConnection(string name, string userId)
    {
        MongoCollection connections = this.getUserConnectionsCollection();
        auto userIdBOI = BsonObjectID.fromString(userId);

        auto result = connections.findOne(["user_id": userIdBOI]);

        if (result.isNull)
        {
            connections.insertOne(Connections(
                    userIdBOI,
                    BsonObjectID().generate(),
                    []
            ));
        }

        UpdateOptions uo;
        uo.upsert = true;

        Connection c = Connection(
            BsonObjectID.generate(),
            name,
            0,
            false
        );

        connections.replaceOne([
            "user_id": userIdBOI
        ], [
            "$push": ["connections": c]
        ], uo);
    }

    public void storeConnections(Connections c)
    {
        MongoCollection connections = this.getUserConnectionsCollection();
        connections.insertOne(c);
    }

    public void recreateApiKey(string oldKey, string userId)
    {
        MongoCollection connections = this.getUserConnectionsCollection();
        BsonObjectID userIdBOI = BsonObjectID.fromString(userId);
        BsonObjectID oldKeyBOI = BsonObjectID.fromString(oldKey);

        UpdateOptions uo;
        uo.upsert = true;

        connections.replaceOne([
            "user_id": userIdBOI,
            "api_key": oldKeyBOI
        ], [
            "$set": ["api_key": BsonObjectID.generate()]
        ], uo);
    }
}
