using System;
using System.Linq;
using Microsoft.AspNet.SignalR;
using Microsoft.AspNet.SignalR.Hubs;
using PixelByProxy.VSWindow.Server.Shared.Model;

namespace PixelByProxy.VSWindow.Server.Host
{
    [HubName("StudioHub")]
    public class StudioHub : Hub
    {
        public void Receive(string connectionId, string message)
        {
            var client = Clients.Client(connectionId);
            if (client != null)
            {
                client.Receive(message);
            }
        }
        public void Send(string message)
        {
            Program.Connection.SendMessageAsync(message);
        }
        public void RegisterInstance(VisualStudioInstance instance)
        {
            Program.Connection.RegisterInstance(instance);
        }
        public void UnregisterInstance(Guid instanceId)
        {
            Program.Connection.UnregisterInstance(instanceId);
        }
        public void UpdateWindowInfo(string connectionId, string solutionName)
        {
            var client = ClientInfo.Instances.FirstOrDefault(i => i.ConnectionId == connectionId);
            if (client != null)
            {
                client.SolutionName = solutionName;
                Program.Connection.UpdateWindowInfo(client.ConnectionId);
            }
        }
        public void DisconnectAll()
        {
            Clients.All.Disconnect();

            Program.CloseConnection = true;
        }
        public string GetStatusText()
        {
            return Program.Connection.StatusText;
        }
    }
}