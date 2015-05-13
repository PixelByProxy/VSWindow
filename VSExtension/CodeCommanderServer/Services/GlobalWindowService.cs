using System;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Threading;
using EnvDTE80;
using Microsoft.AspNet.SignalR.Client;
using Microsoft.AspNet.SignalR.Client.Hubs;
using PixelByProxy.VSWindow.Server.Shared;
using PixelByProxy.VSWindow.Server.Shared.Model;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Services
{
    public sealed class GlobalWindowService : IGlobalWindowService
    {
        #region Private Fields
        private readonly Guid _signalRId;
        private readonly DTE2 _dte;
        private readonly HostService _host;
        private readonly AutoResetEvent _messageResetEvent;
        private Thread _hubThread;
        private ModelBase _activeModel;
        private string _statusText;
        private HubConnection _hubConnection;
        private IHubProxy _hub;
        #endregion

        #region Constructors
        /// <summary>
        /// Default ctor.
        /// </summary>
        /// <param name="dte"></param>
        public GlobalWindowService(DTE2 dte)
        {
            _signalRId = Guid.NewGuid();
            _host = new HostService();
            _dte = dte;
            _messageResetEvent = new AutoResetEvent(true);

            // hook up events
            _dte.Events.WindowEvents.WindowActivated += WindowEvents_WindowActivated;

            // connect the hub
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
            _hubThread = new Thread(StartConnection);
            _hubThread.Start();
        }
        private void StartConnection()
        {
            try
            {
                // start the host
                StatusText = "Starting host...";
                _host.StartHost();

                // connect the hub
                ConnectHub();
            }
            catch (Exception ex)
            {
                StatusText = "An error occurred attempting to start the host.";
                Log.Instance.WarnException("Unable to start the host.", ex);
            }
        }
        private void RestartConnection()
        {
            try
            {
                // give it a few seconds to re-connect
                Thread.Sleep(10000);

                // connect the hub
                ConnectHub();
            }
            catch (Exception ex)
            {
                Log.Instance.WarnException("Unable to start the host.", ex);
            }
        }
        private void ConnectHub()
        {
            try
            {
                // create the SignalR hub
                _hubConnection = new HubConnection(string.Format(ServerSettings.SignalUrl, ServerSettings.SignalPort));
                _hubConnection.Error += HubConnection_Error;
                _hub = _hubConnection.CreateHubProxy("StudioHub");

                // wire up the events
                _hub.On<string>("UpdateStatus", OnStatusUpdate);
                _hub.On<CommandMessage>("Receive", OnReceiveSignal);
                _hub.On("Disconnect", OnDisconnect);

                // connect to the hub
                _hubConnection.Start().Wait(-1);

                // get the status text
                var task = _hub.Invoke<string>("GetStatusText");
                task.Wait();
                StatusText = task.Result;
                
                // report to SignalR
                var process = Process.GetCurrentProcess();
                var devEnvVersion = FileVersionInfo.GetVersionInfo(process.MainModule.FileName);
                VisualStudioInstance instance = new VisualStudioInstance
                {
                    Id = _signalRId,
                    ProcessId = process.Id,
                    ConnectionId = _hubConnection.ConnectionId,
                    SolutionName = Utils.GetSolutionName(_dte)
                };

                // get the visual studio version
                switch(devEnvVersion.FileMajorPart)
                {
                    case 14:
                        instance.Version = 2015;
                        break;
                    case 12:
                        instance.Version = 2013;
                        break;
                    case 11:
                        instance.Version = 2012;
                        break;
                    default:
                        instance.Version = 2010;
                        break;
                }

                _hub.Invoke<VisualStudioInstance>("RegisterInstance", instance).Wait();
            }
            catch (Exception ex)
            {
                StatusText = "An error occurred attempting to connect to the host.";
                Log.Instance.WarnException(StatusText, ex);
            }
        }
        private void OnStatusUpdate(string status)
        {
            try
            {
                StatusText = status;
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("StatusUpdate Failed", ex);
            }
        }
        private void OnReceiveSignal(CommandMessage cmd)
        {
            try
            {
                if (cmd == null) return;

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
                //SolutionModel mod = new SolutionModel(_dte);
                //var response = mod.ExecuteCommand(new CommandMessage { CommandName = "List" });

                //string id = null;

                //foreach(var i in ((SolutionCommandResponse)response).Items)
                //{
                //    id = i.Id;
                //}

                //var response2 = mod.ExecuteCommand(new CommandMessage { CommandName = "GetSubItems", CommandArgs = id});
                //response = _activeModel.ExecuteCommand(cmd);

                CommandResponse response = _activeModel.ExecuteCommand(cmd);

                SendSignal(response);

                // bring the VS window to the front
                ActivateWindow();
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("ReceiveMessage Failed", ex);
            }
        }
        private void OnDisconnect()
        {
            // restart the connection
            _hubThread = new Thread(RestartConnection);
            _hubThread.Start();
        }
        private void SendSignal(CommandResponse response)
        {
            Action<CommandResponse> send = SendSignalAsync;
            send.BeginInvoke(response, null, null);
        }
        private void SendSignalAsync(CommandResponse response)
        {
            try
            {
                // wait for the previous message to send
                _messageResetEvent.WaitOne();
                _messageResetEvent.Reset();

                // send to the hub
                string message = JsonHelper.Serialize(response);
                _hub.Invoke<string>("Send", message).Wait();

                Log.Instance.Debug("Signal Sent = {0}", message);
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("Unable to send the signal.", ex);
            }
            finally
            {
                _messageResetEvent.Set();
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
        private void ActivateWindow()
        {
            try
            {
                // bring this window to the front
                RunProcess.BringProcessToFront(Process.GetCurrentProcess().MainWindowHandle);
            }
            catch (Exception ex)
            {
                Log.Instance.DebugException("Unable to activate the window.", ex);
            }
        }
        #endregion

        #region Event Methods
        private void WindowEvents_WindowActivated(EnvDTE.Window gotFocus, EnvDTE.Window lostFocus)
        {
            if (!Utils.IsSolutionOpen(_dte))
                UpdateWindowInfo();
        }
        private void ActiveModel_Changed(object sender, ModelChangedEventArgs e)
        {
            SendSignal(e.Response);
        }
        private void HubConnection_Error(Exception obj)
        {
            try
            {
                StatusText = "Host connection closed.";
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("HubConnection Error Failed", ex);
            }
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
        public void UpdateWindowInfo()
        {
            if (_hubConnection != null && _hubConnection.State == ConnectionState.Connected)
            {
                Action updateWindow = () =>
                 {
                     try
                     {
                         _hub.Invoke<string>("UpdateWindowInfo", _hubConnection.ConnectionId, Utils.GetSolutionName(_dte)).Wait();
                     }
                     catch (Exception ex)
                     {
                         Log.Instance.ErrorException("Unable to update the window information.", ex);
                     }
                 };

                updateWindow.BeginInvoke(null, null);
            }
        }
        public void UpdateSettings()
        {
            // disconnect from the hub
            if (_hubConnection != null && _hubConnection.State == ConnectionState.Connected)
                _hub.Invoke("DisconnectAll").Wait();

            // re-start the host
            _host.StopHost();
            _host.StartHost();
        }
        public void Close()
        {
            StatusText = "Disconnecting from the Hub...";

            try
            {
                if (_hub != null)
                {
                    _hub.Invoke<VisualStudioInstance>("UnregisterInstance", _signalRId);
                }

                if (_hubThread != null && _hubThread.IsAlive)
                {
                    _hubThread.Abort();
                    _hubThread = null;
                }
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("Failed to disconnect from the hub.", ex);
            }
        }
        #endregion
    }
}