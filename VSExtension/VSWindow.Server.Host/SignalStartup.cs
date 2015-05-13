using Owin;

namespace PixelByProxy.VSWindow.Server.Host
{
    class SignalStartup
    {
        public void Configuration(IAppBuilder app)
        {
            app.MapHubs();
        }
    }
}