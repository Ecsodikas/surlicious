module controller.connectionscontroller;

import vibe.vibe;

import models.userdata;
import models.connection;
import database.database;
import database.connectionstore;
import models.heartbeat;

public class ConnectionsController
{
	UserData user;

	public this(UserData user)
	{
		this.user = user;
	}

	void index(string _authUser)
	{
		ConnectionStore cs = Database.getConnectionStore();
		Connections connections = cs.getConnections(_authUser);
		auto currentUser = this.user;
		string _error = null;
		render!("connections.dt", currentUser, connections, _error);
	}

	void getAddConnection(string _authUser, string _error)
	{
		auto currentUser = this.user;
		ConnectionStore cs = Database.getConnectionStore();
		Connections connections = cs.getConnections(_authUser);
		render!("addconnection.dt", currentUser, connections, _error);
	}

	void postSetConnectionStatus(HTTPServerRequest req, HTTPServerResponse res, string _authUser)
	{
		auto formdata = req.form;
		ConnectionStore cs = Database.getConnectionStore();
		cs.setConnectionStatus(formdata.get("status"), _authUser, formdata.get("connection_id"));
		res.redirect("/connections");
	}

	void postAddConnection(HTTPServerRequest req, HTTPServerResponse res, string _authUser)
	{
		auto formdata = req.form;

		ConnectionStore cs = Database.getConnectionStore();
		if (cs.getConnections(_authUser).connections.length < 5)
		{
			cs.addConnection(formdata.get("name"), _authUser);
			res.redirect("/connections");
		}
		throw new Exception("Maximum amount of connections reached.");
	}

	void postRemoveConnection(HTTPServerRequest req, HTTPServerResponse res, string _authUser) {
		auto formdata = req.form;
		BsonObjectID connectionId = BsonObjectID.fromString(formdata.get("connection_id"));
		ConnectionStore cs = Database.getConnectionStore();
		cs.removeConnection(connectionId, _authUser);
		res.redirect("/connections");
	}

	void postRecreateApiKey(HTTPServerRequest req, HTTPServerResponse res, string _authUser)
	{
		auto formdata = req.form;
		ConnectionStore cs = Database.getConnectionStore();
		cs.recreateApiKey(formdata.get("api_key"), _authUser);
		res.redirect("/connections");
	}

	void postHeartbeat(Heartbeat heartbeat)
	{
		ConnectionStore cs = Database.getConnectionStore();
		cs.getConnectionsByHeartbeat(heartbeat);
	}
}
