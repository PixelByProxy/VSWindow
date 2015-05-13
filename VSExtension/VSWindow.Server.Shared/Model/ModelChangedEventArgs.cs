using System;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public class ModelChangedEventArgs : EventArgs
    {
        private readonly CommandResponse _response;

        public ModelChangedEventArgs(CommandResponse response)
        {
            _response = response;
        }

        public CommandResponse Response
        {
            get { return _response; }
        }
    }
}