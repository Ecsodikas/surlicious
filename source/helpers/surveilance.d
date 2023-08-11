module helpers.surveilance;

import vibe.vibe;
import controller.connectionscontroller;

void sendAlertMails()
{
	logInfo("Sending alert mails...");
	ConnectionsController cc = new ConnectionsController();
    cc.sendAlertMails();
	logInfo("Sent alert mails!");
}

void initialisePeriodicSurveilance()
{
    import std;
	import vibe.core.core;
    sendAlertMails();
	setTimer(5.minutes, toDelegate(&sendAlertMails), true);
}