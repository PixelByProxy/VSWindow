using System;
using System.Linq;
using System.Runtime.InteropServices;
using EnvDTE80;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PixelByProxy.VSWindow.Server.Shared.Model;

namespace Microsoft.Samples.VisualStudio.IDE.OptionsPage.UnitTests
{
    /// <summary>
    /// Summary description for TaskListModelTests
    /// </summary>
    [TestClass]
    public class OutputModelTests
    {
        private DTE2 _dte = null;
        private OutputModel _model;

        public OutputModelTests()
        {
            _dte = Marshal.GetActiveObject("VisualStudio.DTE.11.0") as DTE2;
            _model = new OutputModel(_dte);
        }

        [TestMethod]
        public void OutputModel_GetOutputWindowItems_Test()
        {
            // Act
            var items = _model.ListItems();

            // Assert
            Assert.IsNotNull(items, "The output window items are null.");
            Assert.IsTrue(items.Count > 0, "The output window items are empty.");
        }
        [TestMethod]
        public void OutputModel_GetOutputWindowText_Test()
        {
            // Act
            string text = _model.SelectText();

            // Assert
            Assert.IsFalse(string.IsNullOrEmpty(text), "The output window is empty.");
        }
    }
}