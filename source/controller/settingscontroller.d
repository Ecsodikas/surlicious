module controller.settingscontroller;

import vibe.vibe;

import models.userdata;
import database.database;
import database.userstore;
import models.user;
import helpers.mail;

public class SettingsController
{
	UserData user;

	public this(UserData user)
	{
		this.user = user;
	}

	void index()
	{
		auto currentUser = this.user;
		string _error = null;
		render!("settings.dt", currentUser, _error);
	}

	void resendActivationMail(string userId)
	{
		UserStore us = Database.getUserStore();
		User u = us.getUserById(userId);

		if(u.isActivated) {
			redirect("/settings");
			return;	
		}
		DateTime now = Clock.currTime.to!DateTime;
		auto time = Interval!DateTime(u.lastActivationMail, now);
		if (time.length > dur!"minutes"(5)) {
			sendActivationMail(u);
			u.lastActivationMail = now;
			us.updateLastActivationTime(u, now);
			redirect("/settings");
			return;
		}

		//TODO: Error handling
	}
}
