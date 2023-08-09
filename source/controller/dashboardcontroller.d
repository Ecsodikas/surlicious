module controller.dashboardcontroller;

import vibe.vibe;

import models.authinfo;

public class DashboardController
{
	void index()
	{
		string error = null;
		render!("dashboard.dt", error);
	}
}
