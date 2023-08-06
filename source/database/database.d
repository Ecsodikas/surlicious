module database.database;

import vibe.vibe;
import database.userstore;
import database.connectionstore;

public class Database
{
    private static string connectionString = "mongodb://root:qwe123@localhost:8889";

    public static UserStore getUserStore() {
        MongoClient client = connectMongoDB(Database.connectionString);
        return new UserStore(client);
    }

    public static ConnectionStore getConnectionStore() {
        MongoClient client = connectMongoDB(Database.connectionString);
        return new ConnectionStore(client);
    }
}