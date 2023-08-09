module models.authinfo;

struct AuthInfo
{
	string userName;
	string userId;
	bool active;
	bool premium;
	bool admin;

@safe:
	bool isAdmin()
	{
		return this.admin;
	}

	bool isActive()
	{
		return this.active;
	}

	bool isPremiumUser()
	{
		return this.premium;
	}
}