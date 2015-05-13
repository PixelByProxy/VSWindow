using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public class CommandMessage
    {
        [DataMember]
        public string CommandName { get; set; }
        [DataMember]
        public string CommandArgs { get; set; }
    }
}