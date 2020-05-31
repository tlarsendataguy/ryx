using System;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace IconLoader
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            try
            {
                var installDirectory = ConfigLoader.LoadInstallPath();
                var loader = new ToolDataLoader(installDirectory);
                var toolData = loader.LoadToolData();
                var response = new Response("", toolData);
                var json = JsonConvert.SerializeObject(response);
                Console.WriteLine(json);
            }
            catch (Exception ex)
            {
                WriteError(ex);
            }
        }

        private static void WriteError(Exception ex)
        {
            var error = $"{ex.Message}: {ex.StackTrace}";
            var response = new Response(error, new List<ToolData>());
            var json = JsonConvert.SerializeObject(response);
            Console.WriteLine(json);
        }
    }

    internal struct Response
    {
        public Response(string error, List<ToolData> toolData)
        {
            Error = error;
            ToolData = toolData;
        }
        public readonly string Error;
        public readonly List<ToolData> ToolData;
    }
}