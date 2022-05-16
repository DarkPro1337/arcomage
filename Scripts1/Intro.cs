using Godot;

namespace Arcomage.Scripts
{
    public class Intro : Control
    {
        public override void _Ready()
        {
            Global.Log("Intro loaded...");
        }

        private void OnAnimPlayerAnimationFinished(string animName)
        {
            if (animName != "init") return;
            Global.Log("Loading to the Main menu...");
            GetTree().ChangeScene("res://scenes/main_menu.tscn");
        }
    }
}
