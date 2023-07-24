using System;
using System.Globalization;
using Godot;

namespace Arcomage.Scripts
{
	public partial class Boot : Node
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
			Global.Log($"IP address: {Network.IpAddress}");

			if (!Config.Settings.IntroSkip)
			{
				Global.Log("Loading from Boot to Intro...");
				GetTree().ChangeSceneToFile("res://Scenes/intro.tscn");
			}
			else
			{
				Global.Log("Loading from Boot to Main menu...");
				GetTree().ChangeSceneToFile("res://Scenes/MainMenu.tscn");
			}
		}

		private static void GenerateBuildNumber() 
		{
			if (OS.IsDebugBuild())
				SaveBuildNumber(GetCurrentBuildNumber());
		}

		private static void SaveBuildNumber(string buildNumber) 
		{
			try
			{
				using var file = FileAccess.Open("res://build.tres", FileAccess.ModeFlags.Write);
				file.StoreString(buildNumber);
				file.Close();
				Global.Log("Build number updated.");
			}
			catch (Exception e)
			{
				Global.Log("Build number cannot be updated due the exception:");
				Global.Log(e.ToString());
			}
		}

		private static string GetCurrentBuildNumber() =>
			DateTime.Today.ToString("ddMMyyyy", CultureInfo.InvariantCulture);
	}
}
