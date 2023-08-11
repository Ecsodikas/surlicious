module controller.settingscontroller;

import vibe.vibe;

import models.authinfo;
import database.database;
import database.userstore;
import models.user;
import helpers.mail;
import helpers.env;

public class SettingsController
{
	void index(string _error)
	{
		string error = _error;
		render!("settings.dt", error);
	}

	void changePassword(string userId, string oldPassword, string newPassword1, string newPassword2)
	{
		UserStore us = Database.getUserStore();
		User u = us.getUserById(userId);

		import helpers.password;
		PasswordHelper.checkPassword(u, oldPassword);
		enforce(newPassword1 == newPassword2, "The two new passwords do not match.");
		
		string[] passwordData = PasswordHelper.hashPassword(newPassword1);
		string passwordHash = passwordData[0];
		string salt = passwordData[1];

		us.updateUserPassword(u._id, passwordHash, salt);
		terminateSession();
		redirect(EnvData.getBaseUrl());
	}

	void resendActivationMail(string userId)
	{
		UserStore us = Database.getUserStore();
		User u = us.getUserById(userId);

		if (u.isActivated)
		{
			redirect(EnvData.getBaseUrl());
			return;
		}
		DateTime now = Clock.currTime.to!DateTime;
		auto time = Interval!DateTime(u.lastActivationMail, now);
		if (time.length > dur!"minutes"(5))
		{
			sendActivationMail(u);
			u.lastActivationMail = now;
			us.updateLastActivationTime(u, now);
			redirect(EnvData.getBaseUrl());
			return;
		}

		//TODO: Error handling
	}
}
