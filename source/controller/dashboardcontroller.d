module controller.dashboardcontroller;

import vibe.vibe;

import models.authinfo;
import models.dashboarddata;

public class DashboardController
{
	private DashboardData generateDashboardData() {
		return DashboardData().init;
	}

	void index()
	{
		string error = null;
		DashboardData dashboardData = this.generateDashboardData();
		render!("dashboard.dt", error, dashboardData);
	}
}
