module controller.usercontroller;

import vibe.vibe;
import models.user;
import models.userdata;
import database.userstore;
import database.connectionstore;
import database.database;
import models.userdata;
import models.connection;

public class UserController
{
	UserData user;

	public this(UserData user)
	{
		this.user = user;
	}

	void getLogin(string _error)
	{
		auto currentUser = this.user;
		render!("login.dt", currentUser, _error);
	}

	public void validateAccount(string activationHash)
	{
		UserStore us = Database.getUserStore();
		User u = us.getUserByActivationHash(activationHash);

		if(u.isActivated || u._id == BsonObjectID.init) {
			//TODO: Error handling
			redirect("login");
		}

		us.activateAccount(activationHash);
		redirect("login");
	}

	void getRegister(string _error)
	{
		auto currentUser = this.user;
		render!("register.dt", currentUser, _error);
	}

	void getLogout()
	{
		terminateSession();
		redirect("/");
	}

	void postRegister(HTTPServerRequest req, HTTPServerResponse res)
	{
		import std.digest.sha;
		import std.digest.md;
		import std.uuid;
		import std.conv;
		import std.stdio;
		import std.algorithm;
		import std.ascii;
		import std.random;
		import std.range;
		import std.net.isemail;

		import helpers.mail;

		auto formdata = req.form;
		string email = formdata.get("email");

		EmailStatus es = isEmail(email);

		if (!es.valid)
		{
			throw new Exception("No valid email address.");
		}

		UserStore us = Database.getUserStore();
		User u = us.getUserByEmail(email);

		if (u.email != "")
		{
			throw new Exception("Email already in use.");
		}

		string password1 = formdata.get("password1");
		string password2 = formdata.get("password2");
		string name = formdata.get("name");

		if (password1 != password2)
		{
			throw new Exception("Passwords do not match.");
		}

		int[] alphabet = [
			1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
			11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
			21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
			31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
			41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
		];

		string salt = iota(15).map!(_ => alphabet.choice()).array().to!string;
		auto sha1 = new SHA1Digest();
		string passwordHash = sha1.digest(password1 ~ salt).toHexString();
		auto id = BsonObjectID.generate();

		string activatonHash = randomUUID.toString();

		User newUser = User(id, email, name, passwordHash, salt, false, activatonHash);
		us.storeUser(newUser);
		sendActivationMail(newUser);
		ConnectionStore cs = Database.getConnectionStore();
		cs.storeConnections(Connections(id, BsonObjectID.generate(), []));

		redirect("/login");
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

		auto sha1 = new SHA1Digest();
		string passwordHash = sha1.digest(password ~ u.salt).toHexString();

		if (u.password == passwordHash)
		{
			if (!req.session)
			{
				req.session = res.startSession();
			}

			UserData ud;
			ud.loggedIn = true;
			ud.name = u.name;
			ud.isActive = u.isActivated;
			ud.uuid = u._id.toString();

			req.session.set!UserData("user", ud);
			res.redirect("/dashboard");
		}
		throw new Exception("Invalid login credentials.");
	}
}
