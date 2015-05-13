using System;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Threading;
using System.Xml.Linq;
using PixelByProxy.VSWindow.Server.Shared;

namespace PixelByProxy.VSWindow.Server.Services
{
    /// <summary>
    /// Class for managing the host process.
    /// </summary>
    internal class HostService
    {
        #region Constants
        private const string HostServiceName = "VSWindow";
        #endregion

        #region Private Fields
        private AutoResetEvent _hubResetEvent;
        #endregion

        #region Public Methods
        /// <summary>
        /// Starts the VSWindow host.
        /// </summary>
        /// <returns></returns>
        public bool StartHost()
        {
            bool started = false;

            try
            {
                // make sure the host isn't already started
                var hostProcesses = Process.GetProcessesByName(HostServiceName);
                var vsHostProcesses = Process.GetProcessesByName(string.Concat(HostServiceName, ".vshost"));

                if (hostProcesses.Length == 0 && vsHostProcesses.Length == 0)
                {
                    _hubResetEvent = new AutoResetEvent(false);

                    // copy the exe to the parent dir so the directory
                    // doesn't change every time we install the plugin
                    // this prevents the firewall prompt from popping on upgrade
                    // ReSharper disable PossibleNullReferenceException
                    string exeName = string.Concat(HostServiceName, ".exe");
                    var currentDirInfo = new FileInfo(GetType().Assembly.Location).Directory;
                    var parentDirInfo = currentDirInfo.Parent;
                    string hostOrgProcess = Path.Combine(currentDirInfo.FullName, exeName);
                    string hostProcess = Path.Combine(parentDirInfo.FullName, exeName);
                    string hostProcessConfig = Path.Combine(parentDirInfo.FullName, string.Concat(exeName, ".config"));
                    // ReSharper restore PossibleNullReferenceException

                    CreateAppConfig(hostProcessConfig, currentDirInfo.Name);
                    File.Copy(hostOrgProcess, hostProcess, true);

                    // start the hub
                    ProcessStartInfo info = new ProcessStartInfo(hostProcess)
                        {
                            CreateNoWindow = true,
                            UseShellExecute = false,
                            RedirectStandardInput = true,
                            RedirectStandardOutput = true,
                            RedirectStandardError = true,
                            Arguments = Process.GetCurrentProcess().Id.ToString(CultureInfo.InvariantCulture)
                        };

                    Process processc = new Process();
                    processc.OutputDataReceived += Process_OutputDataReceived;
                    processc.StartInfo = info;
                    processc.EnableRaisingEvents = true;
                    processc.Start();
                    processc.BeginOutputReadLine();

                    // wait for the hub to become available
                    _hubResetEvent.WaitOne();

                    started = true;
                }
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("Unable to start the host." + new FileInfo(GetType().Assembly.Location).DirectoryName + HostServiceName, ex);
            }

            return started;
        }
        /// <summary>
        /// Kills the host process.
        /// </summary>
        /// <returns></returns>
        public void StopHost()
        {
            try
            {
                // find the host
                var hostProcess = Process.GetProcessesByName(HostServiceName);

                // kill the process
                foreach (var process in hostProcess)
                {
                    process.WaitForExit(5000);

                    if (!process.HasExited)
                        process.Kill();
                }
            }
            catch (Exception ex)
            {
                Log.Instance.ErrorException("Unable to stop the host.", ex);
            }
        }
        #endregion

        #region Private Methods
        private void CreateAppConfig(string filePath, string probingPath)
        {
            XNamespace ns = "urn:schemas-microsoft-com:asm.v1";

            XElement ele = new XElement("configuration",
                new XElement("runtime",
                    new XElement(ns + "assemblyBinding",
                        new XElement(ns + "probing",
                            new XAttribute("privatePath", probingPath)))));

            ele.Save(filePath);
        }
        #endregion

        #region Event Methods
        /// <summary>
        /// Handles the output from the console window.
        /// </summary>
        /// <param name="sendingProcess"></param>
        /// <param name="e"></param>
        private void Process_OutputDataReceived(object sendingProcess, DataReceivedEventArgs e)
        {
            if (_hubResetEvent != null && !string.IsNullOrEmpty(e.Data) && e.Data.IndexOf(ServerSettings.HostReadyText, StringComparison.Ordinal) > -1)
            {
                _hubResetEvent.Set();
            }
        }
        #endregion
    }
}