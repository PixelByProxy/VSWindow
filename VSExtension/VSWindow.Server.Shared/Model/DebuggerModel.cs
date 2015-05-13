using System;
using System.Collections.ObjectModel;
using System.Linq;
using EnvDTE;
using EnvDTE80;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public sealed class DebuggerModel : ModelBase
    {
        private readonly Debugger _debugger;
        private readonly DocumentEvents _docEvents;
        private readonly BuildEvents _buildEvents;

        public DebuggerModel(DTE2 dte)
            : base(dte)
        {
            if (dte == null)
            {
                throw new ArgumentNullException("dte", "The dte can not be null.");
            }

            _debugger = dte.Debugger;
            _docEvents = dte.Events.DocumentEvents;
            _buildEvents = dte.Events.BuildEvents;

            _docEvents.DocumentSaved += Events_DocumentSaved;
            _buildEvents.OnBuildBegin += Events_OnBuildBegin;
        }

        #region Event Methods
        private void Events_OnBuildBegin(vsBuildScope Scope, vsBuildAction Action)
        {
            RunDefaultCommand();
        }
        private void Events_DocumentSaved(Document Document)
        {
            RunDefaultCommand();
        }
        #endregion

        #region CommandModel Members
        public override CommandResponse ExecuteCommand(CommandMessage message)
        {
            if (message == null)
            {
                throw new ArgumentNullException("message", "The message can not be null.");
            }

            BreakpointsCommandResponse response = new BreakpointsCommandResponse
            {
                CommandName = message.CommandName
            };

            bool returnItems = false;

            switch (message.CommandName)
            {
                case "NavigateBreakpoint":
                    Navigate(message.CommandArgs);
                    break;
                case "DeleteBreakpoint":
                    Delete(message.CommandArgs);
                    returnItems = true;
                    break;
                case "DeleteAllBreakpoints":
                    DeleteAll();
                    returnItems = true;
                    break;
                case "EnableBreakpoint":
                    Enable(message.CommandArgs);
                    returnItems = true;
                    break;
                case "EnableAllBreakpoints":
                    EnableAll();
                    returnItems = true;
                    break;
                case "DisableBreakpoint":
                    Disable(message.CommandArgs);
                    returnItems = true;
                    break;
                case "DisableAllBreakpoints":
                    DisableAll();
                    returnItems = true;
                    break;
                default:
                    returnItems = true;
                    break;
            }

            if (returnItems)
            {
                var items = ListItems();
                response.CommandName = "GetBreakpoints";
                response.ItemCount = items.Count;
                response.Items = items.Take(ServerSettings.MaxItemCount);
            }

            return response;
        }
        public override void Deactivate()
        {
            base.Deactivate();

            _docEvents.DocumentSaved -= Events_DocumentSaved;
            _buildEvents.OnBuildBegin -= Events_OnBuildBegin;
        }
        #endregion

        #region Public Methods
        public Collection<BreakpointItem> ListItems()
        {
            Collection<BreakpointItem> items = new Collection<BreakpointItem>();

            if (_debugger.Breakpoints != null)
            {
                for (int i = 1; i < (_debugger.Breakpoints.Count + 1); i++)
                {
                    items.Add(BreakpointItem.CreateBreakpointItem(_debugger.Breakpoints.Item(i)));
                }
            }

            /*
            for (int i = 0; i < 200; i++)
            {
                items.Add(new BreakpointItem
                {
                    Id = "a" + i.ToString(),
                    Enabled = true,
                    File = "file" + i.ToString(),
                    FileColumn = 1,
                    FileLine = 2,
                    FunctionName = "func" + i.ToString(),
                    Name = "name" + i.ToString(),
                    Tag = "a"
                });
            }
            */

            return items;
        }
        public BreakpointItem GetItemById(string id)
        {
            return ListItems().FirstOrDefault(i => string.Equals(i.Id, id, StringComparison.Ordinal));
        }
        public void Navigate(string id)
        {
            var tli = GetItemById(id);
            if (tli != null)
            {
                Breakpoint bp = tli.Breakpoint;

                DTE.MainWindow.Activate();
                Window win = DTE.ItemOperations.OpenFile(bp.File);
                if (win != null && win.Document != null && win.Document.Selection != null)
                {
                    ((TextSelection)win.Document.Selection).MoveToDisplayColumn(bp.FileLine, bp.FileColumn);
                }
            }
        }
        public void Delete(string id)
        {
            var tli = GetItemById(id);
            if (tli != null)
            {
                Breakpoint bp = tli.Breakpoint;
                if (bp != null)
                {
                    bp.Delete();
                }
            }
        }
        public void DeleteAll()
        {
            var items = ListItems();
            foreach (var tli in items)
            {
                if (tli != null)
                {
                    Breakpoint bp = tli.Breakpoint;
                    if (bp != null)
                    {
                        bp.Delete();
                    }
                }
            }
        }
        public void Enable(string id)
        {
            var tli = GetItemById(id);
            if (tli != null)
            {
                Breakpoint bp = tli.Breakpoint;
                if (bp != null)
                {
                    bp.Enabled = true;
                }
            }
        }
        public void EnableAll()
        {
            var items = ListItems();
            foreach (var tli in items)
            {
                if (tli != null)
                {
                    Breakpoint bp = tli.Breakpoint;
                    if (bp != null)
                    {
                        bp.Enabled = true;
                    }
                }
            }
        }
        public void Disable(string id)
        {
            var tli = GetItemById(id);
            if (tli != null)
            {
                Breakpoint bp = tli.Breakpoint;
                if (bp != null)
                {
                    bp.Enabled = false;
                }
            }
        }
        public void DisableAll()
        {
            var items = ListItems();
            foreach (var tli in items)
            {
                if (tli != null)
                {
                    Breakpoint bp = tli.Breakpoint;
                    if (bp != null)
                    {
                        bp.Enabled = false;
                    }
                }
            }
        }
        #endregion
    }
}