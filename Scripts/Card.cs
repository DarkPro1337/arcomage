using System.Collections.Generic;
using System.Text.Json;
using Godot;

namespace Arcomage.Scripts;

public enum CardsLayout
{
    Brick,
    Gem,
    Recruits,
    None
}

public enum CardsUse
{
    Attack,
    Defence,
    Resource
}

public enum CardFeature
{
    PlayAgain,
    DrawDiscard,
    NotDiscardable,
}

public class Cards
{
    public string Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public CardsLayout Type { get; set; }
    public int Cost { get; set; }
    public string Pic { get; set; }
    public List<CardsUse> Uses { get; set; }
    public List<CardFeature> Features { get; set; }

    public void Load(JsonElement obj)
    {
        Id = obj.GetProperty("id").GetString();
        Name = obj.GetProperty("name").GetString();
        Description = obj.GetProperty("description").GetString();
        Type = obj.GetProperty("type").GetString() switch
        {
            "brick" => CardsLayout.Brick,
            "gem" => CardsLayout.Gem,
            "recruits" => CardsLayout.Recruits,
            _ => CardsLayout.None
        };
        Cost = obj.GetProperty("cost").GetInt32();
        Pic = obj.GetProperty("pic").GetString();
        
        // TODO: Uses should be automated based on Actions
        Uses = null;
        
        if (obj.TryGetProperty("features", out var features))
        {
            Features = new List<CardFeature>();
            foreach (var feature in features.EnumerateArray())
            {
                Features.Add(feature.GetString() switch
                {
                    "playAgain" => CardFeature.PlayAgain,
                    "drawDiscard" => CardFeature.DrawDiscard,
                    "notDiscardable" => CardFeature.NotDiscardable
                });
            }
        }
    }
}
    
public partial class Card : Control
{
    private Panel Selector => GetNode<Panel>("Selector");
    private TextureRect CardBack => GetNode<TextureRect>("CardBack");
    private Label NameLabel => GetNode<Label>("Name");
    private TextureRect Art => GetNode<TextureRect>("Art");
    private Label Description =>  GetNode<Label>("Description");
    private Label Cost => GetNode<Label>("Cost");
    private TextureRect Layout => GetNode<TextureRect>("Layout");
    private Label Discarded => GetNode<Label>("Discarded");

    private readonly RandomNumberGenerator _rng = new RandomNumberGenerator();
    public readonly List<Cards> CardsList = new();

    public int CardIdx = -1;
    public string CardId;
    public string CardName;
    public string CardDescription;
    public int CardCost;
    public CardsLayout CardLayout;
    public string CardArt;
    public List<CardsUse> CardUses;
    public List<CardFeature> CardFeatures;

    public bool Preview = false;
    public bool Discardable = true;
    public bool Usable = true;
    public bool BotUsable = true;
    public bool Used = false;
    public bool UiCardUppercaseText = false;

    public override void _Ready()
    {
        GuiInput += OnGuiInput;
        MouseEntered += OnMouseEntered;
        MouseExited += OnMouseExited;
        
        _rng.Randomize();

        var jsonFile = FileAccess.Open("res://Db/base.json", FileAccess.ModeFlags.Read);
        var json = jsonFile.GetAsText();
        jsonFile.Close();
        
        using (var document = JsonDocument.Parse(json)) 
            LoadCards(document);
        
        var selectedCard = CardIdx != -1 && CardIdx >= 0 && CardIdx <= CardsList.Count
            ? CardsList[CardIdx]
            : CardsList[_rng.RandiRange(0, CardsList.Count)];
            
        CardId = selectedCard.Id;
        CardName = selectedCard.Id.ToUpper();
        CardArt = selectedCard.Pic.Replace("../", "res://");
        CardDescription = $"{selectedCard.Id.ToUpper()}_DESC";
        CardCost = selectedCard.Cost;
        CardLayout = selectedCard.Type;
        CardUses = selectedCard.Uses;
        CardFeatures = selectedCard.Features;

        NameLabel.Text = CardName;
        Art.Texture = GD.Load<Texture2D>(CardArt);
        Description.Text = CardDescription;
        Cost.Text = CardCost.ToString();
        NameLabel.Uppercase = UiCardUppercaseText;
        Name = CardId;

        if (CardFeatures.Contains(CardFeature.NotDiscardable)) Discardable = false;

        switch (CardLayout)
        {
            case CardsLayout.Brick:
                Layout.Texture = GD.Load<Texture2D>("res://Sprites/red_card_layout_alt.png");
                break;
            case CardsLayout.Gem:
                Layout.Texture = GD.Load<Texture2D>("res://Sprites/blue_card_layout_alt.png");
                break;
            case CardsLayout.Recruits:
                Layout.Texture = GD.Load<Texture2D>("res://Sprites/green_card_layout_alt.png");
                break;
            default:
                Global.Log("CardLayout out of range");
                Layout.Texture = GD.Load<Texture2D>("res://Sprites/null_card_layout_alt.png");
                break;
        }
    }
    
    private void OnMouseEntered()
    {
        // TODO: implement showing selector
    }
    
    private void OnMouseExited()
    {
        // TODO: implement hiding selector
    }

    private void OnGuiInput(InputEvent @event)
    {
        // TODO: implement LMB, RMB and discarding
    }

    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);
    }
    
    private void LoadCards(JsonDocument document)
    {
        var root = document.RootElement;
        if(root.ValueKind != JsonValueKind.Array) return;
        foreach (var card in root.EnumerateArray())
        {
            var newCard = new Cards();
            newCard.Load(card);
            CardsList.Add(newCard);
        }
    }
}