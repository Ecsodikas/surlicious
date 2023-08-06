module controller.dashboardcontroller;

import vibe.vibe;

import models.userdata;

public class DashboardController
{
	UserData user;

	public this(UserData user)
	{
		this.user = user;
	}

	void index()
	{
		auto currentUser = this.user;
		string _error = null;
		render!("dashboard.dt", currentUser, _error);
	}
}
