module controller.homecontroller;

import vibe.vibe;

import models.userdata;

public class HomeController
{
    UserData user;

    public this(UserData user)
    {
        this.user = user;
    }

    @method(HTTPMethod.GET)
    void index()
    {
        auto currentUser = this.user;
        string _error = null;
        render!("index.dt", currentUser, _error);
    }
}
