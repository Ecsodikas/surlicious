module database.resetstore;
import vibe.vibe;
import models.resetcode;

public class ResetStore
{
    private MongoClient mongoClient;
    private string databaseName;

    public this(MongoClient mc, string databaseName = "Surlicious")
    {
        this.mongoClient = mc;
        this.databaseName = databaseName;
    }

    public void setResetCode(ResetCode rc)
    {
        MongoCollection resetCodes = this.mongoClient.getDatabase(this.databaseName)["ResetCodes"];
        resetCodes.insertOne(rc);
    }

    public ResetCode getResetCodeByMail(string email)
    {
        MongoCollection resetCodes = this.mongoClient.getDatabase(this.databaseName)["ResetCodes"];

        auto result = resetCodes.findOne([
            "email": email
        ]);

        if (result.isNull)
        {
            return ResetCode.init;
        }

        return result.deserializeBson!ResetCode();
    }

    public ResetCode getResetCodeByToken(string token)
    {
        MongoCollection resetCodes = this.mongoClient.getDatabase(this.databaseName)["ResetCodes"];

        auto result = resetCodes.findOne([
            "token": token
        ]);

        if (result.isNull)
        {
            return ResetCode.init;
        }

        return result.deserializeBson!ResetCode();
    }

    public void removeResetCode(ResetCode rc)
    {
        MongoCollection resetCodes = this.mongoClient.getDatabase(this.databaseName)["ResetCodes"];
        resetCodes.deleteOne([
            "_id": rc._id
        ]);
    }

}
