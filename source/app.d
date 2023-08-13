import vibe.vibe;
import vibe.web.auth;

// Database
import database.database;
import database.userstore;
import database.connectionstore;

// Models
import models.connection;
import models.user;
import models.authinfo;
import models.heartbeat;

// Controllers
import controller.homecontroller;
import controller.documentationcontroller;
import controller.usercontroller;
import controller.dashboardcontroller;
import controller.settingscontroller;
import controller.connectionscontroller;
import helpers.mail;

@requiresAuth
class SurliciousApplication
{
	// The authentication handler which will be called whenever auth info is needed.
	// Its return type can be injected into the routes of the associated service.
	// (for obvious reasons this shouldn't be a route itself)
	@noRoute
	AuthInfo authenticate(scope HTTPServerRequest req, scope HTTPServerResponse res) @safe
	{
		if (!req.session || !req.session.isKeySet("auth"))
			throw new HTTPStatusException(HTTPStatus.forbidden, "Not authorized to perform this action!");

		return req.session.get!AuthInfo("auth");
	}

	private void getError(HTTPServerResponse res, string _error = null)
	{
		res.writeBody(_error);
	}

	// Home
	@noAuth
	{
		@method(HTTPMethod.GET)
		void index()
		{
			auto hc = new HomeController();
			hc.index();
		}

		@method(HTTPMethod.GET)
		void imprint()
		{
			auto hc = new HomeController();
			hc.imprint();
		}

		// Documentation
		@method(HTTPMethod.GET)
		void documentation()
		{
			auto dc = new DocumentationController();
			dc.index();
		}

		// User Controls
		@method(HTTPMethod.GET)
		void getLogin(string _error)
		{
			auto uc = new UserController();
			uc.getLogin(_error);
		}

		@method(HTTPMethod.POST)
		@errorDisplay!getLogin void postLogin(HTTPServerRequest req, HTTPServerResponse res)
		{
			auto uc = new UserController();
			uc.postLogin(req, res);
		}

		@method(HTTPMethod.GET)
		void logout()
		{
			auto uc = new UserController();
			uc.getLogout();
		}

		@method(HTTPMethod.GET)
		void getRegister(string _error)
		{
			auto uc = new UserController();
			uc.getRegister(_error);
		}

		@method(HTTPMethod.POST)
		@errorDisplay!getRegister void register(HTTPServerRequest req, HTTPServerResponse res)
		{
			auto uc = new UserController();
			uc.postRegister(req, res);
		}

		@method(HTTPMethod.GET)
		@path("validateaccount/:hash")
		void getValidateAccount(HTTPServerRequest req)
		{
			string activationHash = req.params["hash"];
			auto uc = new UserController();
			uc.validateAccount(activationHash);
		}

		@method(HTTPMethod.POST)
		void heartbeat(HTTPServerRequest req, HTTPServerResponse res)
		{
			/** 
			* {
			*    "apiKey": "42154153245wefdsfg324"
			*    "connectionId": "jfdksl92j32922n"
			* }
			*/
			auto cc = new ConnectionsController();
			Heartbeat heartbeat = req.json().deserializeJson!Heartbeat();
			cc.postHeartbeat(heartbeat);
			res.writeJsonBody(["heartbeat": "OK"]);
		}
	}
	
	// AUTHENTICATED ROUTES
	// Dashboard
	@anyAuth
	{
		@method(HTTPMethod.GET)
		void dashboard()
		{
			auto dc = new DashboardController();
			dc.index();
		}

		// Settings
		@method(HTTPMethod.GET)
		void settings(string _error)
		{
			auto sc = new SettingsController();
			sc.index(_error);
		}

		@method(HTTPMethod.POST)
		@path("resendactivationmail")
		void resendActivationMail(AuthInfo ai, HTTPServerRequest req, HTTPServerResponse res)
		{
			auto sc = new SettingsController();
			sc.resendActivationMail(ai.userId);
			terminateSession();
		}

		// Connections
		@method(HTTPMethod.GET)
		void connections(AuthInfo ai, HTTPServerRequest req, string _error)
		{
			auto cc = new ConnectionsController();
			cc.index(ai.userId, _error);
		}

		@method(HTTPMethod.GET)
		@path("addconnection")
		void getAddConnection(AuthInfo ai, HTTPServerRequest req, string _error)
		{
			auto cc = new ConnectionsController();
			cc.getAddConnection(ai.userId, _error);
		}

		@method(HTTPMethod.POST)
		@errorDisplay!getAddConnection void addconnection(AuthInfo ai, HTTPServerRequest req, HTTPServerResponse res)
		{
			auto cc = new ConnectionsController();
			cc.postAddConnection(req, res, ai);
		}

		@method(HTTPMethod.POST)
		@path("removeconnection")
		@errorDisplay!connections void removeConnection(AuthInfo ai, HTTPServerRequest req, HTTPServerResponse res)
		{
			auto cc = new ConnectionsController();
			cc.postRemoveConnection(req, res, ai.userId);
		}

		@method(HTTPMethod.POST)
		void recreateapikey(AuthInfo ai, HTTPServerRequest req, HTTPServerResponse res)
		{
			auto cc = new ConnectionsController();
			cc.postRecreateApiKey(req, res, ai.userId);
		}

		@method(HTTPMethod.POST)
		void setconnectionstatus(AuthInfo ai, HTTPServerRequest req, HTTPServerResponse res)
		{
			auto cc = new ConnectionsController();
			cc.postSetConnectionStatus(req, res, ai.userId);
		}

		@method(HTTPMethod.POST)
		@path("changepassword")
		@errorDisplay!settings void changePassword(AuthInfo ai, string oldpassword, string newpassword1, string newpassword2)
		{
			auto sc = new SettingsController();
			sc.changePassword(ai.userId, oldpassword, newpassword1, newpassword2);
		}
	}
}

void errorPage(HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo errorInfo)
{
	string error = null;
	res.render!("error.dt", req, error, errorInfo);
}

void main()
{
	auto router = new URLRouter();
	router.registerWebInterface(new SurliciousApplication());
	router.get("*", serveStaticFiles("public/"));
	auto settings = new HTTPServerSettings;
	settings.sessionStore = new MemorySessionStore();
	settings.port = 8080;
	settings.bindAddresses = ["0.0.0.0"];
	settings.errorPageHandler = toDelegate(&errorPage);
	listenHTTP(settings, router);
	import helpers.surveilance;

	initialisePeriodicSurveilance();
//	lowerPrivileges("exomie", "exomie");
	runApplication();
}
