using Godot;

namespace Arcomage.Scripts
{
    public class Info : Control
    {
        private VBoxContainer _originalContainer;
        private VBoxContainer _remakeContainer;
        private VBoxContainer _translationContainer;
        private Label _authorLabel;

        public override void _EnterTree()
        {
            base._EnterTree();
            _originalContainer = GetNode<VBoxContainer>("OriginalInfo");
            _remakeContainer = GetNode<VBoxContainer>("RemakeInfo");
            _translationContainer = GetNode<VBoxContainer>("TranslationInfo");
            _authorLabel = GetNode<Label>("RemakeInfo/Text/Author");

            var authorLabel = GetNode<Label>("RemakeInfo/Text/Author");
            var engineButton = GetNode<TextureButton>("RemakeInfo/Logos/Engine");
            var githubButton = GetNode<TextureButton>("RemakeInfo/Logos/GitHub");
            var trelloButton = GetNode<TextureButton>("RemakeInfo/Logos/Trello");
            var itchButton = GetNode<TextureButton>("RemakeInfo/Logos/Itch");
            var gameJoltButton = GetNode<TextureButton>("RemakeInfo/Logos/GameJolt");
            var bmcButton = GetNode<TextureButton>("RemakeInfo/Logos/Bmc");
            var patronButton = GetNode<TextureButton>("RemakeInfo/Logos/Patreon");
            var kofiButton = GetNode<TextureButton>("RemakeInfo/Logos/Kofi");
            var nextButton = GetNode<Button>("Next");

            authorLabel.Connect("gui_input", this, nameof(OnAuthorGuiInput));
            authorLabel.Connect("mouse_entered", this, nameof(OnAuthorMouseEntered));
            authorLabel.Connect("mouse_exited", this, nameof(OnAuthorMouseExited));
            engineButton.Connect("pressed", this, nameof(OnEnginePressed));
            githubButton.Connect("pressed", this, nameof(OnGithubPressed));
            trelloButton.Connect("pressed", this, nameof(OnTrelloPressed));
            itchButton.Connect("pressed", this, nameof(OnItchPressed));
            gameJoltButton.Connect("pressed", this, nameof(OnGameJoltPressed));
            bmcButton.Connect("pressed", this, nameof(OnBmcPressed));
            patronButton.Connect("pressed", this, nameof(OnPatronPressed));
            kofiButton.Connect("pressed", this, nameof(OnKofiPressed));
            nextButton.Connect("pressed", this, nameof(OnNextPressed));
        }

        public override void _Ready()
        {
            _originalContainer.Show();
            _remakeContainer.Hide();
            _translationContainer.Hide();
        }

        private void OnNextPressed()
        {
            if (_originalContainer.Visible)
            {
                _originalContainer.Hide();
                _remakeContainer.Show();
            }
            else if (_remakeContainer.Visible)
            {
                _translationContainer.Show();
                _remakeContainer.Hide();
            }
            else if (_translationContainer.Visible)
            {
                _originalContainer.Show();
                _translationContainer.Hide();
                Hide();
            }
        }
    
        private void OnAuthorGuiInput(InputEvent @event)
        {
            if (@event is InputEventMouseButton btn && btn.IsPressed() && btn.ButtonIndex == 1)
                OS.ShellOpen("https://darkpro1337.github.io");
        }

        private void OnAuthorMouseEntered() => _authorLabel.Modulate = new Color("#ff993f");
        private void OnAuthorMouseExited() => _authorLabel.Modulate = new Color("#ffffff");
    
        private void OnEnginePressed() => OS.ShellOpen("https://godotengine.org");
        private void OnGithubPressed() => OS.ShellOpen("https://github.com/DarkPro1337/arcomage");
        private void OnTrelloPressed() => OS.ShellOpen("https://trello.com/b/nQuzlNk5/arcomage-remake");
        private void OnItchPressed() => OS.ShellOpen("https://darkpro1337.itch.io/arcomage");
        private void OnGameJoltPressed() => OS.ShellOpen("https://gamejolt.com/games/arcomage/537808");
        private void OnBmcPressed() => OS.ShellOpen("https://www.buymeacoffee.com/darkpro1337");
        private void OnPatronPressed() => OS.ShellOpen("https://patreon.com/darkpro1337");
        private void OnKofiPressed() => OS.ShellOpen("https://ko-fi.com/darkpro1337");
    }
}
