module models.resetcode;

import vibe.data.bson;

struct ResetCode
{
    BsonObjectID _id;
    string email;
    string token;
}