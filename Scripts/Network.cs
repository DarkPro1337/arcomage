using System.Net;
using System.Net.Sockets;
using Godot;

namespace Arcomage.Scripts
{
    public class Network : Node
    {
        private const int _defaultPort = 28960;
        private const int _maxClients = 2;

        private NetworkedMultiplayerENet _server = null;
        private NetworkedMultiplayerENet _client = null;

        public static string IpAddress = "0.0.0.0";
    
        #region Signals
        [Signal]
        delegate void ServerCreated();
        [Signal]
        delegate void JoinSuccess();
        [Signal]
        delegate void JoinFail();
        [Signal]
        delegate void PlayerListChanged();
        #endregion

        public override void _Ready()
        {
            IpAddress = GetLocalIpAddress();
        
            GetTree().Connect("network_peer_connected", this, nameof(OnPlayerConnected));
            GetTree().Connect("network_peer_disconnected", this, nameof(OnPlayerDisconnected));
            GetTree().Connect("connected_to_server", this, nameof(OnConnectedToServer));
            GetTree().Connect("connection_failed", this, nameof(OnConnectionFailed));
            GetTree().Connect("server_disconnected", this, nameof(OnDisconnectedFromServer));
        }

        public void CreateServer()
        {
            _server = new NetworkedMultiplayerENet();
            if (_server.CreateServer(_defaultPort, _maxClients) != Error.Ok)
            {
                Global.Log("Failed to create server!");
                _server = null;
                return;
            }
            GetTree().NetworkPeer = _server;
            EmitSignal(nameof(ServerCreated));
            Global.Log($"Server started at {_defaultPort}");
        }

        public void JoinServer()
        {
            _client = new NetworkedMultiplayerENet();
            if (_client.CreateClient(IpAddress, _defaultPort) != Error.Ok)
            {
                Global.Log("Failed to join server!");
                _client = null;
                EmitSignal(nameof(JoinFail));
                return;
            }
            GetTree().NetworkPeer = _client;
        }

        private static string GetLocalIpAddress()
        {
            var host = Dns.GetHostEntry(Dns.GetHostName());
            foreach (var ip in host.AddressList)
            {
                if (ip.AddressFamily == AddressFamily.InterNetwork)
                {
                    return ip.ToString();
                }
            }
            GD.PrintErr("No network adapters with an IPv4 address in the system!");
            return "0.0.0.0";
        }

        private void OnPlayerConnected(int peerId)
        {
        }

        private void OnPlayerDisconnected(int peerId)
        {
        }

        private void OnConnectedToServer()
        {
            EmitSignal(nameof(JoinSuccess));
            Global.Log("Successfully connected to server!");
        }

        private void OnConnectionFailed()
        {
            EmitSignal(nameof(JoinFail));
            GetTree().NetworkPeer = null;
            Global.Log("Connection failed!");
        }

        private void OnDisconnectedFromServer()
        {
            Global.Log("Disconnected from server!");
        }
    }
}
