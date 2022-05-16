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
            _originalContainer = GetNode<VBoxContainer>("original_info");
            _remakeContainer = GetNode<VBoxContainer>("remake_info");
            _translationContainer = GetNode<VBoxContainer>("translation_info");
            _authorLabel = GetNode<Label>("remake_info/text/author");
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
        private void OnGamejoltPressed() => OS.ShellOpen("https://gamejolt.com/games/arcomage/537808");
        private void OnBmcPressed() => OS.ShellOpen("https://www.buymeacoffee.com/darkpro1337");
        private void OnPatreonPressed() => OS.ShellOpen("https://patreon.com/darkpro1337");
        private void OnKofiPressed() => OS.ShellOpen("https://ko-fi.com/darkpro1337");
    }
}
