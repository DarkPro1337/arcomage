using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using Godot;

namespace Arcomage.Scripts;

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

    public void Load(JsonElement obj)
    {
        if(obj.TryGetProperty("id", out var idElem) && idElem.ValueKind == JsonValueKind.String)
            Id = idElem.GetString();
        if(obj.TryGetProperty("name", out var nameElem) && nameElem.ValueKind == JsonValueKind.String)
            Name = nameElem.GetString();
        if(obj.TryGetProperty("description", out var descriptionElem) && descriptionElem.ValueKind == JsonValueKind.String)
            Description = descriptionElem.GetString();
        if(obj.TryGetProperty("type", out var typeElem) && typeElem.ValueKind == JsonValueKind.Number)
            Type = (CardsLayout)typeElem.GetInt32();
        if(obj.TryGetProperty("cost", out var costElem) && costElem.ValueKind == JsonValueKind.Number)
            Cost = costElem.GetInt32();
        if(obj.TryGetProperty("use", out var useElem) && useElem.ValueKind == JsonValueKind.Number)
            Use = (CardsUse)useElem.GetInt32();
        if(obj.TryGetProperty("not_discardable", out var notDiscardableElem) && notDiscardableElem.ValueKind == JsonValueKind.String)
            NotDiscardable = notDiscardableElem.GetString().Equals("true");
        if(obj.TryGetProperty("pic", out JsonElement picElem) && picElem.ValueKind == JsonValueKind.String)
            Pic = picElem.GetString();
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
        GuiInput += OnGuiInput;
        MouseEntered += OnMouseEntered;
        MouseExited += OnMouseExited;
        
        _rng.Randomize();
            
        var jsonString = System.IO.File.ReadAllText("Db/base.cdb");
        using (var document = JsonDocument.Parse(jsonString)) 
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
        CardUse = selectedCard.Use;
        CardNotDiscardable = selectedCard.NotDiscardable;

        NameLabel.Text = CardName;
        Art.Texture = GD.Load<Texture2D>(CardArt);
        Description.Text = CardDescription;
        Cost.Text = CardCost.ToString();
        NameLabel.Uppercase = UiCardUppercaseText;
        Name = CardId;

        if (CardNotDiscardable) Discardable = false;

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
        if(!root.TryGetProperty("sheets", out JsonElement sheetsElem) || sheetsElem.ValueKind != JsonValueKind.Array) return;
        foreach (var s in sheetsElem.EnumerateArray().Where(s => s.ValueKind == JsonValueKind.Object))
        {
            if(!s.TryGetProperty("name", out JsonElement nameElem) || nameElem.ValueKind != JsonValueKind.String) continue;
            var sheetName = nameElem.GetString();
            if (sheetName != null && !sheetName.Equals("cards")) continue;
            if(!s.TryGetProperty("lines", out JsonElement linesElem) || linesElem.ValueKind != JsonValueKind.Array) continue;
            foreach (var l in linesElem.EnumerateArray())
            {
                if(l.ValueKind != JsonValueKind.Object) continue;
                var value = new Cards();
                value.Load(l);
                CardsList.Add(value);
            }
        }
    }
}