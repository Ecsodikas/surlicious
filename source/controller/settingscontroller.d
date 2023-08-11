module controller.settingscontroller;

import vibe.vibe;

import models.authinfo;
import database.database;
import database.userstore;
import models.user;
import helpers.mail;

public class SettingsController
{
	void index()
	{
		string error = null;
		render!("settings.dt", error);
	}

	void resendActivationMail(string userId)
	{
		UserStore us = Database.getUserStore();
		User u = us.getUserById(userId);

		if(u.isActivated) {
			redirect("/");
			return;	
		}
		DateTime now = Clock.currTime.to!DateTime;
		auto time = Interval!DateTime(u.lastActivationMail, now);
		if (time.length > dur!"minutes"(5)) {
			sendActivationMail(u);
			u.lastActivationMail = now;
			us.updateLastActivationTime(u, now);
			redirect("/");
			return;
		}

		//TODO: Error handling
	}
}
