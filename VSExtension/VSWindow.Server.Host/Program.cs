using System;
using System.Diagnostics;
using System.Threading;
using Microsoft.Owin.Hosting;
using PixelByProxy.VSWindow.Server.Shared;

namespace PixelByProxy.VSWindow.Server.Host
{
    class Program
    {
        public static SocketConnection Connection;
        public static bool CloseConnection;
        public static int LauncherProcess;

        static void Main(string[] args)
        {
            IDisposable app = null;

            try
            {
                // parse out the launcher process
                if (args != null && args.Length > 0)
                    int.TryParse(args[0], out LauncherProcess);

                // start the socket
                Connection = new SocketConnection();

                // start SignalR
                app = StartWebHost();

                // notify the client that we are ready
                Console.WriteLine(ServerSettings.HostReadyText);

                // wait until all instances of VS have closed
                Process[] devEnvs = Process.GetProcessesByName("devenv");

#if DEBUG
                const int devEnvCount = 1;
#else
                const int devEnvCount = 0;
#endif

                // once all instances of VS have closed we can exit
                while (devEnvs.Length > devEnvCount && !CloseConnection)
                {
                    Thread.Sleep(1000);
                    devEnvs = Process.GetProcessesByName("devenv");
                }

                if (CloseConnection)
                    Thread.Sleep(2000); // wait for the clients to disconnect

            }
            catch (Exception ex)
            {
                Log.Instance.FatalException("Unable to start.", ex);
            }
            finally
            {
                Connection.Close();

                if (app != null)
                    app.Dispose();
            }
        }

        private static IDisposable StartWebHost()
        {
            IDisposable app = null;
            bool connected = false;
            const int maxRetries = 8;
            int currentTry = 0;

            do
            {
                currentTry++;

                try
                {
                    app = WebApplication.Start<SignalStartup>(string.Format(ServerSettings.SignalUrl, ServerSettings.SignalPort));
                    connected = true;
                }
                catch (Exception ex)
                {
                    Log.Instance.WarnException(string.Format("Unable to start the Signal R web application attempt {0} of {1}.", currentTry, maxRetries), ex);

                    if (currentTry > maxRetries)
                        throw;
                }

                if (!connected)
                    Thread.Sleep(15000);

            } while (!connected);

            return app;
        }
    }
}