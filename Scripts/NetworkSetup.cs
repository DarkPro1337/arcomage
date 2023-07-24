using Godot;

namespace Arcomage.Scripts;

public partial class NetworkSetup : Control
{
    private const int Port = 4433;
    private const int MaxPlayers = 2;
        
    private VBoxContainer MultiplayerConfigUi => GetNode<VBoxContainer>("Container");
    private LineEdit ServerIpAddress => GetNode<LineEdit>("Container/IpAddress");
    private Label DeviceIpAddress => GetNode<Label>("DeviceIpAddress");
    private Button CreateServerButton => GetNode<Button>("Container/CreateServer");
    private Button JoinServerButton => GetNode<Button>("Container/JoinServer");
    private Button CancelButton => GetNode<Button>("Cancel");
    private Node Level => GetNode<Node>("Level");

    public override void _EnterTree()
    {
        base._EnterTree();

        CreateServerButton.Pressed += OnCreateServerPressed;
        JoinServerButton.Pressed += OnConnectPressed;
        CancelButton.Pressed += OnCancelPressed;
    }

    public override void _Ready()
    {
        DeviceIpAddress.Text = Network.IpAddress;
            
        Multiplayer.ConnectionFailed += OnConnectionFailed;
        Multiplayer.ServerDisconnected += OnServerDisconnected;
        Multiplayer.ConnectedToServer += OnConnectedToServer;
            
        Multiplayer.Set("server_relay", false);

        if (DisplayServer.GetName() == "headless")
            CallDeferred(nameof(OnConnectPressed));
    }

    private void OnCancelPressed()
    {
        MultiplayerConfigUi.Show();
        Hide();
    }
        
    private void OnConnectionFailed()
    {
        Global.Log("Connection failed.");
        MultiplayerConfigUi.Show();
    }
        
    private void OnServerDisconnected()
    {
        Global.Log("Server disconnected.");
        MultiplayerConfigUi.Show();
    }

    private void OnConnectedToServer()
    {
        Global.Log("Connected to server.");
    }

    private void OnCreateServerPressed()
    {
        var peer = new ENetMultiplayerPeer();
        peer.CreateServer(Port, MaxPlayers);
            
        peer.PeerConnected += id => Global.Log("Peer connected, ID = " + id);
        peer.PeerDisconnected += id => Global.Log("Peer disconnected, ID = " + id);
            
        if (peer.GetConnectionStatus() == MultiplayerPeer.ConnectionStatus.Disconnected)
        {
            OS.Alert("Failed to start multiplayer server.");
            return;
        }

        Multiplayer.MultiplayerPeer = peer;
        StartGame();
    }
        
    public void OnConnectPressed()
    {
        var address = ServerIpAddress.Get("text").AsString();
        if (string.IsNullOrWhiteSpace(address))
        {
            Global.Log("Need a remote to connect to.");
            return;
        }
        
        var peer = new ENetMultiplayerPeer();
        peer.CreateClient(address, Port);
        if (peer.GetConnectionStatus() == MultiplayerPeer.ConnectionStatus.Disconnected)
        {
            OS.Alert("Failed to connect to server");
            return;
        }

        Multiplayer.MultiplayerPeer = peer;
        StartGame();
    }
    
    private void StartGame()
    {
        MultiplayerConfigUi.Hide();
        GetTree().Paused = false;
        
        // Load host to the table
        if (Multiplayer.IsServer())
            CallDeferred(nameof(ChangeLevel), ResourceLoader.Load("res://Scenes/Table.tscn"));
    }
    
    private void ChangeLevel(PackedScene scene)
    {
        Global.Log("Calling ChangeLevel");
        RemoveOldLevel();
        Level.AddChild(scene.Instantiate());
    }

    private void RemoveOldLevel()
    {
        foreach (var child in Level.GetChildren())
        {
            Level.RemoveChild(child);
            child.QueueFree();
        }
    }
}