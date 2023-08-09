module controller.documentationcontroller;

import vibe.vibe;
import models.authinfo;

public class DocumentationController
{
    void index()
    {
        string error = null;
        render!("documentation.dt", error);
    }
}
