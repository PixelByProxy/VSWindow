using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using EnvDTE80;
using PixelByProxy.VSWindow.Server.Shared;
using PixelByProxy.VSWindow.Server.Shared.Model;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;
using PixelByProxy.VSWindow.Server.UI;

namespace PixelByProxy.VSWindow.Server.Services
{
	public sealed class GlobalWindowService : IGlobalWindowService
    {
        #region Private Fields
        public const int MaxItemCount = 100;
        public const int MaxTextLength = 20000;
        private const string _firewallExeName = "VS Window Firewall";
        private const int _bufferSize = 8192;
        private const int _serviceVersion = 2;
        private readonly DTE2 _dte;
        private Thread _socketThread;
        private TcpListener _listener;
        private ModelBase _activeModel;
        private bool _sendInProgress;
        private readonly Collection<CommandResponse> _messages;
        private NetworkStream _stream;
        private TcpClient _client;
        private byte[] _data;
        private readonly UserSettings _settings;
	    private int _port = 39739;
        private string _password;
	    private bool _isAborting;
        private string _statusText;
	    private readonly OptionsPageGeneral _optionsPage;
        private readonly byte[] _nullByte = Encoding.UTF8.GetBytes(new[] { (char)0 });
        private readonly AutoResetEvent autoEvent;
        #endregion

        #region Constructors
        /// <summary>
        /// Default ctor.
        /// </summary>
        /// <param name="dte"></param>
        /// <param name="optionsPage"></param>
        public GlobalWindowService(DTE2 dte, OptionsPageGeneral optionsPage)
		{
            _settings = new UserSettings();
		    _optionsPage = optionsPage;
            _dte = dte;
            _dte.Events.WindowEvents.WindowActivated += WindowEvents_WindowActivated;

            _messages = new Collection<CommandResponse>();

            // get the saved settings
            _port = _settings.Port;
            _password = _settings.Password;

            // start the socket listening thread
            autoEvent = new AutoResetEvent(false);
            StartListener();

            // pre-cache the commands
            var cacheThread = new Thread(CacheCommands);
            cacheThread.Start();
        }
        #endregion

        #region Private Methods
        private void CacheCommands()
        {
            try
            {
                ToolBarModel model = new ToolBarModel(_dte);
                model.ListCachedToolBarItems();
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("Unable to cache the toolbar items.", ex);
            }
        }
        private void StartListener()
        {
            autoEvent.Reset();
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
                    _listener = new TcpListener(IPAddress.Any, _port);
                    _listener.Start();
                }

                StatusText = "Listening for connections...";
                
                _client = _listener.AcceptTcpClient();
                _client.NoDelay = true;

                StatusText = string.Format(CultureInfo.CurrentCulture, "Connected to {0}", _client.Client.RemoteEndPoint);

                // notify the client we are connected
                SendMessage(new ConnectedCommandResponse
                {
                    ServiceVersion = _serviceVersion.ToString(CultureInfo.InvariantCulture),
                    Password = _password
                });

                _data = new byte[_bufferSize];
                _stream = _client.GetStream();
                _stream.BeginRead(_data, 0, _bufferSize, ReceiveMessage, _stream);

                autoEvent.WaitOne();
            }
            catch (Exception ex)
            {
                if (!_isAborting)
                {
                    StatusText = "An error occurred attempting to connect to the socket.";
                    Log.Instance.WarnException("Socket Exception", ex);
                }
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

                        Trace.WriteLine(string.Format(CultureInfo.CurrentCulture, "Received ({0}): {1}", _client.Client.RemoteEndPoint, messageReceived));

                        string[] messages = messageReceived.Split(new[] { "}{" }, StringSplitOptions.RemoveEmptyEntries);

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

                            if (string.Equals(cmd.CommandName, "Subscribe", StringComparison.Ordinal))
                            {
                                // deactivate the previous model
                                if (_activeModel != null)
                                {
                                    _activeModel.Deactivate();
                                }

                                // set the active model
                                _activeModel = CreateModel(cmd.CommandArgs);
                                _activeModel.Changed += ActiveModel_Changed;
                            }

                            // return the result of the command
                            CommandResponse response = _activeModel.ExecuteCommand(cmd);

                            SendMessage(response);
                        }
                    }
                    else if (_client.Client.Poll(1000, SelectMode.SelectRead) && _client.Client.Available == 0)
                    {
                        autoEvent.Set();
                        StartListener();
                        return;
                    }
                }
            }
            catch (ObjectDisposedException ode)
            {
                //Log.Instance.DebugException("ReceiveMessage Failed with ObjectDisposedException", ode);
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("ReceiveMessage Failed", ex);
            }

            try
            {
                // Continue reading from client. 
                if (_client != null && ns != null)
                {
                    ns.BeginRead(_data, 0, _bufferSize, ReceiveMessage, ns);
                }
            }
            catch (ObjectDisposedException ode)
            {
                //Log.Instance.ErrorException("Failed to read from the client because the object was disposed.", ode);
                Close();
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("Failed to read from the client.", ex);
                Close();
            }
        }
        private void SendMessage(string message)
        {
            try
            {
                List<byte> sendBytes = new List<byte>(Encoding.UTF8.GetBytes(message));
                sendBytes.AddRange(_nullByte);

                NetworkStream stream = _client.GetStream();
                stream.Write(sendBytes.ToArray(), 0, sendBytes.Count);
                stream.Flush();

                Trace.WriteLine(string.Format("Message Sent ({0}) = {1}", sendBytes.Count, message));
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("SendMessage Failed", ex);
            }
        }
        private void SendMessage(CommandResponse response)
        {
            try
            {
                if (_sendInProgress || !_client.GetStream().CanWrite)
                {
                    _messages.Add(response);
                    Trace.WriteLine("Added message to queue");
                }
                else
                {
                    _sendInProgress = true;
                    SendMessage(JsonHelper.Serialize(response));
                    _sendInProgress = false;

                    if (_messages.Count > 0)
                    {
                        var nextMessage = _messages[0];
                        _messages.Remove(nextMessage);
                        SendMessage(nextMessage);
                        Trace.WriteLine("Removed message from queue");
                    }
                }
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("SendMessage Failed", ex);
            }
        }
        private ModelBase CreateModel(string typeName)
        {
            Type type = Type.GetType(typeName);

            if (type == null)
            {
                Log.Instance.Error(string.Format(CultureInfo.CurrentCulture, "Unable to create type {0}", typeName));
                return null;
            }

            return (ModelBase)Activator.CreateInstance(type, _dte);
        }
        private void CheckFirewall(int port, int oldPort)
        {
            try
            {
                if (!_settings.NeverShowFirewallDialog && Environment.OSVersion.Version.Major >= 6)
                {
                    string vsExe = Process.GetCurrentProcess().MainModule.FileName;
                    int vsVersion = FileVersionInfo.GetVersionInfo(vsExe).FileMajorPart;

                    // enable the port in the firewall
                    FirewallManager fw = new FirewallManager();
                    if (fw.CheckFirewallEnabled() && !fw.CheckVSWindowProgramRuleEnabled(vsExe, vsVersion))
                    {
                        string runDir = new FileInfo(this.GetType().Assembly.Location).DirectoryName;

#if DEBUG
                        runDir = null;
#endif

                        //int exitCode = RunProcess.RunWithExitCode(_firewallExeName, runDir, string.Concat(port, " ", oldPort, " ", Process.GetCurrentProcess().Id), true, false); // old port method
                        int exitCode = RunProcess.RunWithExitCode(_firewallExeName, runDir, string.Concat("0 0 ", Process.GetCurrentProcess().Id, " \"", vsExe, "\" ", vsVersion), true, false);

                        _settings.NeverShowFirewallDialog = (exitCode == 2);
                        _settings.Save();
                    }
                }
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("Unable to configure the Windows Firewall.", ex);
            }
        }
        #endregion

        #region Event Methods
        private void WindowEvents_WindowActivated(EnvDTE.Window GotFocus, EnvDTE.Window LostFocus)
        {
            _dte.Events.WindowEvents.WindowActivated -= WindowEvents_WindowActivated;

            CheckFirewall(_port, 0);
        }
        private void ActiveModel_Changed(object sender, ModelChangedEventArgs e)
        {
            SendMessage(e.Response);
        }
        #endregion

        #region IGlobalWindowService Members
        public event EventHandler StatusChanged;
        private void RaiseStatusChanged()
        {
            if (StatusChanged != null)
            {
                StatusChanged(this, EventArgs.Empty);
            }
        }
        public string StatusText
        {
            get { return _statusText; }
            set
            {
                _statusText = value;

                RaiseStatusChanged();
            }
        }
        public void UpdateSettings(int port, string password)
        {
            // update the settings
            int orgPort = _port;
            _port = port;
            _password = password;

            // recheck the firewall
            if (_port != orgPort)
            {
                CheckFirewall(_port, orgPort);
            }

            // close the existing socket
            Close();

            // reopen the socket on the new port
            StartListener();
        }
        public void ReloadSettings()
        {
            _settings.Reload();
        }
        public void Close()
        {
            StatusText = "Closing socket...";

            try
            {
                _isAborting = true;

                autoEvent.Set();

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
        #endregion
    }
}