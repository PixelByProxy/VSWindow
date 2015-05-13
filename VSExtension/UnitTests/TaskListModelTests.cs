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
    public class TaskListModelTests
    {
        private DTE2 _dte = null;
        private TaskListModel _model;

        public TaskListModelTests()
        {
            _dte = Marshal.GetActiveObject("VisualStudio.DTE.11.0") as DTE2;
            _model = new TaskListModel(_dte);
        }

        [TestMethod]
        public void TaskListModel_Items_Test()
        {
            // Act
            var items = _model.ListItems();

            // Assert
            Assert.IsNotNull(items, "The task list items are null.");
            Assert.IsTrue(items.Count > 0, "The task list items are empty.");
        }
        [TestMethod]
        public void TaskListModel_AddDeleteSelect_Test()
        {
            // Arrange
            string taskName = "Test Item";
            int taskPriority = 1;
            string args = string.Concat(taskName, ",", taskPriority);

            // Act
            var item = _model.Add(args);
            var items = _model.ListItems();

            // Assert
            Assert.IsNotNull(item, "The added item was null.");
            Assert.IsNotNull(items.FirstOrDefault(i => string.Equals(i.Id, item.Id, StringComparison.Ordinal)), "The added item was not found.");

            // Act
            _model.Select(item.Id);
            _model.Delete(item.Id);
            items = _model.ListItems();

            // Assert
            Assert.IsNull(items.FirstOrDefault(i => string.Equals(i.Id, item.Id, StringComparison.Ordinal)), "The added item was not found.");
        }
        [TestMethod]
        public void TaskListModel_Navigate_Test()
        {
            // Arrange
            // TODO: TaskListModel_Navigate_Test
            string taskName = "TODO: TaskListModel_Navigate_Test";

            // Act
            var item = _model.GetItemByDescription(taskName);
            _model.Navigate(item.Id);

            // Assert
            Assert.IsNotNull(item, "The item with the matching description was not found.");
        }
        [TestMethod]
        public void TaskListModel_Select_Test()
        {
            // Arrange
            // TODO: TaskListModel_Select_Test
            string taskName = "TODO: TaskListModel_Select_Test";

            // Act
            var item = _model.GetItemByDescription(taskName);
            _model.Select(item.Id);

            // Assert
            Assert.IsNotNull(item, "The item with the matching description was not found.");
        }
    }
}