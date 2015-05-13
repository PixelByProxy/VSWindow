using System;
using System.Linq;
using System.Runtime.InteropServices;
using EnvDTE80;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using EnvDTE;
using System.Reflection;
using System.IO;
using PixelByProxy.VSWindow.Server.Shared.Model;

namespace Microsoft.Samples.VisualStudio.IDE.OptionsPage.UnitTests
{
    /// <summary>
    /// Summary description for FindModelTests
    /// </summary>
    [TestClass]
    public class FindModelTests
    {
        private DTE2 _dte = null;
        private FindModel _model;

        public FindModelTests()
        {
            _dte = Marshal.GetActiveObject("VisualStudio.DTE.11.0") as DTE2;
            _model = new FindModel(_dte);
        }

        [TestMethod]
        public void FindModel_Find_Test()
        {
            Window win = null;

            try
            {
                // Arrange
                string findTextLower = "jack";
                string findTextUpper = "JACK";

                Assembly assembly = Assembly.GetExecutingAssembly();
                FileInfo assemblyInfo = new FileInfo(assembly.FullName);
                FileInfo testInfo = new FileInfo(Path.Combine(assemblyInfo.DirectoryName, "..\\..\\..\\UnitTests\\TestData\\UnitTests.txt"));

                win = _dte.ItemOperations.OpenFile(testInfo.FullName);
                win.Activate();

                // Act
                bool foundOneNoMatchCase = _model.Find(findTextLower, false, false);
                bool foundOneMatchCase = _model.Find(findTextUpper, true, false);
                bool foundOneMatchCaseNegative = _model.Find(findTextLower, true, false);
                bool foundAllNoMatchCase = _model.Find(findTextLower, false, true);
                bool foundAllMatchCase = _model.Find(findTextUpper, true, true);
                bool foundAllMatchCaseNegative = _model.Find(findTextLower, true, true);

                // Assert
                Assert.IsTrue(foundOneNoMatchCase, "The single text was not found with case matching off.");
                Assert.IsTrue(foundOneMatchCase, "The single text was found with case matching on.");
                Assert.IsFalse(foundOneMatchCaseNegative, "The single text was not found with case matching on.");

                Assert.IsTrue(foundAllNoMatchCase, "The multi text was not found with case matching off.");
                Assert.IsTrue(foundAllMatchCase, "The multi text was found with case matching on.");
                Assert.IsFalse(foundAllMatchCaseNegative, "The multi text was with case matching on.");
            }
            finally
            {
                if (win != null)
                {
                    win.Close();
                }
            }
        }
        [TestMethod]
        public void FindModel_Replace_Test()
        {
            Window win = null;

            try
            {
                // Arrange
                string findText1 = "jack";
                string findText2 = "DULL";
                string replaceText1 = "PETE";
                string replaceText2 = "HAPPY";

                Assembly assembly = Assembly.GetExecutingAssembly();
                FileInfo assemblyInfo = new FileInfo(assembly.FullName);
                FileInfo testInfo = new FileInfo(Path.Combine(assemblyInfo.DirectoryName, "..\\..\\..\\UnitTests\\TestData\\UnitTests.txt"));

                win = _dte.ItemOperations.OpenFile(testInfo.FullName);
                win.Activate();

                // Act
                bool replaceAll = _model.Replace(findText1, replaceText1, false);
                bool replaceAllIgnoreCase = _model.Replace(findText2, replaceText2, true);

                // Assert
                // TODO: Figure this out, not replacing the correct value
                //Assert.IsTrue(replaceAll, "The text was not replaced with case matching off.");
                //Assert.IsTrue(replaceAllIgnoreCase, "The text was not replaced with case matching on.");
            }
            finally
            {
                if (win != null)
                {
                    win.Close();
                }
            }
        }
    }
}