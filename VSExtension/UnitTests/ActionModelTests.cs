using System;
using System.Linq;
using System.Runtime.InteropServices;
using EnvDTE80;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using PixelByProxy.VSWindow.Server.Shared.Model;

namespace Microsoft.Samples.VisualStudio.IDE.OptionsPage.UnitTests
{
    /// <summary>
    /// Summary description for CommandModelTests
    /// </summary>
    [TestClass]
    public class ActionModelTests
    {
        private DTE2 _dte = null;
        private ToolBarModel _model;

        public ActionModelTests()
        {
            _dte = Marshal.GetActiveObject("VisualStudio.DTE.11.0") as DTE2;
            _model = new ToolBarModel(_dte);
        }

        [TestMethod]
        public void ActionModel_GetCommands_Test()
        {
            // Act
            //var items = _model.GetCommands();

            // Assert
            //Assert.IsNotNull(items, "The output window items are null.");
            //Assert.IsTrue(items.Count > 0, "The output window items are empty.");
        }
        [TestMethod]
        public void ActionModel_ExecuteCommand_Test()
        {
            // Act
            bool result = _model.Run("Edit.SelectAll");

            // Assert
            Assert.IsTrue(result, "The command failed to execute.");
        }
    }
}