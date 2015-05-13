using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using EnvDTE;
using EnvDTE80;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public sealed class SolutionModel : ModelBase, IVsSolutionEvents3
    {
        private static IList<SolutionItem> _cachedItems;
        private static readonly Object Lock = new Object();

        private readonly SolutionEvents _solutionEvents;
        private readonly ProjectItemsEvents _projectItemsEvents;

        private IVsSolution _solution;
        private uint _hSolutionEvents = uint.MaxValue;

        public SolutionModel(DTE2 dte)
            : base(dte)
        {
            // TODO: Change to static class
            _solutionEvents = DTE.Events.SolutionEvents;
            _projectItemsEvents = DTE.Events.SolutionItemsEvents;

            RegisterEvents();
        }

        #region Event Methods
        private void Events_SolutionOpened()
        {
            RunDefaultCommand();
        }
        private void Events_SolutionClosed()
        {
            _cachedItems.Clear();
            RunDefaultCommand();
        }
        private void Events_ProjectItemAdded(ProjectItem ProjectItem)
        {
            // TODO: Refresh project
        }
        private void Events_ProjectItemRemoved(ProjectItem ProjectItem)
        {
            // TODO: Refresh project
        }
        private void Events_ProjectItemRenamed(ProjectItem ProjectItem, string OldName)
        {
            // TODO: Refresh solution
        }
        #endregion

        #region CommandModel Members
        public override CommandResponse ExecuteCommand(CommandMessage message)
        {
            if (message == null)
            {
                throw new ArgumentNullException("message", "The message can not be null.");
            }

            SolutionCommandResponse response = new SolutionCommandResponse
            {
                CommandName = message.CommandName
            };

            switch (message.CommandName)
            {
                case "NavigateItem":
                    var items = Navigate(message.CommandArgs);
                    if (items != null)
                    {
                        response.CommandName = "GetItems";
                        response.Items = items.OrderBy(od => od.IsFile).ThenBy(od => od.Name).Take(ServerSettings.MaxItemCount);
                        response.ItemCount = items.Count;
                    }
                    break;
                default:
                    var openDocs = GetProjects();
                    response.CommandName = "GetItems";
                    response.Items = openDocs.OrderBy(od => od.IsFile).ThenBy(od => od.Name).Take(ServerSettings.MaxItemCount);
                    response.ItemCount = openDocs.Count;
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
        public IList<SolutionItem> ListCachedProjectItems()
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

                        var items = new Collection<SolutionItem>();

                        if (DTE.Solution.IsOpen)
                        {
                            for (int i = 1; i < (DTE.Solution.Projects.Count + 1); i++)
                            {
                                var item = DTE.Solution.Projects.Item(i);
                                var solutionItem = SolutionItem.CreateSolutionItem(item);
                                items.Add(solutionItem);

                                LoadProjectItemsRecursive(items, solutionItem.Id, item.ProjectItems);
                            }
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
        public IList<SolutionItem> GetProjects()
        {
            return ListCachedProjectItems().Where(i => string.IsNullOrEmpty(i.ParentId)).ToList();
        }
        public IList<SolutionItem> GetProjectItems(string parentId)
        {
            return ListCachedProjectItems().Where(i => string.Equals(i.ParentId, parentId, StringComparison.Ordinal)).ToList();
        }
        public SolutionItem GetItemById(string id)
        {
            return ListCachedProjectItems().FirstOrDefault(i => string.Equals(i.Id, id, StringComparison.Ordinal));
        }
        public IList<SolutionItem> Navigate(string id)
        {
            IList<SolutionItem> items = null;

            var item = GetItemById(id);
            if (item != null)
            {
                if (item.IsFile)
                    DTE.ItemOperations.OpenFile(item.Path);
                else
                    items = GetProjectItems(item.Id);
            }

            return items;
        }
        #endregion

        #region Private Methods
        private void RegisterEvents()
        {
            AdviseSolutionEvents();
            _projectItemsEvents.ItemAdded += Events_ProjectItemAdded;
            _projectItemsEvents.ItemRemoved += Events_ProjectItemRemoved;
            _projectItemsEvents.ItemRenamed += Events_ProjectItemRenamed;
        }
        private void UnregisterEvents()
        {
            UnadviseSolutionEvents();
            _projectItemsEvents.ItemAdded -= Events_ProjectItemAdded;
            _projectItemsEvents.ItemRemoved -= Events_ProjectItemRemoved;
            _projectItemsEvents.ItemRenamed -= Events_ProjectItemRenamed;
        }
        private void AdviseSolutionEvents()
        {
            UnadviseSolutionEvents();

            _solution = ((IServiceProvider)DTE).GetService(typeof(SVsSolution)) as IVsSolution;

            if (_solution != null)
                _solution.AdviseSolutionEvents(this, out _hSolutionEvents);
        }
        private void UnadviseSolutionEvents()
        {
            if (_solution != null)
            {
                if (_hSolutionEvents != uint.MaxValue)
                {
                    _solution.UnadviseSolutionEvents(_hSolutionEvents);
                    _hSolutionEvents = uint.MaxValue;
                }

                _solution = null;
            }
        }
        private void LoadProjectItemsRecursive(Collection<SolutionItem> items, string parentId, ProjectItems projectItems)
        {
            if (projectItems != null)
            {
                for (int m = 1; m < (projectItems.Count + 1); m++)
                {
                    var subItem = projectItems.Item(m);
                    var solutionItem = SolutionItem.CreateSolutionItem(subItem, parentId);
                    items.Add(solutionItem);

                    if (!solutionItem.IsFile)
                        LoadProjectItemsRecursive(items, solutionItem.Id, subItem.ProjectItems);
                }
            }
        }
        #endregion

        #region IVsSolutionEvents3 Members
        public int OnAfterCloseSolution(object pUnkReserved)
        {
            // TODO: Refresh solution

            return VSConstants.S_OK;
        }
        public int OnAfterClosingChildren(IVsHierarchy pHierarchy)
        {
            return VSConstants.S_OK;
        }
        public int OnAfterLoadProject(IVsHierarchy pStubHierarchy, IVsHierarchy pRealHierarchy)
        {
            return VSConstants.S_OK;
        }
        public int OnAfterMergeSolution(object pUnkReserved)
        {
            return VSConstants.S_OK;
        }
        public int OnAfterOpenProject(IVsHierarchy pHierarchy, int fAdded)
        {
            return VSConstants.S_OK;
        }
        public int OnAfterOpenSolution(object pUnkReserved, int fNewSolution)
        {
            // TODO: Refresh solution

            return VSConstants.S_OK;
        }
        public int OnAfterOpeningChildren(IVsHierarchy pHierarchy)
        {
            return VSConstants.S_OK;
        }
        public int OnBeforeCloseProject(IVsHierarchy pHierarchy, int fRemoved)
        {
            return VSConstants.S_OK;
        }
        public int OnBeforeCloseSolution(object pUnkReserved)
        {
            return VSConstants.S_OK;
        }
        public int OnBeforeClosingChildren(IVsHierarchy pHierarchy)
        {
            return VSConstants.S_OK;
        }
        public int OnBeforeOpeningChildren(IVsHierarchy pHierarchy)
        {
            return VSConstants.S_OK;
        }
        public int OnBeforeUnloadProject(IVsHierarchy pRealHierarchy, IVsHierarchy pStubHierarchy)
        {
            return VSConstants.S_OK;
        }
        public int OnQueryCloseProject(IVsHierarchy pHierarchy, int fRemoving, ref int pfCancel)
        {
            return VSConstants.S_OK;
        }
        public int OnQueryCloseSolution(object pUnkReserved, ref int pfCancel)
        {
            return VSConstants.S_OK;
        }
        public int OnQueryUnloadProject(IVsHierarchy pRealHierarchy, ref int pfCancel)
        {
            return VSConstants.S_OK;
        }
        #endregion
    }
}