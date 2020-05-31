using System;
using System.IO;
using Newtonsoft.Json;


namespace IconLoader
{
    public static class ConfigLoader
    {
        private struct Config
        {
            public string InstallPath;
        }
        
        public static string LoadInstallPath()
        { 
            var folder = AppDomain.CurrentDomain.BaseDirectory;
            var configFile = Path.Combine(folder, "config.json");
            var configContent = System.IO.File.ReadAllText(configFile);
            var config = JsonConvert.DeserializeObject<Config>(configContent);
            return config.InstallPath;
        }
    }
}