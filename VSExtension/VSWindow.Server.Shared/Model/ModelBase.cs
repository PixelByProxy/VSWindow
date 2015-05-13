using System;
using System.Diagnostics;
using System.Timers;
using EnvDTE;
using EnvDTE80;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public abstract class ModelBase
    {
        public EventHandler<ModelChangedEventArgs> Changed;

        private readonly DTE2 _dte;
        private readonly SolutionEvents _events;
        private readonly Timer _delayedCommandTimer;

        protected ModelBase(DTE2 dte)
        {
            if (dte == null)
            {
                throw new ArgumentNullException("dte", "The dte can not be null.");
            }

            _dte = dte;
            _events = _dte.Events.SolutionEvents;
            _delayedCommandTimer = new Timer(500);
            _delayedCommandTimer.Elapsed += DelayedCommandTimer_Elapsed;

            _events.Opened += Events_Opened;
            _events.AfterClosing += Events_AfterClosing;
            _events.Renamed += Events_Renamed;
        }

        #region Event Methods
        private void Events_Renamed(string OldName)
        {
            RunDefaultCommand();
        }
        private void Events_AfterClosing()
        {
            RunCommand(0, "SolutionClosed");
        }
        private void Events_Opened()
        {
            RunDefaultCommand();
        }
        #endregion

        protected DTE2 DTE
        {
            get { return _dte; }
        }

        public abstract CommandResponse ExecuteCommand(CommandMessage message);
        public virtual void Deactivate()
        {
            _events.Opened -= Events_Opened;
            _events.AfterClosing -= Events_AfterClosing;
            _events.Renamed -= Events_Renamed;
        }

        protected void RaiseChanged(CommandResponse response)
        {
            if (Changed != null)
            {
                Changed(this, new ModelChangedEventArgs(response));

                Trace.WriteLine("Changed");
            }
        }
        protected void RunCommand(int wait, string commandName)
        {
            Action action = delegate
            {
                if (wait > 0)
                {
                    System.Threading.Thread.Sleep(wait);
                }

                RaiseChanged(ExecuteCommand(new CommandMessage { CommandName = commandName }));
            };

            action.BeginInvoke(null, null);
        }
        protected void RunDefaultCommand(int wait)
        {
            if (wait > 0)
            {
                _delayedCommandTimer.Interval = wait;
                _delayedCommandTimer.Stop();
                _delayedCommandTimer.Start();
            }
            else
            {
                RunDefaultCommand();
            }
        }
        protected void RunDefaultCommand()
        {
            Action action = () => RaiseChanged(ExecuteCommand(new CommandMessage {CommandName = string.Empty}));
            action.BeginInvoke(null, null);
        }

        void DelayedCommandTimer_Elapsed(object sender, ElapsedEventArgs e)
        {
            _delayedCommandTimer.Stop();
            RunDefaultCommand();
        }
    }
}