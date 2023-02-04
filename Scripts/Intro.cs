using Godot;

namespace Arcomage.Scripts
{
    public class Intro : Control
    {
        public override void _EnterTree()
        {
            base._EnterTree();
            var anim = GetNode<AnimationPlayer>("Anim");
            anim.Connect("animation_finished", this, nameof(OnAnimPlayerAnimationFinished));
        }

        public override void _Ready()
        {
            Global.Log("Intro loaded...");
        }

        private void OnAnimPlayerAnimationFinished(string animName)
        {
            if (animName != "init") return;
            Global.Log("Loading to the Main menu...");
            GetTree().ChangeScene("res://scenes/MainMenu.tscn");
        }
            
        public override void _Input(InputEvent @event)
        {
            base._Input(@event);
            if (!Input.IsActionJustPressed("ui_cancel") && !Input.IsActionJustPressed("ui_select")) return;
            Global.Log("Skipping Intro to the Main menu...");
            GetTree().ChangeScene("res://scenes/MainMenu.tscn");
        }
    }
}
