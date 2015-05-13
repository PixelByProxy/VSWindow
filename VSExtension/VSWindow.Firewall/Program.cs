using System;
using System.Diagnostics;
using System.Windows.Forms;

namespace PixelByProxy.VSWindow.Server.Firewall
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            int port;
            int oldPort;
            int processId;
            int vsVersion;
            string vsExe = args[3];

            int.TryParse(args[0], out port);
            int.TryParse(args[1], out oldPort);
            int.TryParse(args[2], out processId);
            int.TryParse(args[4], out vsVersion);

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            Form1 form = new Form1(port, oldPort, vsExe, vsVersion);

            // if the parent window was supplied then show it modally
            Process parentProcess = null;

            if (processId != 0)
            {
                parentProcess = Process.GetProcessById(processId);
            }

            if (parentProcess != null)
            {
                // make sure we exit if the parent is killed
                Action checkForProcessExit = () =>
                {
                    try
                    {
                        parentProcess.WaitForExit();
                        Application.Exit();
                    }
                    // ReSharper disable EmptyGeneralCatchClause
                    catch
                    // ReSharper restore EmptyGeneralCatchClause
                    {
                    }
                };

                checkForProcessExit.BeginInvoke(null, null);

                // show the dialog
                WindowWrapper wrapper = new WindowWrapper(parentProcess.MainWindowHandle);
                form.StartPosition = FormStartPosition.CenterParent;
                form.ShowInTaskbar = false;
                form.ShowDialog(wrapper);
            }
            else
            {
                // show the standard form
                form.StartPosition = FormStartPosition.WindowsDefaultLocation;
                form.ShowInTaskbar = true;
                Application.Run(form);
            }
        }
    }
}