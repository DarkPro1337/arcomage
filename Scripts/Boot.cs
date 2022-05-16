using System;
using System.Globalization;
using Godot;

namespace Arcomage.Scripts
{
    public class Boot : Node
    {   
        public Boot() 
        {
            GenerateBuildNumber();
        }

        public override void _Ready() 
        {
            var version = ProjectSettings.GetSetting("application/config/version");
            Global.Log($"Arcomage v.{version} loaded!");
            Global.Log($"Build number: {Global.BuildNumber}");
            Global.Log("Boot loaded!");
            Global.Log($"IP: {Network.IpAddress}");

            if (!Config.IntroSkip)
            {
                Global.Log("Loading from Boot to Intro...");
                GetTree().ChangeScene("res://scenes/intro.tscn");
            }
            else
            {
                Global.Log("Loading from Boot to Main menu...");
                GetTree().ChangeScene("res://scenes/main_menu.tscn");
            }
        }

        private static void GenerateBuildNumber() 
        {
            if (OS.IsDebugBuild())
                SaveBuildNumber(GetCurrentBuildNumber());
        }

        private static void SaveBuildNumber(string buildNumber) 
        {
            var file = new File();
            file.Open("res://build.tres", File.ModeFlags.Write);
            file.StoreString(buildNumber);
            file.Close();
        }

        private static string GetCurrentBuildNumber() 
        {
            return DateTime.Today.ToString("ddMMyyyy", CultureInfo.InvariantCulture);
        }
    }
}
