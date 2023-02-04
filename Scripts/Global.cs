using System;
using Godot;

namespace Arcomage.Scripts
{
    public class Global : Node
    {
        public static Table Table { get; set; }
        public static Settings Settings { get; set; }
        public static string BuildNumber { get; set; }

        public override void _Ready()
        {
            OS.LowProcessorUsageMode = true;
            BuildNumber = LoadBuildNumber();
        }

        public static void Log(string text) {
            GD.Print($"[{GetTime()}] {text}");
        }

        private static string GetTime()
        {
            return DateTime.Now.ToString("HH:mm:ss");
        }

        private static string LoadBuildNumber()
        {
            var file = new File();
            const string fileName = "res://build.tres";
            if (file.FileExists(fileName))
            {
                file.Open(fileName, File.ModeFlags.Read);
                var content = file.GetAsText();
                file.Close();
                return content;
            }
            else
            {
                GD.PrintErr("Build.tres file missing");
                return "00000000";
            }
        }
    }
}