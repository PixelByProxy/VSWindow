using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PixelByProxy.VSWindow.Server.Shared
{
    public static class RunProcess
    {
        [DllImport("user32.dll")]
        public static extern bool ShowWindowAsync(HandleRef hWnd, int nCmdShow);
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr windowHandle);
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll", SetLastError = true)]
        static extern int GetWindowLong(IntPtr hWnd, int nIndex);

        public static void BringProcessToFront(IntPtr handle)
        {
            IntPtr activeHandle = GetForegroundWindow();
            if (activeHandle != handle)
            {
                const int gwlStyle = (-16);
                const UInt32 wsMinimize = 0x20000000;
                const int swRestore = 9;

                // check if the window is minimized
                int style = GetWindowLong(handle, gwlStyle);
                if ((style & wsMinimize) == wsMinimize)
                {
                    // maximize it
                    ShowWindowAsync(new HandleRef(null, handle), swRestore);
                }

                SetForegroundWindow(handle);
            }
        }
        public static bool RunWithOutput(string exeName, string directoryName, string args, bool elevated, out string output)
        {
            var process = CreateProcess(exeName, directoryName, args, elevated, true);

            output = process.StandardOutput.ReadToEnd();
            process.WaitForExit();

            return (process.ExitCode == 0);
        }
        public static int RunWithExitCode(string exeName, string directoryName, string args, bool elevated, bool hidden)
        {
            var process = CreateProcess(exeName, directoryName, args, elevated, hidden);
            process.WaitForExit();

            return process.ExitCode;
        }
        public static bool Run(string exeName, string directoryName, string args, bool elevated, bool hidden)
        {
            return (RunWithExitCode(exeName, directoryName, args, elevated, hidden) == 0);
        }

        private static Process CreateProcess(string exeName, string directoryName, string args, bool elevated, bool hidden)
        {
            ProcessStartInfo processInfo = new ProcessStartInfo { FileName = exeName, Arguments = args };

            if (hidden)
            {
                processInfo.UseShellExecute = false;
                processInfo.RedirectStandardOutput = true;
                processInfo.CreateNoWindow = true;
            }

            if (!string.IsNullOrEmpty(directoryName))
            {
                processInfo.WorkingDirectory = directoryName;
            }

            if (elevated)
            {
                processInfo.Verb = "runas";
            }

            var process = Process.Start(processInfo);

            return process;
        }
    }
}