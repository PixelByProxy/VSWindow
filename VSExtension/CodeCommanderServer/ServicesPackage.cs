using System;
using System.ComponentModel.Design;
using System.Globalization;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using PixelByProxy.VSWindow.Server.Services;
using PixelByProxy.VSWindow.Server.Shared;

namespace PixelByProxy.VSWindow.Server
{
    [PackageRegistration(UseManagedResourcesOnly = true)]
    [InstalledProductRegistration("#112", "#113", "0.0.0.1", IconResourceID = 400)]
    [ProvideService(typeof(IGlobalWindowService))]
    [System.Runtime.InteropServices.Guid(Constants.GuidSevicesPackage)]
    [ProvideAutoLoad(VSConstants.UICONTEXT.NoSolution_string)]
    [ProvideAutoLoad(VSConstants.UICONTEXT.SolutionHasSingleProject_string)]
    [ProvideAutoLoad(VSConstants.UICONTEXT.SolutionHasMultipleProjects_string)]
    public sealed class ServicesPackage : Package, IVsSolutionEvents3
    {
        #region Fields
        private IGlobalWindowService _service;
        private IVsSolution _solution;
        private uint _hSolutionEvents = uint.MaxValue;
        #endregion

        #region Constructors
        public ServicesPackage()
        {
            // register our service providers
            IServiceContainer serviceContainer = this;
            serviceContainer.AddService(typeof(IGlobalWindowService), CreateService, true);
        }
        #endregion

        #region Overriden Methods
        protected override void Initialize()
        {
            base.Initialize();

            // initialize the service
            _service = GetService(typeof(IGlobalWindowService)) as IGlobalWindowService;

            AdviseSolutionEvents();
        }
        protected override void Dispose(bool disposing)
        {
            UnadviseSolutionEvents();

            if (_service != null)
            {
                _service.Close();
            }

            base.Dispose(disposing);
        }
        #endregion

        #region Private Methods
        private object CreateService(IServiceContainer container, Type serviceType)
        {
            object service = null;

            if (container == this)
            {
                // create the specified service
                if (serviceType == typeof(IGlobalWindowService))
                {
                    EnvDTE80.DTE2 dte = GetService(typeof(EnvDTE.DTE)) as EnvDTE80.DTE2;

                    service = new GlobalWindowService(dte);
                }
            }

            if (service == null)
            {
                Log.Instance.Error(string.Format(CultureInfo.CurrentCulture, "Unable to create type {0}", serviceType));
            }

            return service;
        }
        private void AdviseSolutionEvents()
        {
            UnadviseSolutionEvents();

            _solution = GetService(typeof(SVsSolution)) as IVsSolution;

            if (_solution != null)
            {
                _solution.AdviseSolutionEvents(this, out _hSolutionEvents);
            }
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
        /// <summary>
        /// Waits a couple of seconds for the window title to update before requesting an update.
        /// </summary>
        private void UpdateWindowInfo()
        {
            _service.UpdateWindowInfo();
        }
        #endregion

        #region IVsSolutionEvents3 Members
        public int OnAfterCloseSolution(object pUnkReserved)
        {
            _service.UpdateWindowInfo();

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
            var updateThread = new System.Threading.Thread(UpdateWindowInfo);
            updateThread.Start();

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