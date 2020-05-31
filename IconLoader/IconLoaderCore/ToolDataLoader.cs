using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;

namespace IconLoader
{
    public struct ToolData
    {
        public ToolData(string plugin, List<string> inputs, List<string> outputs, string icon)
        {
            Plugin = plugin;
            Inputs = inputs;
            Outputs = outputs;
            Icon = icon;
        }
        public readonly string Plugin;
        public readonly List<string> Inputs;
        public readonly List<string> Outputs;
        public readonly string Icon;
    }

    public class ToolDataLoader
    {
        public ToolDataLoader(string installPath)
        {
            _binPath = Path.Combine(installPath, "bin");
            _pluginPath = Path.Combine(_binPath, "Plugins");
            _additionalPluginsPath = Path.Combine(installPath, "Settings", "AdditionalPlugins");
            AppDomain.CurrentDomain.AssemblyResolve += Resolve;
        }

        private readonly string _binPath;
        private readonly string _pluginPath;
        private readonly string _additionalPluginsPath;

        public List<ToolData> LoadToolData()
        {
            SetDllDirectory(_binPath);
            var toolData = LoadDllTools();
            return toolData;
        }

        private List<ToolData> LoadDllTools()
        {
            var folders = new List<string>(){_pluginPath, _binPath};
            foreach (var ini in Directory.GetFiles(_additionalPluginsPath, "*.ini"))
            {
                var additionalPluginFolder = ReadIniPath(ini);
                if (additionalPluginFolder != "")
                {
                    folders.Add(additionalPluginFolder);
                }
            }

            var toolData = new List<ToolData>();
            var pluginType = "AlteryxGuiToolkit.Plugins.IPlugin";
            var interfaceFilter = new TypeFilter(InterfaceFilter);
            var toBytes = new ImageConverter();

            foreach (var folder in folders)
            {
                var dlls = Directory.GetFiles(folder, "*.dll");
                foreach (var dll in dlls)
                {
                    Assembly assy;
                    Type[] types;
                    try
                    {
                        assy = Assembly.LoadFrom(dll);
                        types = assy.GetTypes();
                    }
                    catch (ReflectionTypeLoadException ex)
                    {
                        types = ex.Types;
                    }
                    catch
                    {
                        continue;
                    }
                    
                    foreach (var type in types)
                    {
                        if (type == null)
                        {
                            continue;
                        }

                        var found = type.FindInterfaces(interfaceFilter, pluginType);
                        if (found.Length > 0)
                        {
                            ConstructorInfo pluginConstructor = type.GetConstructor(Type.EmptyTypes);
                            if (pluginConstructor == null) continue;
                            MethodInfo getIcon = type.GetMethod("GetIcon");
                            if (getIcon == null) continue;
                            MethodInfo getInputConnections = type.GetMethod("GetInputConnections");
                            if (getInputConnections == null) continue;
                            MethodInfo getOutputConnections = type.GetMethod("GetOutputConnections");
                            if (getOutputConnections == null) continue;

                            try
                            {
                                object plugin = pluginConstructor.Invoke(new object[] { });
                                var icon = getIcon.Invoke(plugin, new object[] { });
                                var raw = toBytes.ConvertTo(icon, typeof(byte[])) as byte[];
                                var base64 = raw == null ? "" : Convert.ToBase64String(raw);
                                var inConns = GetConnectionInfo(getInputConnections, plugin);
                                var outConns = GetConnectionInfo(getOutputConnections, plugin);
                                var data = new ToolData(type.FullName, inConns, outConns, base64);
                                toolData.Add(data);
                            }
                            catch
                            {
                            }
                        }
                    }
                }
            }
            return toolData;
        }

        private static List<String> GetConnectionInfo(MethodInfo method, object plugin)
        {
            var connections = method.Invoke(plugin, new object[] { }) as IEnumerable;
            if (connections == null) connections = new object[] { };
            var connectionInfo = new List<string>();

            foreach (var connection in connections)
            {
                var connType = connection.GetType();
                var nameField = connType.GetField("m_strName");
                var name = nameField.GetValue(connection) as string;
                connectionInfo.Add(name);
            }

            return connectionInfo;
        }
        
        private static bool InterfaceFilter(Type typeObj,Object criteriaObj)
        {
            if(typeObj.ToString() == criteriaObj.ToString())
                return true;
            return false;
        }

        private Assembly Resolve(object sender, ResolveEventArgs args)
        {
            var fileName = args.Name.Split(',')[0] + ".dll";
            var path = Path.Combine(_binPath, fileName);
            if (File.Exists(path))
            {
                Assembly asm = Assembly.LoadFrom(path);
                return asm;
            }

            return null;
        }

        private string ReadIniPath(string ini)
        {
            var retVal = new StringBuilder(255);
            GetPrivateProfileString("Settings", "x64Path", "", retVal, 255, ini);
            return retVal.ToString();
        }

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool SetDllDirectory(string lpPathName);
        
        [DllImport("kernel32", CharSet = CharSet.Unicode)]
        static extern int GetPrivateProfileString(string section, string key, string defaultValue, StringBuilder retVal, int size, string filePath);
    }
}