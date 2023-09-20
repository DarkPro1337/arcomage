using Godot;
using static Arcomage.Scripts.Global;

namespace Arcomage.Scripts;

public partial class Boot : Node
{
	public override void _Ready() 
	{
		var version = ProjectSettings.GetSetting("application/config/version");
		Log($"Arcomage v.{version} loaded!");
		Log($"Build number: {BuildNumber}");
		Log("Boot loaded!");
		Log($"IP address: {Network.IpAddress}");

		if (!Config.Settings.IntroSkip)
		{
			Log("Loading from Boot to Intro...");
			GetTree().ChangeSceneToFile("res://Scenes/intro.tscn");
		}
		else
		{
			Log("Loading from Boot to Main menu...");
			GetTree().ChangeSceneToFile("res://Scenes/MainMenu.tscn");
		}
	}
}