using System;
using System.Collections.ObjectModel;
using EnvDTE80;
using System.Linq;
using System.Collections.Generic;
using System.Globalization;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public sealed class ToolBarModel : ModelBase
    {
        private static IList<ToolBarItem> _cachedItems;
        private static readonly Object Lock = new Object();

        public ToolBarModel(DTE2 dte)
            : base(dte)
        {
        }

        #region CommandModel Members
        public override CommandResponse ExecuteCommand(CommandMessage message)
        {
            if (message == null)
            {
                throw new ArgumentNullException("message", "The message can not be null.");
            }

            ToolBarCommandResponse response = new ToolBarCommandResponse
            {
                CommandName = message.CommandName
            };

            switch (message.CommandName)
            {
                case "FindCommands":
                    var commands = FindCommands(message.CommandArgs);
                    response.Items = commands.Take(ServerSettings.MaxItemCount);
                    response.ItemCount = commands.Count;
                    break;
                case "RunCommand":
                    response.CommandValue = Run(message.CommandArgs);
                    break;
            }

            return response;
        }
        #endregion

        #region Public Methods
        public IList<ToolBarItem> ListCachedToolBarItems()
        {
            if (_cachedItems == null)
            {
                lock (Lock)
                {
                    if (_cachedItems == null)
                    {
                        /*
                        Stopwatch w = new Stopwatch();
                        w.Start();
                        */

                        var items = new Collection<ToolBarItem>();

                        foreach (EnvDTE.Command tempCmd in DTE.Commands)
                        {
                            items.Add(ToolBarItem.CreateToolBarItem(tempCmd));
                        }

                        _cachedItems = items.ToList();

                        //_cachedItems = DTE.Commands.AsParallel().OfType<EnvDTE.Command>().Select(s => ToolBarItem.CreateToolBarItem(s)).OrderBy(c => c.Id).ToList();
                        
                        //w.Stop();
                        //Trace.WriteLine("Query Took " + w.ElapsedMilliseconds);
                    }
                }
            }

            return _cachedItems;
        }
        public Collection<ToolBarItem> FindCommands(string commandName)
        {
            Collection<ToolBarItem> foundCommands = new Collection<ToolBarItem>();

            if (!string.IsNullOrEmpty(commandName))
            {
                var items = ListCachedToolBarItems();

                foreach (var item in items)
                {
                    if ((!string.IsNullOrEmpty(item.Id) && item.Id.IndexOf(commandName, StringComparison.OrdinalIgnoreCase) > -1) || (!string.IsNullOrEmpty(item.Name) && item.Name.IndexOf(commandName, StringComparison.OrdinalIgnoreCase) > -1))
                    {
                        foundCommands.Add(item);
                    }
                }
            }

            return foundCommands;
        }
        public bool Run(params string[] commands)
        {
            if (commands == null)
            {
                throw new ArgumentNullException("commands", "The commands can not be null.");
            }

            bool executed = false;
            string activeCommand = null;

            try
            {
                foreach (string command in commands)
                {
                    activeCommand = command;
                    DTE.ExecuteCommand(command);
                }

                executed = true;
            }
            catch (Exception ex)
            {
                Log.Instance.DebugException(string.Format(CultureInfo.CurrentCulture, "Failed to execute command {0}.", (activeCommand ?? string.Empty)), ex);
            }

            return executed;
        }
        #endregion
    }
}