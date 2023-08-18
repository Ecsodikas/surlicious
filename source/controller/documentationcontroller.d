module controller.documentationcontroller;

import vibe.vibe;
import models.authinfo;

public class DocumentationController
{
    void index()
    {
        string error = null;
        string success = null;
        render!("documentation.dt", error, success);
    }
}
