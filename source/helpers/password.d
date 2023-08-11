module helpers.password;

import std.digest.sha;
import std.digest.md;
import std.random;
import std.conv;
import std.stdio;
import std.algorithm;
import std.ascii;
import std.range;

import vibe.vibe;
import models.user;

public class PasswordHelper
{
    public static void checkPassword(User u, string password)
    {
        auto sha1 = new SHA1Digest();
        string passwordHash = sha1.digest(password ~ u.salt).toHexString();

        enforce(u.password == passwordHash, "Invalid login credentials.");
    }

    public static string[] hashPassword(string password)
    {
        int[] alphabet = [
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
            11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
            21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
            31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
            41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
        ];

        string salt = iota(15).map!(_ => alphabet.choice()).array().to!string;
        auto sha1 = new SHA1Digest();
        string passwordHash = sha1.digest(password ~ salt).toHexString();
        return [passwordHash, salt];
    }
}
