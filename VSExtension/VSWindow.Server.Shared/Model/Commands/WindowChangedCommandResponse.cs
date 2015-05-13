using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public sealed class WindowChangedCommandResponse : CommandResponse
    {
        #region Public Properties
        [DataMember]
        public override string CommandName
        {
            get { return "WindowChanged"; }
            set { }
        }
        [DataMember]
        public VisualStudioInstance Instance { get; set; }
        #endregion
    }
}