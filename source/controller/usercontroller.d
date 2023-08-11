module controller.usercontroller;

import vibe.vibe;
import models.user;
import models.authinfo;
import database.userstore;
import database.connectionstore;
import database.database;
import models.connection;
import helpers.env;


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

		if(u.isActivated || u._id == BsonObjectID.init) {
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
		import std.uuid;
		import std.net.isemail;
		import helpers.password;
		import helpers.mail;

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
}
