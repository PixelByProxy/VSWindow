using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public class InstanceSelectedCommandResponse : CommandResponse
    {
        #region Public Properties
        [DataMember]
        public override string CommandName
        {
            get { return "SetActiveInstance"; }
            set { }
        }
        [DataMember]
        public VisualStudioInstance Instance { get; set; }
        #endregion
    }
}
