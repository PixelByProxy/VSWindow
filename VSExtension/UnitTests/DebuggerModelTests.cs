using System;
using System.Linq;
using System.Runtime.InteropServices;
using EnvDTE80;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PixelByProxy.VSWindow.Server.Shared.Model;

namespace Microsoft.Samples.VisualStudio.IDE.OptionsPage.UnitTests
{
    /// <summary>
    /// Summary description for DebuggerModelTests
    /// </summary>
    [TestClass]
    public class DebuggerModelTests
    {
        private DTE2 _dte = null;
        private DebuggerModel _model;

        public DebuggerModelTests()
        {
            _dte = Marshal.GetActiveObject("VisualStudio.DTE.11.0") as DTE2;
            _model = new DebuggerModel(_dte);
        }

        [TestMethod]
        public void DebuggerModel_GetBreakpoints_Test()
        {
            // Act
            var bps = _model.ListItems();

            // Assert
            Assert.IsNotNull(bps, "The breakpoint items are null.");
            Assert.IsTrue(bps.Count > 0, "The breakpoint items are empty.");
        }
    }
}