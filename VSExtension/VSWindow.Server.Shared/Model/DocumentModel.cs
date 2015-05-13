using System;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using EnvDTE;
using EnvDTE80;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;
using Process = EnvDTE.Process;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public sealed class DocumentModel : ModelBase
    {
        private readonly DocumentEvents _docEvents;
        private readonly WindowEvents _winEvents;

        public DocumentModel(DTE2 dte)
            : base(dte)
        {
            _docEvents = DTE.Events.DocumentEvents;
            _winEvents = DTE.Events.WindowEvents;

            RegisterEvents();
        }

        #region Event Methods
        private void Events_DocumentStateChanged(Document Document)
        {
            RunDefaultCommand(500);
        }
        private void Events_WindowClosing(Window Window)
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

            DocumentCommandResponse response = new DocumentCommandResponse
            {
                CommandName = message.CommandName
            };

            switch (message.CommandName)
            {
                case "NavigateDocumentItem":
                    Navigate(message.CommandArgs);
                    break;
                case "Close":
                    Close(message.CommandArgs);
                    break;
                case "CloseAll":
                    CloseAll();
                    response.CommandName = "GetOpenDocuments"; // close all returns an empty list
                    break;
                case "Explore":
                    Explore(message.CommandArgs);
                    break;
                default:
                    var openDocs = ListOpenDocuments();
                    response.CommandName = "GetOpenDocuments";
                    response.OpenDocuments = openDocs.OrderBy(od => od.Name).Take(ServerSettings.MaxItemCount);
                    response.OpenDocumentCount = openDocs.Count;
                    break;
            }

            return response;
        }
        public override void Deactivate()
        {
            base.Deactivate();

            UnregisterEvents();
        }
        #endregion

        #region Public Methods
        public Collection<DocumentItem> ListOpenDocuments()
        {
            Collection<DocumentItem> items = new Collection<DocumentItem>();

            for (int i = 1; i < (DTE.Documents.Count + 1); i++)
            {
                var item = DTE.Documents.Item(i);
                if (item.ActiveWindow != null)
                {
                    items.Add(DocumentItem.CreateDocumentItem(item));
                }
            }

            return items;
        }
        public DocumentItem GetItemById(string id)
        {
            return ListOpenDocuments().FirstOrDefault(i => string.Equals(i.Id, id, StringComparison.Ordinal));
        }
        public void Navigate(string id)
        {
            var item = GetItemById(id);
            if (item != null)
            {
                item.Document.Activate();
            }
        }
        public void Close(string id)
        {
            var item = GetItemById(id);
            if (item != null)
            {
                item.Document.Close();
            }
        }
        public void CloseAll()
        {
            try
            {
                // temporarily disable the events
                UnregisterEvents();

                ToolBarModel model = new ToolBarModel(DTE);
                model.Run("Window.CloseAllDocuments");
            }
            finally
            {
                RegisterEvents();
            }
        }
        public void Explore(string id)
        {
            var item = GetItemById(id);
            if (item != null && !string.IsNullOrEmpty(item.Document.FullName))
            {
                string windir = Environment.GetEnvironmentVariable("windir");
                if (string.IsNullOrWhiteSpace(windir))
                    windir = "C:\\Windows\\";
                else if (!windir.EndsWith("\\"))
                    windir += "\\";

                ProcessStartInfo pi = new ProcessStartInfo(windir + "explorer.exe")
                {
                    Arguments = "/select, \"" + item.Document.FullName + "\"",
                    WorkingDirectory = windir
                };

                //Start Process
                System.Diagnostics.Process.Start(pi);
            }
        }
        #endregion

        #region Private Methods
        private void RegisterEvents()
        {
            _docEvents.DocumentOpened += Events_DocumentStateChanged;
            _docEvents.DocumentClosing += Events_DocumentStateChanged;
            _docEvents.DocumentSaved += Events_DocumentStateChanged;
            _winEvents.WindowClosing += Events_WindowClosing;
        }
        private void UnregisterEvents()
        {
            _docEvents.DocumentOpened -= Events_DocumentStateChanged;
            _docEvents.DocumentClosing -= Events_DocumentStateChanged;
            _docEvents.DocumentSaved -= Events_DocumentStateChanged;
            _winEvents.WindowClosing -= Events_WindowClosing;
        }
        #endregion
    }
}