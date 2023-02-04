using Godot;

namespace Arcomage.Scripts
{
    public class NetworkSetup : Control
    {
        private VBoxContainer _multiplayerConfigUi;
        private LineEdit _serverIpAddress;
        private Label _deviceIpAddress;
        private Network _networkInstance;

        public override void _EnterTree()
        {
            base._EnterTree();
            _multiplayerConfigUi = GetNode<VBoxContainer>("container");
            _serverIpAddress = GetNode<LineEdit>("container/ip_addr");
            _deviceIpAddress = GetNode<Label>("device_ip_addr");
        }

        public override void _Ready()
        {
            _networkInstance = new Network();
            GetTree().Connect("network_peer_connected", this, "PlayerConnected");
            GetTree().Connect("network_peer_disconnected", this, "PlayerDisconnected");

            _deviceIpAddress.Text = Network.IpAddress;
            _networkInstance.Connect("server_created", this, "OnReadyToPlay");
            _networkInstance.Connect("join_success", this, "OnReadyToPlay");
            _networkInstance.Connect("join_fail", this, "OnReadyToPlay");
        }

        private void PlayerConnected(int id)
        {
            Global.Log($"Player {id} has connected!");
        }

        private void PlayerDisconnected(int id)
        {
            Global.Log($"Player {id} has disconnected!");
        }

        private void OnCreateServerPressed()
        {
            _networkInstance.CreateServer();
            _multiplayerConfigUi.Hide();
        }

        private void OnJoinServerPressed()
        {
            if (_serverIpAddress.Text == string.Empty) return;
            Network.IpAddress = _serverIpAddress.Text;
            _networkInstance.JoinServer();
            _multiplayerConfigUi.Hide();
        }

        private void OnCancelPressed() => Hide();
        private void OnReadyToPlay() => GetTree().ChangeScene("res://Scenes/Table.tscn");

        private void OnJoinFail()
        {
            _multiplayerConfigUi.Show();
            Global.Log("Failed to join server.");
        }
    }
}
