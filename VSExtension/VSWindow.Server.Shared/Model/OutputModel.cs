using System;
using System.Collections.ObjectModel;
using EnvDTE;
using EnvDTE80;
using System.Linq;
using System.Globalization;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public sealed class OutputModel : ModelBase
    {
        private readonly OutputWindow _outputWindow;
        private readonly OutputWindowEvents _outputWindowEvents;

        public OutputModel(DTE2 dte)
            : base(dte)
        {
            if (dte == null)
            {
                throw new ArgumentNullException("dte", "The dte can not be null.");
            }

            _outputWindow = dte.ToolWindows.OutputWindow;
            _outputWindowEvents = dte.Events.OutputWindowEvents;

            _outputWindowEvents.PaneUpdated += Events_PaneUpdated;
        }

        #region Event Methods
        private void Events_PaneUpdated(OutputWindowPane pPane)
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

            CommandResponse response = new CommandResponse { CommandName = message.CommandName };

            switch (message.CommandName)
            {
                case "ClearOutputWindowText":
                    Clear();
                    response.CommandValue = true;
                    break;
                case "SolutionClosed":
                    response.CommandName = "GetOutputWindowText";
                    response.CommandValue = string.Empty;
                    break;
                // ReSharper disable RedundantCaseLabel
                case "GetOutputWindowText":
                // ReSharper restore RedundantCaseLabel
                default:
                    response.CommandName = "GetOutputWindowText";
                    response.CommandValue = SelectTextForDisplay();
                    break;
            }

            return response;
        }
        public override void Deactivate()
        {
            base.Deactivate();

            _outputWindowEvents.PaneUpdated -= Events_PaneUpdated;
        }
        #endregion

        #region Public Methods
        public string SelectText()
        {
            string section = string.Empty;

            if (_outputWindow.ActivePane != null && _outputWindow.ActivePane.TextDocument != null && _outputWindow.ActivePane.TextDocument.Selection != null)
            {
                _outputWindow.ActivePane.TextDocument.Selection.SelectAll();
                section = _outputWindow.ActivePane.TextDocument.Selection.Text;
                _outputWindow.ActivePane.TextDocument.Selection.EndOfDocument();
            }

            return section;
        }
        public string SelectTextForDisplay()
        {
            string section = SelectText();

            /*
            System.Text.StringBuilder builder = new System.Text.StringBuilder();

            for (int i = 0; i < 30000; i++)
            {
                builder.AppendLine("Hello World");
            }

            builder.AppendLine("Goodbye World");

            section += builder.ToString();
            */

            if (!string.IsNullOrEmpty(section) && section.Length > ServerSettings.MaxTextLength)
            {
                string subText = section.Substring(section.Length - ServerSettings.MaxTextLength);
                section = string.Concat(string.Format(CultureInfo.CurrentCulture, "Truncated {0} characters...", (section.Length - subText.Length)), Environment.NewLine, subText);
            }

            if (section != null)
            {
                var split = section.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries).Reverse();

                return string.Join(Environment.NewLine, split);
            }

            return string.Empty;
        }
        public string Clear()
        {
            string section = string.Empty;

            if (_outputWindow.ActivePane != null)
            {
                _outputWindow.ActivePane.Clear();
            }

            return section;
        }
        public Collection<string> ListItems()
        {
            string section = SelectText();
            Collection<string> items = new Collection<string>(section.Split(new [] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries));

            return items;
        }
        #endregion
    }
}