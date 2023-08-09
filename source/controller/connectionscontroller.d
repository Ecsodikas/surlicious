module controller.connectionscontroller;

import vibe.vibe;

import models.authinfo;
import models.connection;
import database.database;
import database.connectionstore;
import models.heartbeat;

public class ConnectionsController
{
	void index(string userId)
	{
		ConnectionStore cs = Database.getConnectionStore();
		Connections connections = cs.getConnections(userId);
		string error = null;
		render!("connections.dt", connections, error);
	}

	void getAddConnection(string userId, string error)
	{
		ConnectionStore cs = Database.getConnectionStore();
		Connections connections = cs.getConnections(userId);
		render!("addconnection.dt", connections, error);
	}

	void postSetConnectionStatus(HTTPServerRequest req, HTTPServerResponse res, string userId)
	{
		auto formdata = req.form;
		ConnectionStore cs = Database.getConnectionStore();
		cs.setConnectionStatus(formdata.get("status"), userId, formdata.get("connection_id"));
		res.redirect("/connections");
	}

	void postAddConnection(HTTPServerRequest req, HTTPServerResponse res, string userId)
	{
		auto formdata = req.form;

		ConnectionStore cs = Database.getConnectionStore();
		if (cs.getConnections(userId).connections.length < 5)
		{
			cs.addConnection(formdata.get("name"), userId);
			res.redirect("/connections");
		}
		throw new Exception("Maximum amount of connections reached.");
	}

	void postRemoveConnection(HTTPServerRequest req, HTTPServerResponse res, string userId) {
		auto formdata = req.form;
		BsonObjectID connectionId = BsonObjectID.fromString(formdata.get("connection_id"));
		ConnectionStore cs = Database.getConnectionStore();
		cs.removeConnection(connectionId, userId);
		res.redirect("/connections");
	}

	void postRecreateApiKey(HTTPServerRequest req, HTTPServerResponse res, string userId)
	{
		auto formdata = req.form;
		ConnectionStore cs = Database.getConnectionStore();
		cs.recreateApiKey(formdata.get("api_key"), userId);
		res.redirect("/connections");
	}

	void postHeartbeat(Heartbeat heartbeat)
	{
		ConnectionStore cs = Database.getConnectionStore();
		cs.getConnectionsByHeartbeat(heartbeat);

	}

	void sendAlertMails() {
		ConnectionStore cs = Database.getConnectionStore();
		cs.getFlatLineConnections();
	}
}
