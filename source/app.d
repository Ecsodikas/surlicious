import vibe.vibe;

// Database
import database.database;
import database.userstore;
import database.connectionstore;
// Models
import models.connection;
import models.user;
import models.userdata;
import models.heartbeat;
// Controllers
import controller.homecontroller;
import controller.documentationcontroller;
import controller.usercontroller;
import controller.dashboardcontroller;
import controller.settingscontroller;
import controller.connectionscontroller;
import helpers.mail;


class SurliciousApplication
{
	private SessionVar!(UserData, "user") user;
	mixin PrivateAccessProxy;
	private string ensureAuth(HTTPServerRequest req, HTTPServerResponse res)
	{
		if (!user.loggedIn)
		{
			redirect("/login");
		}
		return user.uuid;
	}
	private enum auth = before!ensureAuth("_authUser");

	private void getError(HTTPServerResponse res, string _error = null) {
		res.writeBody(_error);
	}

	// Routes

	// Home
	@method(HTTPMethod.GET)
	void index()
	{	
		auto hc = new HomeController(this.user.value);
		hc.index();
	}

	// Documentation
	@method(HTTPMethod.GET)
	void documentation()
	{	
		auto dc = new DocumentationController(this.user.value);
		dc.index();

	}

	// User Controls
	@method(HTTPMethod.GET)
	void getLogin(string _error)
	{
		auto uc = new UserController(this.user.value);
		uc.getLogin(_error);
	}

	@method(HTTPMethod.GET)
	void logout()
	{
		auto uc = new UserController(this.user.value);
		uc.getLogout();
	}

	@method(HTTPMethod.POST)
	@errorDisplay!getLogin
	void login(HTTPServerRequest req, HTTPServerResponse res) {
		auto uc = new UserController(this.user.value);
		uc.postLogin(req, res);
	}

	@method(HTTPMethod.GET)
	void getRegister(string _error)
	{
		auto uc = new UserController(this.user.value);
		uc.getRegister(_error);
	}

	@method(HTTPMethod.POST)
	@errorDisplay!getRegister
	void register(HTTPServerRequest req, HTTPServerResponse res)
	{
		auto uc = new UserController(this.user.value);
		uc.postRegister(req, res);
	}

	// AUTHENTICATED ROUTES

	// Dashboard
	@auth
	@method(HTTPMethod.GET)
	void dashboard(string _authUser)
	{	
		auto dc = new DashboardController(this.user.value);
		dc.index();
	}

	// Settings
	@auth
	@method(HTTPMethod.GET)
	void settings(string _authUser)
	{
		auto sc = new SettingsController(this.user.value);
		sc.index();
	}
	
	// Connections
	@auth
	@method(HTTPMethod.GET)
	void connections(string _authUser)
	{	
		auto cc = new ConnectionsController(this.user.value);
		cc.index(_authUser);
	}

	@auth
	@method(HTTPMethod.GET)
	@path("addconnection")
	void getAddConnection(string _authUser, string _error) {	
		auto cc = new ConnectionsController(this.user.value);
		cc.getAddConnection(_authUser, _error);
	}

	@auth
	@method(HTTPMethod.POST)
	@path("removeconnection")
	void removeConnection(HTTPServerRequest req, HTTPServerResponse res, string _authUser) {	
		auto cc = new ConnectionsController(this.user.value);
		cc.postRemoveConnection(req, res, _authUser);
	}

	@auth
	@method(HTTPMethod.POST)
	void recreateapikey(HTTPServerRequest req, HTTPServerResponse res, string _authUser) 
	{
		auto cc = new ConnectionsController(this.user.value);
		cc.postRecreateApiKey(req, res, _authUser);
	}

	@auth
	@method(HTTPMethod.POST)
	void setconnectionstatus(HTTPServerRequest req, HTTPServerResponse res, string _authUser) 
	{
		auto cc = new ConnectionsController(this.user.value);
		cc.postSetConnectionStatus(req, res, _authUser);
	}

	@auth
	@method(HTTPMethod.POST)
	@errorDisplay!getAddConnection
	void addconnection(HTTPServerRequest req, HTTPServerResponse res, string _authUser) {
		auto cc = new ConnectionsController(this.user.value);
		cc.postAddConnection(req, res, _authUser);
	}

	@method(HTTPMethod.POST)
	void heartbeat(HTTPServerRequest req, HTTPServerResponse res) 
	{	
		/** 
		 * {
    	 *	  "dateTime": "2018-01-01T12:30:10"
		 *    "apiKey": "42154153245wefdsfg324"
		 *    "connectionId": "jfdksl92j32922n"
		 * }
		 */
		auto cc = new ConnectionsController(this.user.value);
		Heartbeat heartbeat = req.json().deserializeJson!Heartbeat();
		cc.postHeartbeat(heartbeat);
	}
}

void main()
{	
	auto router = new URLRouter();
	router.registerWebInterface(new SurliciousApplication());
	router.get("*", serveStaticFiles("public/"));
	auto settings = new HTTPServerSettings;
	settings.sessionStore = new MemorySessionStore();
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings, router);
	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication();
}
