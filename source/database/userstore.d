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

    void storeUser(User u)
    {
        MongoCollection users = this.mongoClient.getDatabase(this.databaseName)["Users"];
        users.insertOne(u);
    }

    void activateAccount(string activationHash)
    {
        MongoCollection users = this.mongoClient.getDatabase(this.databaseName)["Users"];
        auto result = users.replaceOne([
            "activationHash": activationHash
        ],
        ["$set": ["isActivated": true]]);
    }

    User getUserByActivationHash(string activationHash)
    {
        MongoCollection users = this.mongoClient.getDatabase(this.databaseName)["Users"];
        auto result = users.findOne([
            "activationHash": activationHash
        ]);

        if(result.isNull) {
            return User.init;
        }

        return result.deserializeBson!User();
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

    void updateLastActivationTime(User u, DateTime time) {
        MongoCollection users = this.mongoClient.getDatabase(this.databaseName)["Users"];
        users.replaceOne([
            "_id": u._id 
        ],
        ["$set": ["lastActivationMail": time]]);
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
