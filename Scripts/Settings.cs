using System;
using System.Globalization;
using Godot;
using static Arcomage.Scripts.Config;

namespace Arcomage.Scripts
{
    public class Settings : Control
    {
        private string _configPath = "user://settings.ini";
        private readonly CultureInfo _invariantCulture = CultureInfo.InvariantCulture;

        #region Control vars
        private AnimationPlayer _anim;
        private ToolButton _reset;
        private TextureRect _background;
        private TabContainer _tab;

        // Window settings
        private CenterContainer _windowSettings;
        private ToolButton _windowSettingsButton;
        private HBoxContainer _fullscreen;
        private CheckButton _fullscreenButton;
        private CheckButton _borderlessButton;
        private HBoxContainer _windowResolution;
        private LineEdit _windowWidthEdit;
        private LineEdit _windowHeightEdit;
        private CheckButton _vsyncButton;
        private HBoxContainer _introSkip;
        private CheckButton _introSkipButton;

        // Sound settings
        private CenterContainer _soundSettings;
        private ToolButton _soundSettingsButton;
        private HSlider _masterVolume;
        private HSlider _musicVolume;
        private HSlider _soundVolume;
        private CheckBox _muteSound;

        // Starting conditions
        private CenterContainer _startingConditions;
        private ToolButton _startingConditionsButton;
        private CheckBox _singleplayerButton;
        private CheckBox _multiplayerButton;
        private CheckBox _singleClickButton;
        private SpinBox _towerLevels;
        private SpinBox _wallLevels;
        private SpinBox _quarryLevels;
        private SpinBox _brickQuantity;
        private SpinBox _magicLevels;
        private SpinBox _gemQuantity;
        private SpinBox _dungeonLevels;
        private SpinBox _recruitQuantity;
    
        // Play conditions
        private CenterContainer _playConditions;
        private ToolButton _playConditionsButton;
        private SpinBox _autoBricks;
        private SpinBox _autoGems;
        private SpinBox _autoRecruits;
        private SpinBox _cardsInHand;
        private OptionButton _ai;
    
        // Victory conditions
        private CenterContainer _victoryConditions;
        private ToolButton _victoryConditionsButton;
        private SpinBox _winTower;
        private SpinBox _winResources;
    
        // Tavern presets
        private CenterContainer _tavernPresets;
        private ToolButton _tavernPresetsButton;
        private OptionButton _tavernPreset;
    
        // Language settings
        private CenterContainer _languageSettings;
        private ToolButton _languageSettingsButton;
        private OptionButton _language;
        private Label _languageErrors;
    
        // Player settings
        private CenterContainer _playerSettings;
        private ToolButton _playerSettingsButton;
        private LineEdit _nickname;
        #endregion
        
        public override void _EnterTree()
        {
            base._EnterTree();
            #region OnReady vars
            _anim = GetNode<AnimationPlayer>("AnimationPlayer");
            _reset = GetNode<ToolButton>("reset");
            _background = GetNode<TextureRect>("bg");
            _tab = GetNode<TabContainer>("tab");
            
            // Window settings
            _windowSettings = GetNode<CenterContainer>("tab/Graphics");
            _windowSettingsButton = GetNode<ToolButton>("buttons_container/buttons_grid/window_settings");
            _fullscreen = GetNode<HBoxContainer>("tab/Graphics/graphics/fullscreen");
            _fullscreenButton = GetNode<CheckButton>("tab/Graphics/graphics/fullscreen/fullscreen_button");
            _borderlessButton = GetNode<CheckButton>("tab/Graphics/graphics/borderless/borderless_button");
            _windowResolution = GetNode<HBoxContainer>("tab/Graphics/graphics/window_res");
            _windowWidthEdit = GetNode<LineEdit>("tab/Graphics/graphics/window_res/width");
            _windowHeightEdit = GetNode<LineEdit>("tab/Graphics/graphics/window_res/height");
            _vsyncButton = GetNode<CheckButton>("tab/Graphics/graphics/vsync/vsync_button");
            _introSkip = GetNode<HBoxContainer>("tab/Graphics/graphics/intro_skip");
            _introSkipButton = GetNode<CheckButton>("tab/Graphics/graphics/intro_skip/introskip_button");
            
            // Sound settings
            _soundSettings = GetNode<CenterContainer>("tab/Sound");
            _soundSettingsButton = GetNode<ToolButton>("buttons_container/buttons_grid/sound_settings");
            _masterVolume = GetNode<HSlider>("tab/Sound/sound/master/master_slider");
            _musicVolume = GetNode<HSlider>("tab/Sound/sound/music/music_slider");
            _soundVolume = GetNode<HSlider>("tab/Sound/sound/sounds/sounds_slider");
            _muteSound = GetNode<CheckBox>("tab/Sound/sound/mute/mute_sound");
            
            // Starting conditions
            _startingConditions = GetNode<CenterContainer>("tab/Starting_Conditions");
            _startingConditionsButton = GetNode<ToolButton>("buttons_container/buttons_grid/starting_conditions");
            _singleplayerButton = GetNode<CheckBox>("tab/Starting_Conditions/starting_conditions/main/gameplay/single_player/singleplayer");
            _multiplayerButton = GetNode<CheckBox>("tab/Starting_Conditions/starting_conditions/main/gameplay/multi_player/multiplayer");
            _singleClickButton = GetNode<CheckBox>("tab/Starting_Conditions/starting_conditions/main/gameplay/single_click/singleclick_mode");
            _towerLevels = GetNode<SpinBox>("tab/Starting_Conditions/starting_conditions/main/towers_walls/tower_levels/level");
            _wallLevels = GetNode<SpinBox>("tab/Starting_Conditions/starting_conditions/main/towers_walls/wall_levels/level");
            _quarryLevels = GetNode<SpinBox>("tab/Starting_Conditions/starting_conditions/main/towers_walls/wall_levels/level");
            _brickQuantity = GetNode<SpinBox>("tab/Starting_Conditions/starting_conditions/gen_res/resources/brick_quantity/level");
            _magicLevels = GetNode<SpinBox>("tab/Starting_Conditions/starting_conditions/gen_res/generators/magic_levels/level");
            _gemQuantity = GetNode<SpinBox>("tab/Starting_Conditions/starting_conditions/gen_res/resources/gem_quantity/level");
            _dungeonLevels = GetNode<SpinBox>("tab/Starting_Conditions/starting_conditions/gen_res/generators/dungeon_levels3/level");
            _recruitQuantity = GetNode<SpinBox>("tab/Starting_Conditions/starting_conditions/gen_res/resources/recruit_quantity/level");
            
            // Play conditions
            _playConditions = GetNode<CenterContainer>("tab/Play_Conditions");
            _playConditionsButton = GetNode<ToolButton>("buttons_container/buttons_grid/play_conditions");
            _autoBricks = GetNode<SpinBox>("tab/Play_Conditions/main/autoget/bricks/level");
            _autoGems = GetNode<SpinBox>("tab/Play_Conditions/main/autoget/gems/level");
            _autoRecruits = GetNode<SpinBox>("tab/Play_Conditions/main/autoget/recruits/level");
            _cardsInHand = GetNode<SpinBox>("tab/Play_Conditions/main/cardsnum_and_ai/cards_in_hand/level");
            _ai = GetNode<OptionButton>("tab/Play_Conditions/main/cardsnum_and_ai/AI/mode");
            
            // Victory conditions
            _victoryConditions = GetNode<CenterContainer>("tab/Victory_Conditions");
            _victoryConditionsButton = GetNode<ToolButton>("buttons_container/buttons_grid/victory_conditions");
            _winTower = GetNode<SpinBox>("tab/Victory_Conditions/main/tower/level");
            _winResources = GetNode<SpinBox>("tab/Victory_Conditions/main/resource/level");
            
            // Tavern presets
            _tavernPresets = GetNode<CenterContainer>("tab/Tavern_Presets");
            _tavernPresetsButton = GetNode<ToolButton>("buttons_container/buttons_grid/tavern_presets");
            _tavernPreset = GetNode<OptionButton>("tab/Tavern_Presets/main/preset/tavern_option");
            
            // Language settings
            _languageSettings = GetNode<CenterContainer>("tab/Language_Settings");
            _languageSettingsButton = GetNode<ToolButton>("buttons_container/buttons_grid/language_settings");
            _language = GetNode<OptionButton>("tab/Language_Settings/main/language/lang_option");
            _languageErrors = GetNode<Label>("tab/Language_Settings/main/lang_errors");
            
            // Player settings
            _playerSettings = GetNode<CenterContainer>("tab/Player_Settings");
            _playerSettingsButton = GetNode<ToolButton>("buttons_container/buttons_grid/player_settings");
            _nickname = GetNode<LineEdit>("tab/Player_Settings/main/nickname/edit");
            #endregion
        }

        public override void _Ready()
        {
            // Settings looks different if you will open them from in-game menu
            if (GetParent().Name == "ingame_menu")
            {
                _startingConditionsButton.Hide();
                _playConditionsButton.Hide();
                _victoryConditionsButton.Hide();
                _tavernPresetsButton.Hide();
                _playerSettingsButton.Hide();
                _languageSettingsButton.Hide();
                _introSkip.Hide();
                _reset.Hide();
            }
            else if (GetParent().Name != "main_menu")
            {
                Hide();
            }
            
            LoadSettings();
            _windowHeightEdit.Text = OS.WindowSize.x.ToString(_invariantCulture);
            _windowHeightEdit.Text = OS.WindowSize.y.ToString(_invariantCulture);

            switch (CurrentLocale)
            {
                case Locale.en:
                    TranslationServer.SetLocale("en"); 
                    break;
                case Locale.ru:
                    TranslationServer.SetLocale("ru"); 
                    break;
                case Locale.uk:
                    TranslationServer.SetLocale("uk");
                    break;
                case Locale.pl:
                    TranslationServer.SetLocale("pl");
                    break;
                case Locale.da:
                    TranslationServer.SetLocale("da");
                    break;
                default:
                    TranslationServer.SetLocale("en");
                    break;
            }
        }

        private async void OnClosePressed()
        {
            SaveSettings();
            _anim.Play("hide");
            await ToSignal(_anim, "animation_finished");
            Hide();
        }

        private void SaveSettings()
        {
            var c = new ConfigFile();
            var err = c.Load(_configPath);
            // If file didn't exist - create new one with defaults.
            if (err != Error.Ok)
            {
                // Window settings
                c.SetValue("WINDOW", "fullscreen", Fullscreen);
                c.SetValue("WINDOW", "borderless", Borderless);
                c.SetValue("WINDOW", "width", WindowWidth);
                c.SetValue("WINDOW", "height", WindowHeight);
                c.SetValue("WINDOW", "vsync", Vsync);
                c.SetValue("WINDOW", "intro_skip", IntroSkip);
                // Audio settings
                c.SetValue("AUDIO", "master", MasterVolume);
                c.SetValue("AUDIO", "music", MusicVolume);
                c.SetValue("AUDIO", "sound", SoundVolume);
                c.SetValue("AUDIO", "mute", MuteSound);
                // Starting conditions
                c.SetValue("START", "singleplayer", Singleplayer);
                c.SetValue("START", "single_click_mode", SingleClick);
                c.SetValue("START", "tower_levels", TowerLevels);
                c.SetValue("START", "wall_levels", WallLevels);
                c.SetValue("START", "quarry_levels", QuarryLevels);
                c.SetValue("START", "brick_quantity", BrickQuantity);
                c.SetValue("START", "magic_levels", MagicLevels);
                c.SetValue("START", "gem_quantity", GemQuantity);
                c.SetValue("START", "dungeon_levels", DungeonLevels);
                c.SetValue("START", "recruit_quantity", RecruitQuantity);
                // Play conditions
                c.SetValue("PLAY", "auto_bricks", AutoBricks);
                c.SetValue("PLAY", "auto_gems", AutoGems);
                c.SetValue("PLAY", "auto_recruits", AutoRecruits);
                c.SetValue("PLAY", "cards_in_hand", CardsInHand);
                c.SetValue("PLAY", "ai", CurrentAiType);
                // Victory conditions
                c.SetValue("VICTORY", "tower_victory", TowerVictory);
                c.SetValue("VICTORY", "resource_victory", ResourceVictory);
                // Tavern presets
                c.SetValue("TAVERN", "preset", CurrentTavern);
                // Language settings
                c.SetValue("LANGUAGE", "locale", CurrentLocale);
                // Player settings
                c.SetValue("PLAYER", "nickname", Nickname);
                c.Save(_configPath);
            }
            else
            {
                // Window settings
                c.SetValue("WINDOW", "fullscreen", _fullscreenButton.Pressed);
                c.SetValue("WINDOW", "borderless", _borderlessButton.Pressed);
                c.SetValue("WINDOW", "width", int.Parse(_windowWidthEdit.Text));
                c.SetValue("WINDOW", "height", int.Parse(_windowHeightEdit.Text));
                c.SetValue("WINDOW", "vsync", _vsyncButton.Pressed);
                c.SetValue("WINDOW", "intro_skip", _introSkipButton.Pressed);
                // Audio settings
                c.SetValue("AUDIO", "master", _masterVolume.Value);
                c.SetValue("AUDIO", "music", _musicVolume.Value);
                c.SetValue("AUDIO", "sound", _soundVolume.Value);
                c.SetValue("AUDIO", "mute", _muteSound.Pressed);
                // Starting conditions
                c.SetValue("START", "singleplayer", _singleplayerButton.Pressed);
                c.SetValue("START", "single_click_mode", _singleClickButton.Pressed);
                c.SetValue("START", "tower_levels", (int)_towerLevels.Value);
                c.SetValue("START", "wall_levels", (int)_wallLevels.Value);
                c.SetValue("START", "quarry_levels", (int)_quarryLevels.Value);
                c.SetValue("START", "brick_quantity", (int)_brickQuantity.Value);
                c.SetValue("START", "magic_levels", (int)_magicLevels.Value);
                c.SetValue("START", "gem_quantity", (int)_gemQuantity.Value);
                c.SetValue("START", "dungeon_levels", (int)_dungeonLevels.Value);
                c.SetValue("START", "recruit_quantity", (int)_recruitQuantity.Value);
                // Play conditions
                c.SetValue("PLAY", "auto_bricks", (int)_autoBricks.Value);
                c.SetValue("PLAY", "auto_gems", (int)_autoGems.Value);
                c.SetValue("PLAY", "auto_recruits", (int)_autoRecruits.Value);
                c.SetValue("PLAY", "cards_in_hand", (int)_cardsInHand.Value);
                c.SetValue("PLAY", "ai", _ai.Selected);
                // Victory conditions
                c.SetValue("VICTORY", "tower_victory", (int)_winTower.Value);
                c.SetValue("VICTORY", "resource_victory", (int)_winResources.Value);
                // Tavern presets
                c.SetValue("TAVERN", "preset", _tavernPreset.Selected);
                // Language settings
                c.SetValue("LANGUAGE", "locale", _language.Selected);
                // Player settings
                c.SetValue("PLAYER", "nickname", _nickname.Text);
                c.Save(_configPath);
            }
        }

        private void LoadSettings()
        {
            var c = new ConfigFile();
            var err = c.Load(_configPath);
            // Apply current settings from .ini file.
            if (err != Error.Ok) return;
            // Window settings
            HasKeyElseSet(c,"WINDOW", "fullscreen", _fullscreenButton.Pressed);
            Fullscreen = (bool)c.GetValue("WINDOW", "fullscreen");
            _fullscreenButton.Pressed = Fullscreen;
            HasKeyElseSet(c,"WINDOW", "borderless", _borderlessButton.Pressed);
            Borderless = (bool)c.GetValue("WINDOW", "borderless");
            _borderlessButton.Pressed = Borderless;
            HasKeyElseSet(c,"WINDOW", "width", int.Parse(_windowWidthEdit.Text));
            WindowWidth = (int)c.GetValue("WINDOW", "width");
            _windowWidthEdit.Text = WindowWidth.ToString();
            HasKeyElseSet(c,"WINDOW", "height", int.Parse(_windowHeightEdit.Text));
            WindowHeight = (int)c.GetValue("WINDOW", "height");
            _windowHeightEdit.Text = WindowHeight.ToString();
            HasKeyElseSet(c,"WINDOW", "vsync", _vsyncButton.Pressed);
            Vsync = (bool)c.GetValue("WINDOW", "vsync");
            _vsyncButton.Pressed = Vsync;
            HasKeyElseSet(c,"WINDOW", "intro_skip", _introSkipButton.Pressed);
            IntroSkip = (bool)c.GetValue("WINDOW", "intro_skip");
            _introSkipButton.Pressed = IntroSkip;
            // Audio settings
            HasKeyElseSet(c,"AUDIO", "master", _masterVolume.Value);
            MasterVolume = Convert.ToDouble(c.GetValue("AUDIO", "master"));
            _masterVolume.Value = MasterVolume;
            HasKeyElseSet(c,"AUDIO", "music", _musicVolume.Value);
            MusicVolume = Convert.ToDouble(c.GetValue("AUDIO", "music"));
            _musicVolume.Value = MusicVolume;
            HasKeyElseSet(c,"AUDIO", "sound", _soundVolume.Value);
            SoundVolume = Convert.ToDouble(c.GetValue("AUDIO", "sound"));
            _soundVolume.Value = SoundVolume;
            HasKeyElseSet(c,"AUDIO", "mute", _muteSound.Pressed);
            MuteSound = (bool)c.GetValue("AUDIO", "mute");
            _muteSound.Pressed = MuteSound;
            // Starting conditions
            HasKeyElseSet(c,"START", "singleplayer", _singleplayerButton.Pressed);
            Singleplayer = (bool)c.GetValue("START", "singleplayer");
            _singleplayerButton.Pressed = Singleplayer;
            HasKeyElseSet(c,"START", "single_click_mode", _singleClickButton.Pressed);
            SingleClick = (bool)c.GetValue("START", "single_click_mode");
            _singleClickButton.Pressed = SingleClick;
            HasKeyElseSet(c,"START", "tower_levels", int.Parse(_towerLevels.Value.ToString(_invariantCulture)));
            TowerLevels = (int)c.GetValue("START", "tower_levels");
            _towerLevels.Value = TowerLevels;
            HasKeyElseSet(c,"START", "wall_levels", int.Parse(_wallLevels.Value.ToString(_invariantCulture)));
            WallLevels = (int)c.GetValue("START", "wall_levels");
            _wallLevels.Value = WallLevels;
            HasKeyElseSet(c,"START", "quarry_levels", int.Parse(_quarryLevels.Value.ToString(_invariantCulture)));
            QuarryLevels = (int)c.GetValue("START", "quarry_levels");
            _quarryLevels.Value = QuarryLevels;
            HasKeyElseSet(c,"START", "brick_quantity", int.Parse(_brickQuantity.Value.ToString(_invariantCulture)));
            BrickQuantity = (int)c.GetValue("START", "brick_quantity");
            _brickQuantity.Value = BrickQuantity;
            HasKeyElseSet(c,"START", "magic_levels", int.Parse(_magicLevels.Value.ToString(_invariantCulture)));
            MagicLevels = (int)c.GetValue("START", "magic_levels");
            _magicLevels.Value = MagicLevels;
            HasKeyElseSet(c,"START", "gem_quantity", int.Parse(_gemQuantity.Value.ToString(_invariantCulture)));
            GemQuantity = (int)c.GetValue("START", "gem_quantity");
            _gemQuantity.Value = GemQuantity;
            HasKeyElseSet(c,"START", "dungeon_levels", int.Parse(_dungeonLevels.Value.ToString(_invariantCulture)));
            DungeonLevels = (int)c.GetValue("START", "dungeon_levels");
            _dungeonLevels.Value = DungeonLevels;
            HasKeyElseSet(c,"START", "recruit_quantity", int.Parse(_recruitQuantity.Value.ToString(_invariantCulture)));
            RecruitQuantity = (int)c.GetValue("START", "recruit_quantity");
            _recruitQuantity.Value = RecruitQuantity;
            // Play conditions
            HasKeyElseSet(c,"PLAY", "auto_bricks", int.Parse(_autoBricks.Value.ToString(_invariantCulture)));
            AutoBricks = (int)c.GetValue("PLAY", "auto_bricks");
            _autoBricks.Value = AutoBricks;
            HasKeyElseSet(c,"PLAY", "auto_gems", int.Parse(_autoGems.Value.ToString(_invariantCulture)));
            AutoGems = (int)c.GetValue("PLAY", "auto_gems");
            _autoGems.Value = AutoGems;
            HasKeyElseSet(c,"PLAY", "auto_recruits", int.Parse(_autoRecruits.Value.ToString(_invariantCulture)));
            AutoRecruits = (int)c.GetValue("PLAY", "auto_recruits");
            _autoRecruits.Value = AutoRecruits;
            HasKeyElseSet(c,"PLAY", "cards_in_hand", int.Parse(_cardsInHand.Value.ToString(_invariantCulture)));
            CardsInHand = (int)c.GetValue("PLAY", "cards_in_hand");
            _cardsInHand.Value = CardsInHand;
            HasKeyElseSet(c,"PLAY", "ai", _ai.Selected);
            CurrentAiType = (AiType)c.GetValue("PLAY", "ai");
            _ai.Selected = (int)CurrentAiType;
            // Victory conditions
            HasKeyElseSet(c,"VICTORY", "tower_victory", int.Parse(_winTower.Value.ToString(_invariantCulture)));
            TowerVictory = (int)c.GetValue("VICTORY", "tower_victory");
            _winTower.Value = TowerVictory;
            HasKeyElseSet(c,"VICTORY", "resource_victory", int.Parse(_winResources.Value.ToString(_invariantCulture)));
            ResourceVictory = (int)c.GetValue("VICTORY", "resource_victory");
            _winResources.Value = ResourceVictory;
            // Tavern presets
            HasKeyElseSet(c,"TAVERN", "preset", _tavernPreset.Selected);
            CurrentTavern = (Tavern)c.GetValue("TAVERN", "preset");
            _tavernPreset.Selected = (int)CurrentTavern;
            // Language settings
            HasKeyElseSet(c,"LANGUAGE", "locale", _language.Selected);
            CurrentLocale = (Locale)c.GetValue("LANGUAGE", "locale");
            _language.Selected = (int)CurrentLocale;
            // Player settings
            HasKeyElseSet(c,"PLAYER", "nickname", _nickname.Text);
            Nickname = (string)c.GetValue("PLAYER", "nickname");
            _nickname.Text = Nickname;
        }

        private static void HasKeyElseSet(ConfigFile c, string section, string key, object setTo)
        {
            if (!c.HasSectionKey(section, key))
                c.SetValue(section, key, setTo);
        }

        private void OnWindowSettingsPressed() => _tab.CurrentTab = 0;
        private void OnSoundSettingsPressed() => _tab.CurrentTab = 1;
        private void OnStartingConditionsPressed() => _tab.CurrentTab = 2;
        private void OnPlayConditionsPressed() => _tab.CurrentTab = 3;
        private void OnVictoryConditionsPressed() => _tab.CurrentTab = 4;
        private void OnTavernPresetsPressed() => _tab.CurrentTab = 5;
        private void OnLanguageSettingsPressed() => _tab.CurrentTab = 6;
        private void OnPlayerSettingsPressed() => _tab.CurrentTab = 7;

        private void OnFullscreenButtonToggled(bool toggle)
        {
            OS.WindowFullscreen = toggle;
            if (toggle)
                _windowResolution.Hide();
            else
                _windowResolution.Show();
        }

        private void OnBorderlessButtonToggled(bool toggle)
        {
            OS.WindowBorderless = toggle;
            if (toggle && _fullscreenButton.Pressed)
                _fullscreen.Hide();
            else
                _fullscreen.Show();
        }

        private void OnWindowResolutionApplyPressed()
        {
            OS.WindowSize = new Vector2(float.Parse(_windowWidthEdit.Text), 
                float.Parse(_windowHeightEdit.Text));
            OS.WindowPosition = (OS.GetScreenSize() * 0.5f - OS.WindowSize * 0.5f);
        }

        private void OnVsyncButtonToggled(bool toggle) => OS.VsyncEnabled = toggle;
        private void OnIntroSkipButtonToggled(bool toggle) => IntroSkip = toggle;

        private void OnMasterSliderValueChanged(float value) =>
            AudioServer.SetBusVolumeDb(0, GD.Linear2Db((float)_masterVolume.Value));
        private void OnMusicSliderValueChanged(float value) => 
            AudioServer.SetBusVolumeDb(1, GD.Linear2Db((float)_musicVolume.Value));
        private void OnSoundsSliderValueChanged(float value) => 
            AudioServer.SetBusVolumeDb(2, GD.Linear2Db((float)_soundVolume.Value));
        
        private void OnMuteSoundToggled(bool toggle)
        {
            AudioServer.SetBusMute(0, toggle);
            AudioServer.SetBusMute(1, toggle);
            AudioServer.SetBusMute(2, toggle);
        }
        
        private void OnTowerLevelsValueChanged(float value) => TowerLevels = (int)value;
        private void OnWallLevelsValueChanged(float value) => WallLevels = (int)value;
        private void OnQuarryLevelsValueChanged(float value) => QuarryLevels = (int)value;
        private void OnMagicLevelsValueChanged(float value) => MagicLevels = (int)value;
        private void OnDungeonLevelsValueChanged(float value) => DungeonLevels = (int)value;
        private void OnBrickQuantityValueChanged(float value) => BrickQuantity = (int)value;
        private void OnGemQuantityValueChanged(float value) => GemQuantity = (int)value;
        private void OnRecruitQuantityValueChanged(float value) => RecruitQuantity = (int)value;
        
        private void OnAutoGetBricksValueChanged(float value) => AutoBricks = (int)value;
        private void OnAutoGetGemsValueChanged(float value) => AutoGems = (int)value;
        private void OnAutoGetRecruitsValueChanged(float value) => AutoRecruits = (int)value;
        private void OnCardsInHandValueChanged(float value) => CardsInHand = (int)value;
        private void OnAiModeChanged(int index) => CurrentAiType = (AiType)index;

        private void OnTowerVictoryValueChanged(float value) => TowerVictory = (int)value;
        private void OnResourceVictoryValueChanged(float value) => ResourceVictory = (int)value;

        private void OnTavernPresetSelected(int index) => CurrentTavern = (Tavern)index;

        private void OnLanguageSelected(int index)
        {
            switch ((Locale)index)
            {
                case Locale.en:
                    TranslationServer.SetLocale("en");
                    break;
                case Locale.ru:
                    TranslationServer.SetLocale("ru");
                    break;
                case Locale.uk:
                    TranslationServer.SetLocale("uk");
                    break;
                case Locale.pl:
                    TranslationServer.SetLocale("pl");
                    break;
                case Locale.da:
                    TranslationServer.SetLocale("da");
                    break;
                default:
                    TranslationServer.SetLocale("en");
                    break;
            }
        }

        private void OnNicknameTextChanged(string newText) => Nickname = newText;
    }
}
