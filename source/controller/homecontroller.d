module controller.homecontroller;

import vibe.vibe;

public class HomeController
{
    void index()
    {
        string error = null;
        string success = null;
        render!("index.dt", error, success);
    }

    void imprint()
    {
        string error = null;
        string success = null;
        render!("imprint.dt", error, success);
    }
}
