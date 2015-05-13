using System;
using System.ComponentModel;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.NetworkInformation;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using Microsoft.VisualStudio.Shell;
using PixelByProxy.VSWindow.Server.Services;
using PixelByProxy.VSWindow.Server.Shared;

namespace PixelByProxy.VSWindow.Server.UI
{
    [Guid(Constants.GuidOptionsPageGeneral)]
    public class OptionsPageGeneral : DialogPage
    {
        #region Fields
        private OptionsGeneralControl _generalOptionsPage;
        private IGlobalWindowService _windowService;
        #endregion

        #region Properties
        /// <summary>
        /// Gets the window an instance of DialogPage that it uses as its user interface.
        /// </summary>
        /// <devdoc>
        /// The window this dialog page will use for its UI.
        /// This window handle must be constant, so if you are
        /// returning a Windows Forms control you must make sure
        /// it does not recreate its handle.  If the window object
        /// implements IComponent it will be sited by the 
        /// dialog page so it can get access to global services.
        /// </devdoc>
        [Browsable(false), DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
        protected override IWin32Window Window
        {
            get { return _generalOptionsPage ?? (_generalOptionsPage = new OptionsGeneralControl {Location = new Point(0, 0), OptionsPage = this}); }
        }
        #endregion

        #region Overriden Methods
        /// <summary>
        /// Dialog became active.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnActivate(CancelEventArgs e)
        {
            _windowService = GetService(typeof(IGlobalWindowService)) as IGlobalWindowService;

            if (_windowService != null)
            {
                _windowService.StatusChanged += WindowService_StatusChanged;
                _generalOptionsPage.ServiceStatusText = _windowService.StatusText;
            }
            else
            {
                _generalOptionsPage.ServiceStatusText = "Unable to load service.";
            }
        }
        /// <summary>
        /// Dialog was deactivated.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnDeactivate(CancelEventArgs e)
        {
            try
            {
                if (!_generalOptionsPage.IsValid)
                {
                    e.Cancel = true;
                    MessageBox.Show(_generalOptionsPage.ErrorMessage, "VS Window", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                else if (ServerSettings.SocketPort != _generalOptionsPage.Port)
                {
                    e.Cancel = ValidatePort(_generalOptionsPage.Port);
                }
                else if (ServerSettings.SignalPort != _generalOptionsPage.SignalPort)
                {
                    e.Cancel = ValidatePort(_generalOptionsPage.SignalPort);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed to parse the VS Window settings.", "VS Window", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Log.Instance.ErrorException("Error occurred in VSWindow deactivate settings.", ex);
            }

            base.OnDeactivate(e);
        }
        /// <summary>
        /// Updates the connection settings.
        /// </summary>
        /// <param name="e"></param>
        protected override void OnApply(PageApplyEventArgs e)
        {
            try
            {
                if (e.ApplyBehavior == ApplyKind.Apply)
                {
                    bool optionsChanged = false;

                    // update the properties
                    if (ServerSettings.SocketPort != _generalOptionsPage.Port)
                    {
                        ServerSettings.SocketPort = _generalOptionsPage.Port;
                        optionsChanged = true;
                    }

                    if (ServerSettings.SocketPassword != _generalOptionsPage.Password)
                    {
                        ServerSettings.SocketPassword = _generalOptionsPage.Password;
                        optionsChanged = true;
                    }

                    if (ServerSettings.SignalPort != _generalOptionsPage.SignalPort)
                    {
                        ServerSettings.SignalPort = _generalOptionsPage.SignalPort;
                        optionsChanged = true;
                    }

                    if (optionsChanged)
                        _windowService.UpdateSettings();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Failed to apply the VS Window settings.", "VS Window", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Log.Instance.ErrorException("Error occurred in VSWindow apply settings.", ex);
            }

            base.OnApply(e);
        }
        #endregion

        #region Event Methods
        /// <summary>
        /// Handles the StatusChanged event of the service.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void WindowService_StatusChanged(object sender, EventArgs e)
        {
            _generalOptionsPage.ServiceStatusText = _windowService.StatusText;
        }
        #endregion

        #region Private Methods
        /// <summary>
        /// Checks that the port is open and if not prompts the user.
        /// </summary>
        /// <param name="port"></param>
        /// <returns></returns>
        private static bool ValidatePort(int port)
        {
            bool cancel = false;
            bool connected = IsPortAvailable(port);
            DialogResult result = DialogResult.Retry;

            while (!connected && result != DialogResult.Ignore && result != DialogResult.Abort)
            {
                result = MessageBox.Show(string.Format(CultureInfo.CurrentCulture, "Port {0} is already in use.", port), "VS Window", MessageBoxButtons.AbortRetryIgnore, MessageBoxIcon.Warning);

                if (result == DialogResult.Retry)
                {
                    connected = IsPortAvailable(port);
                }
            }

            if (!connected && result == DialogResult.Abort)
            {
                cancel = true;
            }

            return cancel;
        }
        /// <summary>
        /// Checks if the port is already being used.
        /// </summary>
        /// <param name="port"></param>
        /// <returns></returns>
        private static bool IsPortAvailable(int port)
        {
            bool available = true;

            try
            {
                // get the open ports
                IPGlobalProperties ipGlobalProperties = IPGlobalProperties.GetIPGlobalProperties();
                IPEndPoint[] tcpConnInfoArray = ipGlobalProperties.GetActiveTcpListeners();

                available = tcpConnInfoArray.All(ep => ep.Port != port);
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("Unable to check the open ports.", ex);
            }

            return available;
        }
        #endregion
    }
}