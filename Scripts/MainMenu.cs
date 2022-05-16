using Godot;

namespace Arcomage.Scripts
{
    public class MainMenu : Control
    {
        private Control _settings;
        private Control _networkSetup;
        private AnimationPlayer _startupAnim;
        private AnimationPlayer _menuAnim;
        private Control _info;
        private Label _version;
        private Label _buildNumber;

        public override void _EnterTree()
        {
            base._EnterTree();
            _settings = GetNode<Control>("settings");
            _networkSetup = GetNode<Control>("network_setup");
            _startupAnim = GetNode<AnimationPlayer>("startupAnim");
            _menuAnim = GetNode<AnimationPlayer>("menuAnim");
            _info = GetNode<Control>("info");
            _version = GetNode<Label>("logo/ver");
            _buildNumber = GetNode<Label>("build");
        }

        public override void _Ready()
        {
            _version.Text = $"v. {ProjectSettings.GetSetting("application/config/version")}";
            _buildNumber.Text = $"Build: {Global.BuildNumber}";
            GetTree().Paused = false;
            Global.Log("Main menu loaded.");
        }

        private async void OnNewGamePressed()
        {
            _menuAnim.Play("fade_out");
            await ToSignal(_menuAnim, "animation_finished");
            GetTree().ChangeScene("res://scenes/table.tscn");
        }

        private void OnMultiplayerGamePressed() => _networkSetup.Show();

        private void OnSettingsPressed()
        {
            _settings.Show();
            _menuAnim.Play("settings_show");
        }

        private void OnScoresPressed() => Alert(Tr("WORK_IN_PROGRESS"), "Oops");

        private void OnCreditsPressed() => _info.Show();
        private void OnExitPressed() => GetTree().Quit();

        private void Alert(string text, string title = "Alert")
        {
            var dialog = new AcceptDialog();
            dialog.Theme = ResourceLoader.Load("res://themes/main_menu_theme.tres") as Theme;
            dialog.DialogText = text;
            dialog.WindowTitle = title;
            dialog.Connect("modal_connected", dialog, "queue_free");
            AddChild(dialog);
            dialog.PopupCentered();
        }
    }
}
