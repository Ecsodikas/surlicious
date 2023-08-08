module models.user;

import vibe.vibe;


struct User
{
    BsonObjectID _id;
    string email;
    string name;
    string password;
    string salt;
    bool isActivated;
    string activationHash;
}