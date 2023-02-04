using Godot;

namespace Arcomage.Scripts
{
    public class MainMenu : Control
    {
        private Control _settings;
        private Control _networkSetup;
        private AnimationPlayer _startupAnim;
        private AnimationPlayer _menuAnim;
        private Control _credits;
        private Label _version;
        private Label _buildNumber;
        private Theme _mainMenuTheme;

        public override void _EnterTree()
        {
            base._EnterTree();
            _settings = GetNode<Control>("Settings");
            _networkSetup = GetNode<Control>("NetworkSetup");
            _startupAnim = GetNode<AnimationPlayer>("StartupAnim");
            _menuAnim = GetNode<AnimationPlayer>("MenuAnim");
            _credits = GetNode<Control>("Credits");
            _version = GetNode<Label>("Logo/Ver");
            _buildNumber = GetNode<Label>("BuildNumber");
            _mainMenuTheme = (Theme)ResourceLoader.Load("res://themes/main_menu_theme.tres");
            
            var newGameButton = GetNode<Button>("MenuGrid/NewGame");
            var multiplayerGameButton = GetNode<Button>("MenuGrid/MultiplayerGame");
            var settingsButton = GetNode<Button>("MenuGrid/Settings");
            var leaderboardButton = GetNode<Button>("MenuGrid/Leaderboard");
            var creditsButton = GetNode<Button>("MenuGrid/Credits");
            var exitButton = GetNode<Button>("MenuGrid/Exit");

            newGameButton.Connect("pressed", this, nameof(OnNewGamePressed));
            multiplayerGameButton.Connect("pressed", this, nameof(OnMultiplayerGamePressed));
            settingsButton.Connect("pressed", this, nameof(OnSettingsPressed));
            leaderboardButton.Connect("pressed", this, nameof(OnLeaderboardPressed));
            creditsButton.Connect("pressed", this, nameof(OnCreditsPressed));
            exitButton.Connect("pressed", this, nameof(OnExitPressed));
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
            GetTree().ChangeScene("res://Scenes/Table.tscn");
        }

        private void OnSettingsPressed()
        {
            _settings.Show();
            _menuAnim.Play("settings_show");
        }
        
        private void OnMultiplayerGamePressed() => _networkSetup.Show();
        private void OnLeaderboardPressed() => Alert(Tr("WORK_IN_PROGRESS"), "Oops");
        private void OnCreditsPressed() => _credits.Show();
        private void OnExitPressed() => GetTree().Quit();

        private void Alert(string text, string title = "Alert")
        {
            var dialog = new AcceptDialog();
            dialog.Theme = _mainMenuTheme;
            dialog.DialogText = text;
            dialog.WindowTitle = title;
            dialog.Connect("modal_connected", dialog, "queue_free");
            AddChild(dialog);
            dialog.PopupCentered();
        }
    }
}
