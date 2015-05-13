using System.Collections.ObjectModel;
using PixelByProxy.VSWindow.Server.Shared.Model;

namespace PixelByProxy.VSWindow.Server.Host
{
    static class ClientInfo
    {
        public static Collection<VisualStudioInstance> Instances = new Collection<VisualStudioInstance>();
    }
}