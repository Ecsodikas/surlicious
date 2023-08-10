module helpers.surveilance;

import vibe.vibe;
import controller.connectionscontroller;

void sendAlertMails()
{
	import std.datetime;
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
	// start a periodic timer that prints the time every second
	setTimer(5.minutes, toDelegate(&sendAlertMails), true);
}