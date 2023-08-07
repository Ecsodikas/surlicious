module helpers.mail;

import vibe.vibe;
import models.user;

public static void sendMailTo(User user, string subject, string content) {
    Mail email = new Mail;
    email.headers["Date"] = Clock.currTime(PosixTimeZone.getTimeZone("Europe/Berlin")).toRFC822DateTimeString();
    email.headers["Sender"] = "Surlicious <exodiquas@exomie.eu>";
    email.headers["From"] = "Surlicious <exodiquas@exomie.eu>";
    email.headers["To"] = user.name ~  "<" ~ user.email ~ ">";
    email.headers["Subject"] = subject;
    email.bodyText = content;

    auto ms = new SMTPClientSettings("smtp.strato.de", 465);
    ms.connectionType = SMTPConnectionType.tls;
    ms.authType = SMTPAuthType.login;
    ms.tlsValidationMode = TLSPeerValidationMode.none;
    ms.username = "exodiquas@exomie.eu";
    ms.password = "5Hz(TXysa.c(Fv>a";

    sendMail(ms, email);
}

