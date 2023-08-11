module models.user;

import vibe.vibe;


struct User
{
    BsonObjectID _id;
    string email;
    string password;
    string salt;
    bool isActivated;
    string activationHash;
    DateTime lastActivationMail;
}