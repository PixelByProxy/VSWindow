// ReSharper disable RedundantUsingDirective
using System.IO;
using System.Text;
using NLog;
using NLog.Config;
using NLog.Targets;
using NLog.Targets.Wrappers;
// ReSharper restore RedundantUsingDirective

namespace PixelByProxy.VSWindow.Server.Shared
{
    public static class Log
    {
        // ReSharper disable UnusedMember.Local
        private const string LogFileName = "Logs\\VSWindow.log";
        // ReSharper restore UnusedMember.Local

        public static Logger Instance { get; private set; }

        static Log()
        {
#if DEBUG
            TraceTarget traceTarget = new TraceTarget
            {
                Layout = "${level:uppercase=true}|${message}|${exception:format=ToString,StackTrace}"
            };

            SimpleConfigurator.ConfigureForTargetLogging(traceTarget, LogLevel.Debug);
#else

            string runDir = new FileInfo(typeof(Log).Assembly.Location).DirectoryName;
            
            FileTarget target = new FileTarget
            {
                Layout = "${longdate}|${level:uppercase=true}|${message}|${exception:format=ToString,StackTrace}",
                FileName = Path.Combine(runDir, LogFileName),
                KeepFileOpen = false,
                Encoding = Encoding.UTF8
            };

            AsyncTargetWrapper wrapperTarget = new AsyncTargetWrapper
            {
                WrappedTarget = target,
                QueueLimit = 5000,
                OverflowAction = AsyncTargetWrapperOverflowAction.Discard
            };

            SimpleConfigurator.ConfigureForTargetLogging(wrapperTarget, ServerSettings.LogLevel);
#endif

            Instance = LogManager.GetLogger("VSWindow");
            Instance.Debug("Logging Started");
        }
    }
}