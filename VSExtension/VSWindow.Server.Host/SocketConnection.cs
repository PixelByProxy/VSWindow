using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Linq;
using System.Threading;
using Microsoft.AspNet.SignalR;
using PixelByProxy.VSWindow.Server.Shared;
using PixelByProxy.VSWindow.Server.Shared.Model;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Host
{
    internal class SocketConnection
    {
        #region Private Fields
        private TcpListener _listener;
        private Thread _socketThread;
        private readonly Collection<string> _messages;
        private NetworkStream _stream;
        private TcpClient _client;
        private byte[] _data;
        private bool _isAborting;
        private string _statusText;
        private string _activeConnectionId;
        private string _lastConnectionId;
        private readonly byte[] _nullByte = Encoding.UTF8.GetBytes(new[] { (char)0 });
        private readonly AutoResetEvent _autoEvent;
        private CommandMessage _lastSubscriptionMessage;
        private bool _isConnected;
        #endregion

        public SocketConnection()
        {
            _messages = new Collection<string>();
            _autoEvent = new AutoResetEvent(false);

            // start the socket listening thread
            StartListener();
        }

        public void SendMessageAsync(CommandResponse response)
        {
            SendMessageAsync(JsonHelper.Serialize(response));
        }
        public void SendMessageAsync(string message)
        {
            Action<string> send = SendMessage;
            send.BeginInvoke(message, null, null);
        }
        public void UpdateWindowInfo(string connectionId)
        {
            try
            {
                // make sure we are connected
                ConnectFirstClient();

                if (string.Equals(connectionId, _activeConnectionId, StringComparison.Ordinal))
                {
                    var instance = GetActiveInstances().FirstOrDefault(i => string.Equals(i.ConnectionId, connectionId, StringComparison.Ordinal));

                    SendMessageAsync(new WindowChangedCommandResponse
                    {
                        Instance = instance
                    });
                }
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("SendMessage Failed", ex);
            }
        }
        public void RegisterInstance(VisualStudioInstance instance)
        {
            try
            {
                if (ClientInfo.Instances.Any(i => i.Id == instance.Id)) return;
                ClientInfo.Instances.Add(instance);
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("Unable to register instance.", ex);
            }
        }
        public void UnregisterInstance(Guid instanceId)
        {
            var client = ClientInfo.Instances.FirstOrDefault(i => i.Id == instanceId);
            if (client != null)
            {
                // remove the instance
                ClientInfo.Instances.Remove(client);

                Program.Connection.SendMessageAsync(new InstanceClosedCommandResponse { CommandValue = instanceId });

                Console.WriteLine("Visual Studio process {0} disconnected.", client.ProcessId);

                // select the next instance
                if (string.Equals(client.ConnectionId, _activeConnectionId, StringComparison.Ordinal))
                {
                    _activeConnectionId = null;
                    ConnectFirstClient();
                }
            }
        }
        public void Close()
        {
            StatusText = "Closing socket...";

            try
            {
                _isAborting = true;

                _autoEvent.Set();

                if (_client != null)
                {
                    _client.Close();
                    _client = null;
                }

                if (_listener != null)
                {
                    _listener.Stop();
                    _listener = null;
                }

                if (_socketThread != null && _socketThread.IsAlive)
                {
                    _socketThread.Abort();
                    _socketThread = null;
                }
            }
            finally
            {
                _isAborting = false;
            }
        }

        private void StartListener()
        {
            _autoEvent.Reset();
            _socketThread = new Thread(ConnectSocket);
            _socketThread.Start();
        }
        private void ConnectSocket()
        {
            try
            {
                StatusText = "Opening socket...";

                if (_listener == null)
                {
                    bool connected = false;
                    const int maxRetries = 8;
                    int currentTry = 0;

                    do
                    {
                        currentTry++;

                        try
                        {
                            _listener = new TcpListener(IPAddress.Any, ServerSettings.SocketPort);
                            _listener.Start();
                            connected = true;
                        }
                        catch (Exception ex)
                        {
                            Log.Instance.WarnException(string.Format("Unable to connect to the socket attempt {0} of {1}.", currentTry, maxRetries), ex);

                            if (currentTry > maxRetries)
                                throw;
                        }

                        if (!connected && !_isAborting)
                            _autoEvent.WaitOne(15000);

                    } while (!connected && !_isAborting);
                }

                if (_isAborting)
                    return;

                StatusText = "Listening for connections...";

                // reset the active connection
                _activeConnectionId = null;

                _isConnected = false;
                _client = _listener.AcceptTcpClient();
                _client.NoDelay = true;
                _isConnected = true;
                _activeConnectionId = null;

                StatusText = string.Format(CultureInfo.CurrentCulture, "Connected to {0}", _client.Client.RemoteEndPoint);

                // get the window title
                string title = null;

                if (!string.IsNullOrEmpty(_lastConnectionId))
                {
                    var lastInstance = GetActiveInstances().FirstOrDefault(i => string.Equals(_lastConnectionId, i.ConnectionId, StringComparison.Ordinal));
                    if (lastInstance != null)
                    {
                        title = lastInstance.Title;
                    }
                }
                
                if (title == null && Program.LauncherProcess > 0)
                {
                    title = string.Concat(GetProcessTitle(Program.LauncherProcess), " (", Program.LauncherProcess, ")");
                }

                // notify the client we are connected
                var connectedResponse = new ConnectedCommandResponse
                    {
                        ServiceVersion = ServerSettings.ServiceVersion.ToString(CultureInfo.InvariantCulture),
                        Password = ServerSettings.SocketPassword,
                        InstanceTitle = title
                    };
                SendMessageAsync(connectedResponse);

                _data = new byte[ServerSettings.BufferSize];
                _stream = _client.GetStream();
                _stream.BeginRead(_data, 0, ServerSettings.BufferSize, ReceiveMessage, _stream);

                _autoEvent.WaitOne();
            }
            catch (Exception ex)
            {
                if (!_isAborting)
                {
                    StatusText = "An error occurred attempting to connect to the socket.";
                    Log.Instance.ErrorException("Socket Exception", ex);
                }
            }
        }
        private void SendMessage(string message)
        {
            try
            {
                if (_client == null || !_isConnected)
                    return;

                if (!_client.GetStream().CanWrite)
                {
                    _messages.Add(message);
                    Log.Instance.Debug("Added message to queue.");
                }
                else
                {
                    // send the message
                    List<byte> sendBytes = new List<byte>(Encoding.UTF8.GetBytes(message));
                    sendBytes.AddRange(_nullByte);

                    NetworkStream stream = _client.GetStream();
                    stream.WriteTimeout = 10000;
                    stream.Write(sendBytes.ToArray(), 0, sendBytes.Count);
                    stream.Flush();

                    //Log.Instance.Debug("Message Sent ({0}) = {1}", sendBytes.Count, message);

                    // if there is another message send it
                    if (_messages.Count > 0)
                    {
                        var nextMessage = _messages[0];
                        _messages.Remove(nextMessage);
                        SendMessageAsync(nextMessage);
                        Log.Instance.Debug("Removed message from queue.");
                    }
                }
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("SendMessage Failed", ex);
            }
        }
        private void ReceiveMessage(IAsyncResult ar)
        {
            NetworkStream ns = ar.AsyncState as NetworkStream;

            try
            {
                if (_client != null && ns != null)
                {
                    int bufferLength = ns.EndRead(ar);

                    if (bufferLength > 0)
                    {
                        // Receive the message from client side.
                        string messageReceived = Encoding.UTF8.GetString(_data, 0, bufferLength);

                        if (!string.IsNullOrEmpty(messageReceived))
                        {
                            var context = GlobalHost.ConnectionManager.GetHubContext<StudioHub>();

                            //Trace.WriteLine(string.Format(CultureInfo.CurrentCulture, "Received: {0}", messageReceived));

                            string[] messages = messageReceived.Split(new[] {"}{"}, StringSplitOptions.RemoveEmptyEntries);

                            foreach (string message in messages)
                            {
                                // fix the message from the split
                                string formattedMessage = message;

                                if (!formattedMessage.StartsWith("{", StringComparison.Ordinal))
                                    formattedMessage = string.Concat("{", formattedMessage);

                                if (!formattedMessage.EndsWith("}", StringComparison.Ordinal))
                                    formattedMessage = string.Concat(formattedMessage, "}");

                                // deserialize the message
                                CommandMessage cmd = JsonHelper.Deserialize<CommandMessage>(formattedMessage);

                                // check if the command is handled globally
                                if (HandleCommand(cmd)) continue;

                                // store the active subscription
                                if (string.Equals(cmd.CommandName, "Subscribe", StringComparison.Ordinal))
                                {
                                    _lastSubscriptionMessage = cmd;
                                }

                                // make sure we have an active client
                                ConnectFirstClient();

                                // send to the client
                                if (!string.IsNullOrEmpty(_activeConnectionId))
                                {
                                    context.Clients.Client(_activeConnectionId).Receive(cmd);
                                }
                                else
                                {
                                    Log.Instance.Debug("A command {0} was sent without an active connection.", cmd.CommandName);
                                }
                            }
                        }    
                    }
                    else if (QueryConnection())
                    {
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                // check for a connection reset
                SocketException sockEx = ex.InnerException as SocketException;
                if (sockEx != null && sockEx.SocketErrorCode == SocketError.ConnectionReset)
                {
                    _autoEvent.Set();
                    StartListener();
                    return;
                }
                else
                {
                    Log.Instance.ErrorException("ReceiveMessage Failed", ex);
                }
            }

            try
            {
                // Continue reading from client. 
                if (_client != null && ns != null)
                {
                    ns.BeginRead(_data, 0, ServerSettings.BufferSize, ReceiveMessage, ns);
                }
            }
            catch (ObjectDisposedException ode)
            {
                Log.Instance.ErrorException("Failed to read from the client because the object was disposed.", ode);
                Close();
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("Failed to read from the client.", ex);
                Close();
            }
        }
        private bool QueryConnection()
        {
            bool inactive = false;

            try
            {
                if (_client != null && _client.Client.Poll(1000, SelectMode.SelectRead) && _client.Client.Available == 0)
                {
                    inactive = true;
                    _autoEvent.Set();
                    StartListener();
                }
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("QueryConnection Failed", ex);
            }

            return inactive;
        }
        private Collection<VisualStudioInstance> GetActiveInstances()
        {
            Collection<VisualStudioInstance> instances = new Collection<VisualStudioInstance>();
            List<VisualStudioInstance> instancesToRemove = new List<VisualStudioInstance>();

            foreach (var instance in ClientInfo.Instances)
            {
                var process = Process.GetProcessById(instance.ProcessId);
                if (!process.HasExited)
                {
                    // update the title
                    instance.Title = GetProcessTitle(process);

                    instances.Add(instance);
                }
                else
                {
                    // add the item to the list of instances to remove
                    instancesToRemove.Add(instance);
                }
            }

            // remove all of the invalid instances
            if (instancesToRemove.Count > 0)
                instancesToRemove.ForEach(i => ClientInfo.Instances.Remove(i));

            return instances;
        }
        private string GetProcessTitle(int processId)
        {
            string title = null;

            try
            {
                var process = Process.GetProcessById(processId);
                title = GetProcessTitle(process);
            }
            catch (Exception)
            {
            }

            return title;
        }
        private string GetProcessTitle(Process process)
        {
            string title = "Visual Studio";

            if (!process.HasExited)
            {
                // update the title
                string[] titleParts = process.MainWindowTitle.Split('-');

                if (titleParts.Length > 1)
                    title = titleParts[0].Trim();
            }

            return title;
        }
        private bool HandleCommand(CommandMessage command)
        {
            bool handled = false;

            switch (command.CommandName)
            {
                case "ListInstances":

                    // get the list of Visual Studio connection
                    SendMessageAsync(new InstancesCommandResponse
                        {
                            Instances = GetActiveInstances()
                        });
                    
                    handled = true;
                    
                    break;
                case "SetActiveInstance":

                    // get the instance
                    var instance = GetActiveInstances().FirstOrDefault(i => string.Equals(i.ConnectionId, command.CommandArgs, StringComparison.Ordinal));
                    if (instance != null)
                    {
                        _activeConnectionId = command.CommandArgs;
                        _lastConnectionId = _activeConnectionId;
                        
                        SendMessageAsync(new InstanceSelectedCommandResponse
                        {
                            CommandValue = true,
                            Instance = instance
                        });

                        // re-subscribe for the current instnace
                        if (_lastSubscriptionMessage != null)
                        {
                            var context = GlobalHost.ConnectionManager.GetHubContext<StudioHub>();
                            context.Clients.Client(_activeConnectionId).Receive(_lastSubscriptionMessage);
                        }
                    }
                    else
                    {
                        // find the existing instance
                        instance = ClientInfo.Instances.FirstOrDefault(i => string.Equals(i.ConnectionId, _activeConnectionId, StringComparison.Ordinal));

                        SendMessageAsync(new InstanceSelectedCommandResponse
                        {
                            CommandValue = false,
                            Instance = instance
                        });
                    }

                    handled = true;

                    break;
            }

            return handled;
        }
        private void ConnectFirstClient()
        {
            if (string.IsNullOrEmpty(_activeConnectionId))
            {
                var activeInstances = GetActiveInstances();
                if (activeInstances.Count > 0)
                {
                    // select the first instance
                    // if the launcher process is up then use that
                    VisualStudioInstance firstInstance = null;

                    // find the one we were last connected to
                    if (!string.IsNullOrEmpty(_lastConnectionId))
                    {
                        firstInstance = activeInstances.FirstOrDefault(i => string.Equals(i.ConnectionId, _lastConnectionId, StringComparison.Ordinal));
                    }

                    // if not found then reconnect to the VS instance that launched us
                    // if not available then just connect to the first available instance
                    if (firstInstance == null)
                    {
                        firstInstance = activeInstances.FirstOrDefault(ai => ai.ProcessId == Program.LauncherProcess) ?? activeInstances[0];
                    }

                    if (firstInstance != null)
                    {
                        _activeConnectionId = firstInstance.ConnectionId;
                        _lastConnectionId = _activeConnectionId;

                        // resubscribe
                        if (_lastSubscriptionMessage != null)
                        {
                            var context = GlobalHost.ConnectionManager.GetHubContext<StudioHub>();
                            context.Clients.Client(_activeConnectionId).Receive(_lastSubscriptionMessage);
                        }
                    }

                    SendMessageAsync(new InstanceSelectedCommandResponse
                    {
                        CommandValue = true,
                        Instance = firstInstance
                    });
                }
            }
        }

        #region Public Properties
        public string StatusText
        {
            get { return _statusText; }
            set
            {
                _statusText = value;

                // update the status on the client windows
                var context = GlobalHost.ConnectionManager.GetHubContext<StudioHub>();
                if (context != null)
                    context.Clients.All.UpdateStatus(value);
            }
        }
        #endregion
    }
}