using System;
using Microsoft.Win32;
using NLog;

namespace PixelByProxy.VSWindow.Server.Shared
{
    public static class ServerSettings
    {
        public const string HostReadyText = "---READY---";
        public const int MaxItemCount = 100;
        public const int MaxTextLength = 20000;
        public const int BufferSize = 1024;
        public const int ServiceVersion = 6;
        public const string SignalUrl = "http://localhost:{0}/vswindow/";

        private const string SettingsRegKey = "HKEY_CURRENT_USER\\SOFTWARE\\PixelByProxy\\VSWindow";
        private const int DefaultSocketPort = 39739;
        private const int DefaultSignalPort = 37937;

        public static int SocketPort
        {
            get
            {
                int port;

                if (!int.TryParse(GetSetting("SocketPort"), out port) || port <= 0 || port > 65535)
                    return DefaultSocketPort;

                return port;
            }
            set { SetSetting("SocketPort", value); }
        }
        public static int SignalPort
        {
            get
            {
                int port;

                if (!int.TryParse(GetSetting("SignalPort"), out port) || port <= 0 || port > 65535)
                    return DefaultSignalPort;

                return port;
            }
            set { SetSetting("SignalPort", value); }
        }
        public static string SocketPassword
        {
            get { return GetSetting("SocketPassword"); }
            set { SetSetting("SocketPassword", value); }
        }
        public static LogLevel LogLevel
        {
            get
            {
                LogLevel level = LogLevel.Error;

                string setting = GetSetting("LogLevel");

                if (!string.IsNullOrEmpty(setting))
                {
                    switch (setting.ToUpperInvariant())
                    {
                        case "DEBUG":
                            level = LogLevel.Debug;
                            break;
                        case "ERROR":
                            level = LogLevel.Error;
                            break;
                        case "FATAL":
                            level = LogLevel.Fatal;
                            break;
                        case "OFF":
                            level = LogLevel.Off;
                            break;
                        case "TRACE":
                            level = LogLevel.Trace;
                            break;
                        case "WARN":
                            level = LogLevel.Warn;
                            break;
                    }
                }

                return level;
            }
            set { SetSetting("LogLevel", value); }
        }
        /// <summary>
        /// Gets/Sets if the firewall dialog should be shown.
        /// </summary>
        public static bool NeverShowFirewallDialog
        {
            get
            {
                bool neverShow;
                bool.TryParse(GetSetting("NeverShowFirewallDialog"), out neverShow);

                return neverShow;
            }
            set { SetSetting("NeverShowFirewallDialog", value); }
        }

        private static string GetSetting(string name)
        {
            string value = null;

            try
            {
                object regValue = Registry.GetValue(SettingsRegKey, name, null);
                if (regValue != null)
                    value = regValue.ToString();
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException(string.Format("Unable to load setting {0}.", name), ex);
            }

            return value;
        }
        private static void SetSetting(string name, object value)
        {
            try
            {
                Registry.SetValue(SettingsRegKey, name, value == null ? string.Empty : value.ToString());
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException(string.Format("Unable to save setting {0}.", name), ex);
            }
        }
    }
}