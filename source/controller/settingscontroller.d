module controller.settingscontroller;

import vibe.vibe;

import models.userdata;

public class SettingsController
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
		render!("settings.dt", currentUser, _error);
	}
}
