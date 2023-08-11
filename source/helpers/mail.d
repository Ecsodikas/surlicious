module helpers.mail;

import std.stdio;
import std.algorithm;
import std.array;

import vibe.vibe;
import models.user;
import models.connection;

import helpers.env;

public static void sendActivationMail(User user)
{
    string activationURL = EnvData.getBaseUrl() ~ "validateaccount/" ~ user.activationHash;
    sendMailTo(
        user,
        "Account activation",
        "Please click the following link to activate your account: " ~ activationURL
    );
}

public static void sendAlertMail(User user, Connections cons)
{   
    string flatlines = cons.connections.map!(x => x.name).join(", ");
    
    sendMailTo(
        user,
        "Alert: Flatlined Connections",
        "The following connections flatlined: " ~ flatlines ~ "." ~ "\n" ~
        "You will receive this email as long as your " ~
        "connections do not receive a heartbeat or the connection is deactivated."
    );
    
}

private static void sendMailTo(User user, string subject, string content)
{
    Mail email = new Mail;
    email.headers["Date"] = Clock.currTime(PosixTimeZone.getTimeZone("Europe/Berlin"))
        .toRFC822DateTimeString();
    email.headers["Sender"] = "Surlicious <noreply@exomie.eu>";
    email.headers["From"] = "Surlicious <noreply@exomie.eu>";
    email.headers["To"] = user.email;
    email.headers["Subject"] = subject;
    email.bodyText = content;

    auto ms = new SMTPClientSettings("smtp.strato.de", 465);
    ms.connectionType = SMTPConnectionType.tls;
    ms.authType = SMTPAuthType.login;
    ms.tlsValidationMode = TLSPeerValidationMode.none;
    File f = File(".mailcreds", "r");
    dchar[][] creds = f.byLine().map!array.array();
    ms.username = creds[0].to!string;
    ms.password = creds[1].to!string;
    try
    {
        sendMail(ms, email);
    }
    catch (Exception e)
    {
        logError("Couldn't send Emails: " ~ e.msg);
    }
    
}
