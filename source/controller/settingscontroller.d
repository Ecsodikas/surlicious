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
	void index(string _error, HTTPServerRequest req)
	{
		string error = _error;
		string success = null;
		render!("settings.dt", error, success);
	}

	void changePassword(
		HTTPServerResponse res,
		HTTPServerRequest req,
		string userId,
		string oldPassword,
		string newPassword1,
		string newPassword2)
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
		string error = null;
		string success = "Password was changed successfully.";
		res.render!("index.dt", req, error, success);
	}

	void resendActivationMail(HTTPServerResponse res, HTTPServerRequest req, string userId)
	{
		UserStore us = Database.getUserStore();
		User u = us.getUserById(userId);

		enforce(!u.isActivated, "Account already active.");
		DateTime now = Clock.currTime.to!DateTime;
		auto time = Interval!DateTime(u.lastActivationMail, now);
		enforce(
			time.length > dur!"minutes"(5),
			"Last activation email was sent less than 5 minutes ago. Please wait."
		);

		//sendActivationMail(u);
		u.lastActivationMail = now;
		us.updateLastActivationTime(u, now);
		string error = null;
		string success = "Activation mail was sent successfully.";
		res.render!("index.dt", error, req, success);
	}
}
