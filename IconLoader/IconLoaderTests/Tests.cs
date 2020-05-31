using System;
using System.Drawing;
using System.Reflection;
using IconLoader;
using Newtonsoft.Json;
using NUnit.Framework;

namespace IconLoaderTests
{
    
    [TestFixture]
    public class Tests
    {
        [Test]
        public void TestLoadToolData()
        {
            var loader = new ToolDataLoader(@"C:\Program Files\Alteryx");
            Assert.DoesNotThrow(() =>
            {
                var result = loader.LoadToolData();
                Assert.IsNotNull(result);
                Assert.IsTrue(result.Count > 0);
                Console.WriteLine(JsonConvert.SerializeObject(result));
            }); 
        }

        [Test]
        public void TestLoadInstallPath()
        {
            var installPath = ConfigLoader.LoadInstallPath();
            Assert.AreEqual(@"C:\Program Files\Alteryx", installPath);
        }

        [Test]
        public void TestLoadQuestionIcon()
        {
            var dll = @"C:\Program Files\Alteryx\bin\AlteryxGuiToolkit.dll";
            Assembly assy;
            Type[] types;
            assy = Assembly.LoadFrom(dll);
            try
            {
                types = assy.GetTypes();
            } catch (ReflectionTypeLoadException ex)
            {
                types = ex.Types;
            }
            var interfaceFilter = new TypeFilter(InterfaceFilter);
            var pluginTypeString = "AlteryxGuiToolkit.Plugins.IPlugin";
            
            var toBytes = new ImageConverter();
                    
            foreach (var type in types)
            {
                if (type == null)
                {
                    continue;
                }

                var found = type.FindInterfaces(interfaceFilter, pluginTypeString);
                if (found.Length > 0)
                {
                    ConstructorInfo pluginConstructor = type.GetConstructor(Type.EmptyTypes);
                    if (pluginConstructor == null) continue;
                    MethodInfo getIcon = type.GetMethod("GetIcon");
                    if (getIcon == null) continue;
                   
                    try
                    {
                        object plugin= pluginConstructor.Invoke(new object[]{});
                        var icon = getIcon.Invoke(plugin, new object[]{});
                        var raw = toBytes.ConvertTo(icon, typeof(byte[])) as byte[];
                        var base64 = raw == null ? "" : Convert.ToBase64String(raw);
                        Console.WriteLine(base64);
                    }
                    catch
                    {
                    }

                }
            }
        }
        
        private static bool InterfaceFilter(Type typeObj,Object criteriaObj)
        {
            if(typeObj.ToString() == criteriaObj.ToString())
                return true;
            return false;
        }
    }
}

