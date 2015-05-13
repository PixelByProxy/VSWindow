using System.Runtime.InteropServices;
using Microsoft.VisualStudio.Shell;

namespace PixelByProxy.VSWindow.Server.UI
{
    [PackageRegistration(UseManagedResourcesOnly = true)]
    [ProvideOptionPage(typeof(OptionsPageGeneral),"VS Window - Visual Studio Remote","General", 100, 102, true)]
    [ProvideProfile(typeof(OptionsPageGeneral), "VS Window - Visual Studio Remote", "General Options", 100, 102, true, DescriptionResourceID = 101)]
    [InstalledProductRegistration("VS Window - Visual Studio Remote", "Remotely control your Visual Studio development environment from your iPad.", "1.0.0.6")]
    [Guid(Constants.GuidOptionsPackage)]
    public class OptionsPagePackageCS : Package
    {
    }
}