using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public sealed class InstanceClosedCommandResponse : CommandResponse
    {
        #region Public Properties
        [DataMember]
        public override string CommandName
        {
            get { return "InstanceClosed"; }
            set { }
        }
        #endregion
    }
}
