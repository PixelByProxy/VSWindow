using System;
using System.Windows.Forms;

namespace PixelByProxy.VSWindow.Server.Firewall
{
    /// <summary>
    /// Class the wraps the IntPtr to a window.
    /// </summary>
    internal sealed class WindowWrapper : IWin32Window
    {
        #region Private Fields
        private readonly IntPtr _hWnd;
        #endregion

        #region Constructors
        /// <summary>
        /// Default ctor.
        /// </summary>
        /// <param name="hWnd"></param>
        public WindowWrapper(IntPtr hWnd)
        {
            _hWnd = hWnd;
        }
        #endregion

        #region IWin32Window Members
        /// <summary>
        /// Gets the IntPtr to the window handle.
        /// </summary>
        public IntPtr Handle
        {
            get { return _hWnd; }
        }
        #endregion
    }
}