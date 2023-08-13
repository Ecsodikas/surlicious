module database.database;

import vibe.vibe;
import database.userstore;
import database.resetstore;
import database.connectionstore;
import helpers.env;

public class Database
{
    public static UserStore getUserStore() {
        MongoClient client = connectMongoDB(EnvData.getDBConnectionString());
        return new UserStore(client);
    }

    public static ConnectionStore getConnectionStore() {
        MongoClient client = connectMongoDB(EnvData.getDBConnectionString());
        return new ConnectionStore(client);
    }

    public static ResetStore getResetStore() {
        MongoClient client = connectMongoDB(EnvData.getDBConnectionString());
        return new ResetStore(client);
    }
}