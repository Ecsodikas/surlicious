module controller.usercontroller;

import std.uuid;
import std.net.isemail;

import vibe.vibe;

import models.user;
import models.authinfo;
import models.resetcode;
import models.connection;

import database.userstore;
import database.resetstore;
import database.connectionstore;
import database.database;

import helpers.env;
import helpers.password;
import helpers.mail;

public class UserController
{

	void getLogin(string _error)
	{
		string error = _error;
		render!("login.dt", error);
	}

	public void validateAccount(string activationHash)
	{
		UserStore us = Database.getUserStore();
		User u = us.getUserByActivationHash(activationHash);
		import helpers.env;

		if (u.isActivated || u._id == BsonObjectID.init)
		{
			//TODO: Error handling
			redirect(EnvData.getBaseUrl() ~ "login");
		}

		us.activateAccount(activationHash);
		redirect(EnvData.getBaseUrl() ~ "login");
	}

	void getRegister(string _error)
	{
		string error = _error;
		render!("register.dt", error);
	}

	void getLogout()
	{
		terminateSession();
		redirect(EnvData.getBaseUrl());
	}

	void postRegister(HTTPServerRequest req, HTTPServerResponse res)
	{
		auto formdata = req.form;
		string email = formdata.get("email");

		EmailStatus es = isEmail(email);
		enforce(es.valid, "No valid email address.");

		UserStore us = Database.getUserStore();
		User u = us.getUserByEmail(email);
		enforce(u.email != email, "Email already in use.");

		string password1 = formdata.get("password1");
		string password2 = formdata.get("password2");
		enforce(password1 == password2, "Passwords do not match.");

		// passwordData[0] => hash, passwordData[1] => salt
		string[] passwordData = PasswordHelper.hashPassword(password1);

		string passwordHash = passwordData[0];
		string salt = passwordData[1];

		auto id = BsonObjectID.generate();

		string activatonHash = randomUUID.toString();
		DateTime now = Clock.currTime().to!DateTime;
		User newUser = User(id, email, passwordHash, salt, false, activatonHash, now);
		us.storeUser(newUser);
		sendActivationMail(newUser);
		ConnectionStore cs = Database.getConnectionStore();
		cs.storeConnections(Connections(id, BsonObjectID.generate(), []));

		redirect(EnvData.getBaseUrl() ~ "login");
	}

	void postLogin(HTTPServerRequest req, HTTPServerResponse res)
	{
		import std.digest.sha;
		import std.conv;
		import std.stdio;

		auto formdata = req.form;
		string email = formdata.get("email");
		string password = formdata.get("password");

		UserStore us = Database.getUserStore();
		User u = us.getUserByEmail(email);

		import helpers.password;

		PasswordHelper.checkPassword(u, password);

		if (!req.session)
		{
			req.session = res.startSession();
		}

		import models.authinfo;

		AuthInfo ai;
		ai.userId = u._id.toString();
		ai.userName = u.email;
		ai.active = u.isActivated;
		ai.admin = false;
		ai.premium = false;

		req.session.set!AuthInfo("auth", ai);
		res.redirect(EnvData.getBaseUrl() ~ "dashboard");
	}

	void getForgotPassword(string error)
	{
		render!("forgotpassword.dt", error);
	}

	void postForgotPassword(HTTPServerRequest req, HTTPServerResponse res, string email)
	{
		UserStore us = Database.getUserStore();
		User u = us.getUserByEmail(email);

		enforce(u.email == email, "Something went wrong.");

		ResetStore rs = Database.getResetStore();
		ResetCode oldCode = rs.getResetCodeByMail(email);

		if(oldCode.email == email) {
			sendForgotPasswordMail(oldCode);
		} else {
			ResetCode rc = ResetCode(
				BsonObjectID.generate(),
				email,
				randomUUID.toString()
			);

			rs.setResetCode(rc);
			sendForgotPasswordMail(rc);
		}

		redirect(EnvData.getBaseUrl());
	}

	void getResetPassword(string _error, string token)
	{
		string error = _error;
		render!("resetpassword.dt", error, token);
	}

	void postResetPassword(string token, string password1, string password2)
	{
		enforce(password1 == password2, "Passwords have to match.");
		UserStore us = Database.getUserStore();
		ResetStore rs = Database.getResetStore();

		string[] passwordArray = PasswordHelper.hashPassword(password1);
		string passwordHash = passwordArray[0];
		string salt = passwordArray[1];

		ResetCode rc = rs.getResetCodeByToken(token);
		User u = us.getUserByEmail(rc.email);

		us.updateUserPassword(u._id, passwordHash, salt);
		rs.removeResetCode(rc);

		redirect(EnvData.getBaseUrl() ~ "login");
	}
}
