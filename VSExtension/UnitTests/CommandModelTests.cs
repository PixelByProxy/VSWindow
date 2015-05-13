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
    public class CommandModelTests
    {
        private DTE2 _dte = null;
        private CommandModel _model;

        public CommandModelTests()
        {
            _dte = Marshal.GetActiveObject("VisualStudio.DTE.11.0") as DTE2;
            _model = new CommandModel(_dte);
        }

        [TestMethod]
        public void CommandModel_InsertClear_Test()
        {
            // Arrange
            string insertText = "CommandModel_InsertString_Test";

            // Act
            _model.InsertString(insertText);
            string commandText = _model.SelectText();

            // Assert
            Assert.IsTrue(commandText.IndexOf(insertText, StringComparison.Ordinal) > -1, "The inserted text was not found.");

            // Act
            _model.Clear();
            commandText = _model.SelectText();

            // Assert
            Assert.IsTrue(string.Equals(commandText, ">", StringComparison.Ordinal), "The command window was not cleared.");
        }
        [TestMethod]
        public void CommandModel_Run_Test()
        {
            // Arrange
            string runText = "CommandModel_Run_Test";

            // Act
            _model.Run(runText);
            string commandText = _model.SelectText();

            // Assert
            Assert.IsTrue(commandText.IndexOf(runText, StringComparison.Ordinal) > -1, "The run command was not found.");

            // Act
            _model.Clear();
            commandText = _model.SelectText();

            // Assert
            Assert.IsTrue(string.Equals(commandText, ">", StringComparison.Ordinal), "The command window was not cleared.");
        }
    }
}