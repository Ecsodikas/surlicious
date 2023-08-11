module controller.homecontroller;

import vibe.vibe;

public class HomeController
{
    void index()
    {
        string error = null;
        render!("index.dt", error);
    }

    void imprint()
    {
        string error = null;
        render!("imprint.dt", error);
    }
}
