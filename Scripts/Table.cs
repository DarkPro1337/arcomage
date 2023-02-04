using Godot;
using System;
using System.Collections.Generic;

namespace Arcomage.Scripts
{
    public class Player
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public bool Host { get; set; }
        public bool Ai { get; set; }
    }
    
    public class Table : Control
    {
        private readonly RandomNumberGenerator _rng = new RandomNumberGenerator();

        #region Controls

        // Misc objects
        private Control _particles;
        private TextureRect _graveyardCardBack;
        private GridContainer _graveyard;
        private Label _drawCardLabel;
        private Control _endGameScreen;
        private Timer _timeElapsed;

        // Table objects
        private HBoxContainer _redDeck;
        private HBoxContainer _blueDeck;
        private Label _redName;
        private Label _blueName;
        private ColorRect _deckLocker;

        // Red Player Stats Panels objects
        private Panel _redBricksPanel;
        private Label _redBricksPerTurn;
        private Label _redBricksTotal;
        private Panel _redGemsPanel;
        private Label _redGemsPerTurn;
        private Label _redGemsTotal;
        private Panel _redRecruitsPanel;
        private Label _redRecruitsPerTurn;
        private Label _redRecruitsTotal;

        // Blue Player Stats Panels objects
        private Panel _blueBricksPanel;
        private Label _blueBricksPerTurn;
        private Label _blueBricksTotal;
        private Panel _blueGemsPanel;
        private Label _blueGemsPerTurn;
        private Label _blueGemsTotal;
        private Panel _blueRecruitsPanel;
        private Label _blueRecruitsPerTurn;
        private Label _blueRecruitsTotal;

        // Red Player Stats Alternative Panels objects
        private Panel _redBricksAltPanel;
        private Label _redBricksAltPerTurn;
        private Label _redBricksAltTotal;
        private Panel _redGemsAltPanel;
        private Label _redGemsAltPerTurn;
        private Label _redGemsAltTotal;
        private Panel _redRecruitsAltPanel;
        private Label _redRecruitsAltPerTurn;
        private Label _redRecruitsAltTotal;

        // Blue Player Stats Alternative Panels objects
        private Panel _blueBricksAltPanel;
        private Label _blueBricksAltPerTurn;
        private Label _blueBricksAltTotal;
        private Panel _blueGemsAltPanel;
        private Label _blueGemsAltPerTurn;
        private Label _blueGemsAltTotal;
        private Panel _blueRecruitsAltPanel;
        private Label _blueRecruitsAltPerTurn;
        private Label _blueRecruitsAltTotal;

        // UI objects
        private Control _ingameMenu;

        #endregion

        public string RedName = Config.Nickname;
        public string BlueName;

        public List<Player> Players = new List<Player>();
        private int _turn;
        public bool AiReady = true;
        public bool RedPlayAgain = false;
        public bool BluePlayAgain = false;
        public bool RedDiscarding = false;
        public bool BlueDiscarding = false;
        public bool RedDrawCard = false;
        public bool BlueDrawCard = false;

        // Default towers and wall hp setters
        public int RedTowerHp = Config.TowerLevels;
        public int RedWallHp = Config.WallLevels;

        public int BlueTowerHp = Config.TowerLevels;
        public int BlueWallHp = Config.WallLevels;

        // Default resources setters
        public int RedQuarries = Config.QuarryLevels;
        public int RedBricks = Config.BrickQuantity;
        public int RedMagic = Config.MagicLevels;
        public int RedGems = Config.GemQuantity;
        public int RedDungeons = Config.DungeonLevels;
        public int RedRecruits = Config.RecruitQuantity;

        public int BlueQuarries = Config.QuarryLevels;
        public int BlueBricks = Config.BrickQuantity;
        public int BlueMagic = Config.MagicLevels;
        public int BlueGems = Config.GemQuantity;
        public int BlueDungeons = Config.DungeonLevels;
        public int BlueRecruits = Config.RecruitQuantity;

        public int Elapsed = 0;
        public string ElapsedString = "00:00";

        [Signal]
        private delegate void GraveyardAnimationEnded();

        [Signal]
        private delegate void DeckAnimationEnded();

        public override void _EnterTree()
        {
            base._EnterTree();
            #region OnReady vars

            // Misc objects
            _particles = GetNode<Control>("Particles");
            _graveyard = GetNode<GridContainer>("Graveyard");
            _graveyardCardBack = GetNode<TextureRect>("Graveyard/CardBack");
            _drawCardLabel = GetNode<Label>("DrawCardLabel");
            //_endGameScreen = GetNode<Control>("EndGame"); // TODO: Rewrite into C#
            _timeElapsed = GetNode<Timer>("TimeElapsed");

            // Table objects
            _redDeck = GetNode<HBoxContainer>("RedDeck");
            _blueDeck = GetNode<HBoxContainer>("BlueDeck");
            _redName = GetNode<Label>("RedPanel/Name");
            _blueName = GetNode<Label>("BluePanel/Name");
            _deckLocker = GetNode<ColorRect>("DeckLocker");

            // Red Player Stats Panels objects
            _redBricksPanel = GetNode<Panel>("RedBricksPanel");
            _redBricksPerTurn = GetNode<Label>("RedBricksPanel/PerTurn");
            _redBricksTotal = GetNode<Label>("RedBricksPanel/Total");
            _redGemsPanel = GetNode<Panel>("RedGemsPanel");
            _redGemsPerTurn = GetNode<Label>("RedGemsPanel/PerTurn");
            _redGemsTotal = GetNode<Label>("RedGemsPanel/Total");
            _redRecruitsPanel = GetNode<Panel>("RedRecruitsPanel");
            _redRecruitsPerTurn = GetNode<Label>("RedRecruitsPanel/PerTurn");
            _redRecruitsTotal = GetNode<Label>("RedRecruitsPanel/Total");

            // Blue Player Stats Panels objects
            _blueBricksPanel = GetNode<Panel>("BlueBricksPanel");
            _blueBricksPerTurn = GetNode<Label>("BlueBricksPanel/PerTurn");
            _blueBricksTotal = GetNode<Label>("BlueBricksPanel/Total");
            _blueGemsPanel = GetNode<Panel>("BlueGemsPanel");
            _blueGemsPerTurn = GetNode<Label>("BlueGemsPanel/PerTurn");
            _blueGemsTotal = GetNode<Label>("BlueGemsPanel/Total");
            _blueRecruitsPanel = GetNode<Panel>("BlueRecruitsPanel");
            _blueRecruitsPerTurn = GetNode<Label>("BlueRecruitsPanel/PerTurn");
            _blueRecruitsTotal = GetNode<Label>("BlueRecruitsPanel/Total");

            // Red Player Stats Alternative Panels objects
            _redBricksAltPanel = GetNode<Panel>("RedBricksPanelAlt");
            _redBricksAltPerTurn = GetNode<Label>("RedBricksPanelAlt/PerTurn");
            _redBricksAltTotal = GetNode<Label>("RedBricksPanelAlt/Total");
            _redGemsAltPanel = GetNode<Panel>("RedGemsPanelAlt");
            _redGemsAltPerTurn = GetNode<Label>("RedGemsPanelAlt/PerTurn");
            _redGemsAltTotal = GetNode<Label>("RedGemsPanelAlt/Total");
            _redRecruitsAltPanel = GetNode<Panel>("RedRecruitsPanelAlt");
            _redRecruitsAltPerTurn = GetNode<Label>("RedRecruitsPanelAlt/PerTurn");
            _redRecruitsAltTotal = GetNode<Label>("RedRecruitsPanelAlt/Total");

            // Blue Player Stats Alternative Panels objects
            _blueBricksAltPanel = GetNode<Panel>("BlueBricksPanelAlt");
            _blueBricksAltPerTurn = GetNode<Label>("BlueBricksPanelAlt/PerTurn");
            _blueBricksAltTotal = GetNode<Label>("BlueBricksPanelAlt/Total");
            _blueGemsAltPanel = GetNode<Panel>("BlueGemsPanelAlt");
            _blueGemsAltPerTurn = GetNode<Label>("BlueGemsPanelAlt/PerTurn");
            _blueGemsAltTotal = GetNode<Label>("BlueGemsPanelAlt/Total");
            _blueRecruitsAltPanel = GetNode<Panel>("BlueRecruitsPanelAlt");
            _blueRecruitsAltPerTurn = GetNode<Label>("BlueRecruitsPanelAlt/PerTurn");
            _blueRecruitsAltTotal = GetNode<Label>("BlueRecruitsPanelAlt/Total");

            // UI objects
            //_ingameMenu = GetNode<Control>("IngameMenu"); // TODO: Rewrite into C#

            #endregion
        }

        public override void _Input(InputEvent @event)
        {
            base._Input(@event);
            if (!Input.IsActionJustPressed("ui_cancel")) return;
            _ingameMenu.Show();
            GetTree().Paused = true;
        }

        public override void _Ready()
        {
            Global.Table = this;
            _rng.Randomize();
            _turn = _rng.RandiRange(0, Players.Count);
            //AddResources(_turn); // TODO: add method
            //LocaleStatPanels(); // TODO: add method
            _redName.Text = RedName;
            
            if (Players.Count == 2)
                _blueName.Text = Players[1].Name;

            _blueName.Text = "UNKNOWN";
        }
    }
}