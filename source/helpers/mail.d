module helpers.mail;

import std.stdio;
import std.algorithm;
import std.array;

import vibe.vibe;
import models.user;

public static void sendActivationMail(User user)
{
    //TODO: Add base URL env
    string activationURL = "http://127.0.0.1:8080/" ~ "validateaccount/" ~ user.activationHash;
    sendMailTo(
        user,
        "Account activation",
        "Please click the following link to activate your account: " ~ activationURL
    );
}

private static void sendMailTo(User user, string subject, string content)
{
    Mail email = new Mail;
    email.headers["Date"] = Clock.currTime(PosixTimeZone.getTimeZone("Europe/Berlin"))
        .toRFC822DateTimeString();
    email.headers["Sender"] = "Surlicious <exodiquas@exomie.eu>";
    email.headers["From"] = "Surlicious <exodiquas@exomie.eu>";
    email.headers["To"] = user.name ~ "<" ~ user.email ~ ">";
    email.headers["Subject"] = subject;
    email.bodyText = content;

    auto ms = new SMTPClientSettings("smtp.strato.de", 465);
    ms.connectionType = SMTPConnectionType.tls;
    ms.authType = SMTPAuthType.login;
    ms.tlsValidationMode = TLSPeerValidationMode.none;
    File f = File(".mailcreds");
    dchar[][] creds = f.byLine().map!array.array();
    ms.username = creds[0].to!string;
    ms.password = creds[1].to!string;

    sendMail(ms, email);
}
