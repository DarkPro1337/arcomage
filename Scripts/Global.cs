using System;
using Godot;

namespace Arcomage.Scripts
{
    public partial class Global : Node
    {
        public static Table Table { get; set; }
        public static Settings Settings { get; set; }
        public static string BuildNumber { get; private set; }

        public override void _Ready()
        {
            OS.LowProcessorUsageMode = true;
            BuildNumber = LoadBuildNumber();
        }

        public static void Log(string text) => 
            GD.Print($"[{GetTime()}] {text}");

        private static string GetTime() => 
            DateTime.Now.ToString("HH:mm:ss");

        private static string LoadBuildNumber()
        {
            const string fileName = "res://build.tres";
            if (FileAccess.FileExists(fileName))
            {
                using var file = FileAccess.Open(fileName, FileAccess.ModeFlags.Read);
                var content = file.GetAsText();
                file.Close();
                return content;
            }

            GD.PrintErr("Build.tres file missing");
            return "00000000";
        }
    }
}