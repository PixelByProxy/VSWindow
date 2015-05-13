using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public class CommandResponse
    {
        [DataMember]
        public virtual string CommandName { get; set; }
        [DataMember]
        public object CommandValue { get; set; }
    }
}
