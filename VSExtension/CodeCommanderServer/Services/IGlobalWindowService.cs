using System;
using System.Runtime.InteropServices;

namespace PixelByProxy.VSWindow.Server.Services
{
    [Guid(Constants.GuidServicesGlobalWindowService)]
	public interface IGlobalWindowService
    {
        #region Events
        event EventHandler StatusChanged;
        #endregion

        #region Properties
        string StatusText { get; }
        #endregion

        #region Methods
        void UpdateSettings();
        void UpdateWindowInfo();
	    void Close();
        #endregion
    }
}