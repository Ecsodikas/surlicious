module helpers.env;

import std.process;

class EnvData
{
    public static string getBaseUrl()
    {
        return environment.get("BASE_URL", "http://127.0.0.1:8080/");
    }
}
