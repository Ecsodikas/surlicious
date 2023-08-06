module controller.documentationcontroller;

import vibe.vibe;

import models.userdata;

public class DocumentationController
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
        render!("documentation.dt", currentUser, _error);
    }
}
