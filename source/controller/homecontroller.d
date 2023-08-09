module controller.homecontroller;

import vibe.vibe;

public class HomeController
{
    @method(HTTPMethod.GET)
    void index()
    {
        string error = null;
        render!("index.dt", error);
    }
}
