module controller.connectionscontroller;

import vibe.vibe;

import models.connection;
import models.heartbeat;
import models.authinfo;
import models.user;

import database.connectionstore;
import database.userstore;
import database.database;

import helpers.mail;
import helpers.env;

public class ConnectionsController
{
	void index(string userId, string _error)
	{
		ConnectionStore cs = Database.getConnectionStore();
		Connections connections = cs.getConnections(userId);
		string error = _error;
		string success = null;
		render!("connections.dt", connections, error, success);
	}

	void getAddConnection(string userId, string error)
	{
		ConnectionStore cs = Database.getConnectionStore();
		Connections connections = cs.getConnections(userId);
		string success = null;
		render!("addconnection.dt", connections, error, success);
	}

	void postSetConnectionStatus(HTTPServerRequest req, HTTPServerResponse res, string userId)
	{
		auto formdata = req.form;
		ConnectionStore cs = Database.getConnectionStore();
		cs.setConnectionStatus(formdata.get("status"), userId, formdata.get("connection_id"));
		Connections connections = cs.getConnections(userId);
		string error = null;
		string success = "Connection status changed successfully.";
		render!("connections.dt", connections, error, success);
	}

	void postAddConnection(HTTPServerRequest req, HTTPServerResponse res, AuthInfo ai)
	{
		auto formdata = req.form;

		enforce(ai.isActive(), "Account is not active. Please activate your account in the settings menu.");

		ConnectionStore cs = Database.getConnectionStore();
		Connections connections = cs.getConnections(ai.userId);
		if (connections.connections.length < 5)
		{
			cs.addConnection(formdata.get("name"), ai.userId);
			connections = cs.getConnections(ai.userId);
			string error = null;
			string success = "Connection added successfully.";
			render!("connections.dt", connections, error, success);
		}
		throw new Exception("Maximum amount of connections reached.");
	}

	void postRemoveConnection(HTTPServerRequest req, HTTPServerResponse res, string userId)
	{
		auto formdata = req.form;
		BsonObjectID connectionId = BsonObjectID.fromString(formdata.get("connection_id"));
		ConnectionStore cs = Database.getConnectionStore();
		cs.removeConnection(connectionId, userId);
		string error = null;
		string success = "Connection removed successfully.";
		Connections connections = cs.getConnections(userId);
		render!("connections.dt", connections, error, success);
	}

	void postRecreateApiKey(HTTPServerRequest req, HTTPServerResponse res, string userId)
	{
		auto formdata = req.form;
		ConnectionStore cs = Database.getConnectionStore();
		cs.recreateApiKey(formdata.get("api_key"), userId);
		string error = null;
		string success = "API-key was recreated successfully.";
		Connections connections = cs.getConnections(userId);
		render!("connections.dt", connections, error, success);
	}

	void postHeartbeat(Heartbeat heartbeat)
	{
		ConnectionStore cs = Database.getConnectionStore();
		cs.getConnectionsByHeartbeat(heartbeat);
	}

	void sendAlertMails()
	{
		ConnectionStore cs = Database.getConnectionStore();
		UserStore us = Database.getUserStore();
		Connections[] conss = cs.getFlatLineConnections();

		foreach (Connections cons; conss)
		{
			if (cons.connections.length == 0)
			{
				continue;
			}
			User u = us.getUserById(cons.user_id.toString());
			sendAlertMail(u, cons);
		}

	}
}
