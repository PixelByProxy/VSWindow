using System;
using System.IO;
using EnvDTE80;

namespace PixelByProxy.VSWindow.Server.Shared
{
    /// <summary>
    /// Utility class.
    /// </summary>
    public static class Utils
    {
        /// <summary>
        /// Checks if the solution is open. If an error is thrown it is ignored.
        /// </summary>
        /// <param name="dte"></param>
        /// <returns></returns>
        public static bool IsSolutionOpen(DTE2 dte)
        {
            bool isOpen = false;

            try
            {
                isOpen = dte.Solution.IsOpen;
            }
            catch (Exception ex)
            {
                Log.Instance.WarnException("Unable to get the solution open state.", ex);
            }

            return isOpen;
        }
        /// <summary>
        /// Gets the solution name. If an error is thrown it is ignored.
        /// </summary>
        /// <param name="dte"></param>
        /// <returns></returns>
        public static string GetSolutionName(DTE2 dte)
        {
            string name = string.Empty;

            try
            {
                if (dte.Solution.IsOpen)
                    name = Path.GetFileNameWithoutExtension(dte.Solution.FileName);
            }
            catch (Exception ex)
            {
                Log.Instance.WarnException("Unable to get the solution name.", ex);
            }

            return name;
        }
    }
}