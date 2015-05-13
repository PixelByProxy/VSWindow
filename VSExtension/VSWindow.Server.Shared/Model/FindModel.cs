using System;
using EnvDTE;
using EnvDTE80;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public sealed class FindModel : ModelBase
    {
        public FindModel(DTE2 dte)
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

            CommandResponse response = new CommandResponse();

            switch (message.CommandName)
            {
                case "Find":
                    break;
                case "Replace":
                    break;
            }

            return response;
        }
        #endregion

        #region Public Methods
        public bool Find(string findText, bool matchCase, bool findAll)
        {
            bool found = false;
            Document doc = DTE.ActiveDocument;

            if (doc != null)
            {
                TextDocument txtDoc = doc.Object("TextDocument") as TextDocument;

                if (txtDoc != null)
                {
                    Find2 find = (Find2)DTE.Find;
                    find.WaitForFindToComplete = true;
                    find.FindWhat = findText;
                    find.MatchCase = matchCase;
                    find.Action = (findAll ? vsFindAction.vsFindActionFindAll : vsFindAction.vsFindActionFind);
                    found = (find.Execute() == vsFindResult.vsFindResultFound);
                }
            }

            return found;
        }
        public bool Replace(string findText, string replaceText, bool matchCase)
        {
            bool replaced = false;
            Document doc = DTE.ActiveDocument;

            if (doc != null)
            {
                TextDocument txtDoc = doc.Object("TextDocument") as TextDocument;

                if (txtDoc != null)
                {
                    Find2 find = (Find2)DTE.Find;
                    find.WaitForFindToComplete = true;
                    find.MatchCase = matchCase;
                    var result = find.FindReplace(vsFindAction.vsFindActionReplaceAll, findText, (int)vsFindOptions.vsFindOptionsFromStart, replaceText, vsFindTarget.vsFindTargetCurrentDocument, "", "", vsFindResultsLocation.vsFindResultsNone);
                    replaced = (result == vsFindResult.vsFindResultReplaced || result == vsFindResult.vsFindResultReplaceAndFound);
                }
            }

            return replaced;
        }
        #endregion
    }
}