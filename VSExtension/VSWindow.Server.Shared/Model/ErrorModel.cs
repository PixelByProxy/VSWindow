using System;
using System.Collections.ObjectModel;
using System.Linq;
using EnvDTE;
using EnvDTE80;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public sealed class ErrorModel : ModelBase
    {
        private readonly ErrorList _errorList;
        private readonly BuildEvents _buildEvents;
        private readonly DocumentEvents _docEvents;

        public ErrorModel(DTE2 dte)
            : base(dte)
        {
            if (dte == null)
            {
                throw new ArgumentNullException("dte", "The dte can not be null.");
            }

            _errorList = dte.ToolWindows.ErrorList;
            _buildEvents = dte.Events.BuildEvents;
            _docEvents = dte.Events.DocumentEvents;

            _buildEvents.OnBuildDone += Events_OnBuildDone;
            _docEvents.DocumentSaved += Events_DocumentSaved;
        }

        #region Event Methods
        private void Events_OnBuildDone(vsBuildScope Scope, vsBuildAction Action)
        {
            RunDefaultCommand(500);
        }
        private void Events_DocumentSaved(Document Document)
        {
            RunDefaultCommand(1000);
        }
        #endregion

        #region CommandModel Members
        public override CommandResponse ExecuteCommand(CommandMessage message)
        {
            if (message == null)
            {
                throw new ArgumentNullException("message", "The message can not be null.");
            }

            CommandResponse response;

            switch (message.CommandName)
            {
                case "NavigateErrorItem":
                    Navigate(message.CommandArgs);
                    response = new CommandResponse { CommandName = message.CommandName, CommandValue = true };
                    break;
                default:

                    var items = ListItems();
                    var errors = items.Where(i => i.ErrorLevel == vsBuildErrorLevel.vsBuildErrorLevelHigh).ToList();
                    var warnings = items.Where(i => i.ErrorLevel == vsBuildErrorLevel.vsBuildErrorLevelMedium).ToList();

                    response = new ErrorListCommandResponse
                    {
                        CommandName = "GetErrorList",
                        ErrorCount = errors.Count,
                        Errors = errors.Take(ServerSettings.MaxItemCount),
                        WarningCount = warnings.Count,
                        Warnings = warnings.Take(ServerSettings.MaxItemCount)
                    };

                    break;
            }

            return response;
        }
        public override void Deactivate()
        {
            base.Deactivate();

            _buildEvents.OnBuildDone -= Events_OnBuildDone;
            _docEvents.DocumentSaved -= Events_DocumentSaved;
        }
        #endregion

        #region Public Methods
        public Collection<ErrorListItem> ListItems()
        {
            Collection<ErrorListItem> items = new Collection<ErrorListItem>();

            for (int i = 1; i < (_errorList.ErrorItems.Count + 1); i++)
            {
                var item = _errorList.ErrorItems.Item(i);
                if (item.ErrorLevel == vsBuildErrorLevel.vsBuildErrorLevelHigh || item.ErrorLevel == vsBuildErrorLevel.vsBuildErrorLevelMedium)
                {
                    items.Add(ErrorListItem.Create(item));
                }
            }

            /*
            for (int i = 0; i < 200; i++)
            {
                items.Add(new ErrorListItem
                {
                    Id = "abc" + i.ToString(),
                    Description = "error " + i.ToString(),
                    Column = 1,
                    ErrorLevel = vsBuildErrorLevel.vsBuildErrorLevelHigh,
                    FileName = "file" + i.ToString() + ".txt",
                    Line = 1,
                    Project = "project" + i.ToString() + ".proj"
                });
            }
            */

            return items;
        }
        public ErrorListItem GetItemById(string id)
        {
            ErrorListItem item = null;

            for (int i = 1; i < (_errorList.ErrorItems.Count + 1); i++)
            {
                var ei = _errorList.ErrorItems.Item(i);
                if (ei.ErrorLevel == vsBuildErrorLevel.vsBuildErrorLevelHigh || ei.ErrorLevel == vsBuildErrorLevel.vsBuildErrorLevelMedium)
                {
                    var eli = ErrorListItem.Create(ei);
                    if (string.Equals(eli.Id, id, StringComparison.Ordinal))
                    {
                        item = eli;
                        break;
                    }
                }
            }

            return item;
        }
        public void Navigate(string id)
        {
            var tli = GetItemById(id);
            if (tli != null)
            {
                tli.ErrorItem.Navigate();
            }
        }
        #endregion
    }
}