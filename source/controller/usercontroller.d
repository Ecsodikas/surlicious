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
		string success = null;
		render!("login.dt", error, success);
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

		string error = null;
		string success = "Account validated.";
		render!("login.dt", error, success);
	}

	void getRegister(string _error)
	{
		string error = _error;
		string success = null;
		render!("register.dt", error, success);
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

		sendNewAccountInformationMail();

		string error = null;
		string success = "Registered successfully. 
		Please check your email account for further instructions on account validation.";
		render!("login.dt", error, success);
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
		string error = null;
		string success = "Logged in successfully.";
		render!("index.dt", error, success);
	}

	void getForgotPassword(string error)
	{
		string success = null;
		render!("forgotpassword.dt", error, success);
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

		string error = null;
		string success = "Password reset process started.
		Please check your email account for further instructions on the password reset process.";
		render!("index.dt", error, success);
	}

	void getResetPassword(string _error, string token)
	{
		string error = _error;
		string success = null;
		render!("resetpassword.dt", error, success, token);
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

		string error = null;
		string success = "Password reset successfully.";
		render!("login.dt", error, success);
	}
}
