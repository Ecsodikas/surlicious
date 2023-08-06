module database.userstore;
import vibe.vibe;

import models.user;

public class UserStore
{
    private MongoClient mongoClient;
    private string databaseName;

    public this(MongoClient mc, string databaseName = "Surlicious")
    {
        this.mongoClient = mc;
        this.databaseName = databaseName;
    }

    void storeUser(BsonObjectID id, string email, string name, string passwordHash, string salt)
    {
        MongoCollection users = this.mongoClient.getDatabase(this.databaseName)["Users"];
        users.insertOne(User(id, email, name, passwordHash, salt));
    }

    User getUserByEmail(string email)
    {
        MongoCollection users = this.mongoClient.getDatabase(this.databaseName)["Users"];
        auto result = users.findOne([
            "email": email
        ]);

        if (result.isNull)
        {
            return User.init;
        }

        return result.deserializeBson!User();
    }

    User getUserById(string id)
    {
        MongoCollection users = this.mongoClient.getDatabase(this.databaseName)["Users"];
        auto result = users.findOne(["_id": BsonObjectID.fromString(id)]);

        if (result.isNull)
        {
            return User.init;
        }

        return result.deserializeBson!User();
    }
}
