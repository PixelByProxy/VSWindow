using System;
using EnvDTE;
using EnvDTE80;
using System.Linq;
using System.Globalization;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public sealed class CommandModel : ModelBase
    {
        private readonly CommandWindow _commandWindow;

        public CommandModel(DTE2 dte)
            : base(dte)
        {
            if (dte == null)
            {
                throw new ArgumentNullException("dte", "The dte can not be null.");
            }

            _commandWindow = dte.ToolWindows.CommandWindow;
        }

        #region CommandModel Members
        public override CommandResponse ExecuteCommand(CommandMessage message)
        {
            if (message == null)
            {
                throw new ArgumentNullException("message", "The message can not be null.");
            }

            CommandResponse response = new CommandResponse();
            bool selectText = true;

            switch (message.CommandName)
            {
                case "InsertCommand":
                    InsertString(message.CommandArgs);
                    break;
                case "RunCommand":
                    Run(message.CommandArgs);
                    break;
                case "ClearCommandWindowText":
                    Clear();
                    break;
                case "SolutionClosed":
                    selectText = false;
                    break;
            }

            // always return the text on a command action
            response.CommandName = "GetCommandWindowText";
            response.CommandValue = selectText ? SelectTextForDisplay() : string.Empty;
            
            return response;
        }
        #endregion

        #region Public Methods
        public string SelectText()
        {
            string selection = string.Empty;

            if (_commandWindow.TextDocument != null && _commandWindow.TextDocument.Selection != null)
            {
                _commandWindow.TextDocument.Selection.SelectAll();
                selection = _commandWindow.TextDocument.Selection.Text;
                _commandWindow.TextDocument.Selection.EndOfDocument();

                if (selection.Length > 0)
                {
                    selection = selection.TrimEnd('>');
                }
            }

            return selection;
        }
        public string SelectTextForDisplay()
        {
            string selection = SelectText();

            if (!string.IsNullOrEmpty(selection) && selection.Length > ServerSettings.MaxTextLength)
            {
                string subText = selection.Substring(selection.Length - ServerSettings.MaxTextLength);
                selection = string.Concat(string.Format(CultureInfo.CurrentCulture, "Truncated {0} characters...", (selection.Length - subText.Length)), Environment.NewLine, subText);
            }

            if (!string.IsNullOrEmpty(selection))
            {
                var split = selection.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries).Reverse();
                selection = string.Join(Environment.NewLine, split);
            }

            return selection;
        }
        public void InsertString(string text)
        {
            _commandWindow.OutputString(text);
        }
        public void Run(string command)
        {
            _commandWindow.SendInput(command, true);
        }
        public void Clear()
        {
            _commandWindow.Clear();
        }
        #endregion
    }
}