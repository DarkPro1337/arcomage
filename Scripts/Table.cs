using Godot;
using System;
using System.Collections.Generic;

namespace Arcomage.Scripts
{
    public partial class Player
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public bool Host { get; set; }
        public bool Ai { get; set; }
    }
    
    public partial class Table : Control
    {
        private readonly RandomNumberGenerator _rng = new();

        #region Controls

        private Control Particles => GetNode<Control>("Particles");
        private TextureRect GraveyardCardBack => GetNode<TextureRect>("Graveyard/CardBack");
        private GridContainer Graveyard => GetNode<GridContainer>("Graveyard");
        private Label DrawCardLabel => GetNode<Label>("DrawCardLabel");
        private Control EndGameScreen => GetNode<Control>("EndGame");
        private Timer TimeElapsed => GetNode<Timer>("TimeElapsed");

        private HBoxContainer RedDeck => GetNode<HBoxContainer>("RedDeck");
        private HBoxContainer BlueDeck => GetNode<HBoxContainer>("BlueDeck");
        private Label RedNamePanel => GetNode<Label>("RedPanel/Name");
        private Label BlueNamePanel => GetNode<Label>("BluePanel/Name");
        private ColorRect DeckLocker => GetNode<ColorRect>("DeckLocker");

        private Panel RedBricksPanel => GetNode<Panel>("RedBricksPanel");
        private Label RedBricksPerTurn => GetNode<Label>("RedBricksPanel/PerTurn");
        private Label RedBricksTotal => GetNode<Label>("RedBricksPanel/Total");
        private Panel RedGemsPanel => GetNode<Panel>("RedGemsPanel");
        private Label RedGemsPerTurn => GetNode<Label>("RedGemsPanel/PerTurn");
        private Label RedGemsTotal => GetNode<Label>("RedGemsPanel/Total");
        private Panel RedRecruitsPanel => GetNode<Panel>("RedRecruitsPanel");
        private Label RedRecruitsPerTurn => GetNode<Label>("RedRecruitsPanel/PerTurn");
        private Label RedRecruitsTotal => GetNode<Label>("RedRecruitsPanel/Total");

        private Panel BlueBricksPanel => GetNode<Panel>("BlueBricksPanel");
        private Label BlueBricksPerTurn => GetNode<Label>("BlueBricksPanel/PerTurn");
        private Label BlueBricksTotal => GetNode<Label>("BlueBricksPanel/Total");
        private Panel BlueGemsPanel => GetNode<Panel>("BlueGemsPanel");
        private Label BlueGemsPerTurn => GetNode<Label>("BlueGemsPanel/PerTurn");
        private Label BlueGemsTotal => GetNode<Label>("BlueGemsPanel/Total");
        private Panel BlueRecruitsPanel => GetNode<Panel>("BlueRecruitsPanel");
        private Label BlueRecruitsPerTurn => GetNode<Label>("BlueRecruitsPanel/PerTurn");
        private Label BlueRecruitsTotal => GetNode<Label>("BlueRecruitsPanel/Total");

        private Panel RedBricksAltPanel => GetNode<Panel>("RedBricksPanelAlt");
        private Label RedBricksAltPerTurn => GetNode<Label>("RedBricksPanelAlt/PerTurn");
        private Label RedBricksAltTotal => GetNode<Label>("RedBricksPanelAlt/Total");
        private Panel RedGemsAltPanel => GetNode<Panel>("RedGemsPanelAlt");
        private Label RedGemsAltPerTurn => GetNode<Label>("RedGemsPanelAlt/PerTurn");
        private Label RedGemsAltTotal => GetNode<Label>("RedGemsPanelAlt/Total");
        private Panel RedRecruitsAltPanel => GetNode<Panel>("RedRecruitsPanelAlt");
        private Label RedRecruitsAltPerTurn => GetNode<Label>("RedRecruitsPanelAlt/PerTurn");
        private Label RedRecruitsAltTotal => GetNode<Label>("RedRecruitsPanelAlt/Total");

        private Panel BlueBricksAltPanel => GetNode<Panel>("BlueBricksPanelAlt");
        private Label BlueBricksAltPerTurn => GetNode<Label>("BlueBricksPanelAlt/PerTurn");
        private Label BlueBricksAltTotal => GetNode<Label>("BlueBricksPanelAlt/Total");
        private Panel BlueGemsAltPanel => GetNode<Panel>("BlueGemsPanelAlt");
        private Label BlueGemsAltPerTurn => GetNode<Label>("BlueGemsPanelAlt/PerTurn");
        private Label BlueGemsAltTotal => GetNode<Label>("BlueGemsPanelAlt/Total");
        private Panel BlueRecruitsAltPanel => GetNode<Panel>("BlueRecruitsPanelAlt");
        private Label BlueRecruitsAltPerTurn => GetNode<Label>("BlueRecruitsPanelAlt/PerTurn");
        private Label BlueRecruitsAltTotal => GetNode<Label>("BlueRecruitsPanelAlt/Total");

        private Control InGameMenu => GetNode<Control>("InGameMenu");

        #endregion

        public string RedName = Config.Settings.Nickname;
        public string BlueName;

        public List<Player> Players = new();
        private int _turn;
        public bool AiReady = true;
        public bool RedPlayAgain = false;
        public bool BluePlayAgain = false;
        public bool RedDiscarding = false;
        public bool BlueDiscarding = false;
        public bool RedDrawCard = false;
        public bool BlueDrawCard = false;

        // Default towers and wall hp setters
        public int RedTowerHp = Config.Settings.TowerLevels;
        public int RedWallHp = Config.Settings.WallLevels;

        public int BlueTowerHp = Config.Settings.TowerLevels;
        public int BlueWallHp = Config.Settings.WallLevels;

        // Default resources setters
        public int RedQuarries = Config.Settings.QuarryLevels;
        public int RedBricks = Config.Settings.BrickQuantity;
        public int RedMagic = Config.Settings.MagicLevels;
        public int RedGems = Config.Settings.GemQuantity;
        public int RedDungeons = Config.Settings.DungeonLevels;
        public int RedRecruits = Config.Settings.RecruitQuantity;

        public int BlueQuarries = Config.Settings.QuarryLevels;
        public int BlueBricks = Config.Settings.BrickQuantity;
        public int BlueMagic = Config.Settings.MagicLevels;
        public int BlueGems = Config.Settings.GemQuantity;
        public int BlueDungeons = Config.Settings.DungeonLevels;
        public int BlueRecruits = Config.Settings.RecruitQuantity;

        public int Elapsed = 0;
        public string ElapsedString = "00:00";

        [Signal]
        public delegate void GraveyardAnimationEndedEventHandler();

        [Signal]
        public delegate void DeckAnimationEndedEventHandler();

        public override void _Input(InputEvent @event)
        {
            base._Input(@event);
            if (!Input.IsActionJustPressed("ui_cancel")) return;
            InGameMenu.Show();
            GetTree().Paused = true;
        }

        public override void _Ready()
        {
            Global.Log("Table loaded");
            if (!Multiplayer.IsServer()) return;
            
            Multiplayer.PeerConnected += id => Global.Log("Multiplayer :: Peer connected, ID = " + id);
            Multiplayer.PeerDisconnected += id => Global.Log("Multiplayer :: Peer disconnected, ID = " + id);
            
            //SpawnConnectedPlayers(); // TODO: add method
            //SpawnLocalPlayer(); // TODO: add method
            
            Global.Table = this;
            _rng.Randomize();
            _turn = _rng.RandiRange(0, Players.Count);
            //AddResources(_turn); // TODO: add method
            //LocaleStatPanels(); // TODO: add method
            RedNamePanel.Text = RedName;
            
            if (Players.Count == 2)
                BlueNamePanel.Text = Players[1].Name;

            BlueNamePanel.Text = "UNKNOWN"; // Replace with connected player name or AI name if it's single player
        }
    }
}