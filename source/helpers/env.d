module helpers.env;

import std.process;

class EnvData
{
    public static string getBaseUrl()
    {
        return environment.get("BASE_URL", "127.0.0.1:8080/");
    }

        public static string getDBConnectionString()
    {
        return environment.get("CONNECTION_STRING", "mongodb://root:qwe123@127.0.0.1:8889");
    }
}
