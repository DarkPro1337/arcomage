using System.Collections.Generic;
using Godot;
using Newtonsoft.Json.Linq;

namespace Arcomage.Scripts
{
    public enum CardsLayout
    {
        Brick,
        Gem,
        Recruits
    }
    public enum CardsUse
    {
        Attack,
        Defence,
        Resource
    }
    public class Cards
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public CardsLayout Type { get; set; }
        public int Cost { get; set; }
        public string Pic { get; set; }
        public CardsUse Use { get; set; }
        public bool NotDiscardable { get; set; }

        public void Load(JObject obj)
        {
            Id = obj.Property("id").Value.ToString();
            Name = obj.Property("name").Value.ToString();
            Description = obj.Property("description").Value.ToString();
            Type = (CardsLayout)int.Parse(obj.Property("type").Value.ToString());
            Cost = int.Parse(obj.Property("cost").Value.ToString());
            Use = (CardsUse)int.Parse(obj.Property("use").Value.ToString());
            NotDiscardable = obj.Property("not_discardable").Value.ToString().Equals("true");
            Pic = obj.Property("pic").Value.ToString();
        }
    }
    
    public class Сard : Control
    {
        private Panel _selector;
        private TextureRect _cardBack;
        private Label _name;
        private TextureRect _art;
        private Label _description;
        private Label _cost;
        private TextureRect _layout;
        private Label _discarded;

        private readonly RandomNumberGenerator _rng = new RandomNumberGenerator();
        public List<Cards> CardsList = new List<Cards>();

        public int CardIdx = -1;
        public string CardId;
        public string CardName;
        public string CardDescription;
        public int CardCost;
        public CardsLayout CardLayout;
        public string CardArt;
        public CardsUse CardUse;
        public bool CardNotDiscardable;

        public bool Preview = false;
        public bool Discardable = true;
        public bool Usable = true;
        public bool BotUsable = true;
        public bool Used = false;
        public bool UiCardUppercaseText = false;

        public override void _Ready()
        {
            _selector = GetNode<Panel>("selector");
            _cardBack = GetNode<TextureRect>("card_back");
            _name = GetNode<Label>("name");
            _art = GetNode<TextureRect>("art");
            _description = GetNode<Label>("description");
            _cost = GetNode<Label>("cost");
            _layout = GetNode<TextureRect>("layout");
            _discarded = GetNode<Label>("discarded");
            
            _rng.Randomize();
            
            LoadCards(JObject.Parse(System.IO.File.ReadAllText("Db/base.cdb")));
            var selectedCard = CardIdx != -1 && CardIdx >= 0 && CardIdx <= CardsList.Count
                ? CardsList[CardIdx]
                : CardsList[_rng.RandiRange(0, CardsList.Count)];
            
            CardId = selectedCard.Id;
            CardName = selectedCard.Id.ToUpper();
            CardArt = selectedCard.Pic.Replace("../", "res://");
            CardDescription = $"{selectedCard.Id.ToUpper()}_DESC";
            CardCost = selectedCard.Cost;
            CardLayout = selectedCard.Type;
            CardUse = selectedCard.Use;
            CardNotDiscardable = selectedCard.NotDiscardable;

            _name.Text = CardName;
            _art.Texture = GD.Load<Texture>(CardArt);
            _description.Text = CardDescription;
            _cost.Text = CardCost.ToString();
            _name.Uppercase = UiCardUppercaseText;
            Name = CardId;

            if (CardNotDiscardable) Discardable = false;

            switch (CardLayout)
            {
                case CardsLayout.Brick:
                    _layout.Texture = GD.Load<Texture>("res://Sprites/red_card_layout_alt.png");
                    break;
                case CardsLayout.Gem:
                    _layout.Texture = GD.Load<Texture>("res://Sprites/blue_card_layout_alt.png");
                    break;
                case CardsLayout.Recruits:
                    _layout.Texture = GD.Load<Texture>("res://Sprites/green_card_layout_alt.png");
                    break;
                default:
                    Global.Log("CardLayout out of range");
                    _layout.Texture = GD.Load<Texture>("res://Sprites/null_card_layout_alt.png");
                    break;
            }
        }

        public override void _PhysicsProcess(float delta)
        {
            base._PhysicsProcess(delta);
        }

        private void LoadCards(JObject file)
        {
            var sheetsElem = file.Property("sheets").Value as JArray;
            foreach (var s in sheetsElem)
            {
                var sheet = s as JObject;
                var sheetName = sheet.Property("name").Value.ToString();
                if (!sheetName.Equals("cards")) continue;
                var linesElem = sheet.Property("lines").Value as JArray;
                foreach (var l in linesElem)
                {
                    var value = new Cards();
                    value.Load(l as JObject);
                    CardsList.Add(value);
                }
            }
        }
    }
}
