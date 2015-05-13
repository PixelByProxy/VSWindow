using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public sealed class ConnectedCommandResponse : CommandResponse
    {
        #region Public Properties
        [DataMember]
        public override string CommandName
        {
            get { return "Connected"; }
            set { }
        }
        [DataMember]
        public string ServiceVersion { get; set; }
        [DataMember]
        public string Password { get; set; }
        [DataMember]
        public string InstanceTitle { get; set; }
        #endregion
    }
}