using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public class ToolBarCommandResponse : CommandResponse
    {
        public ToolBarCommandResponse()
        {
            Items = new Collection<ToolBarItem>();
        }

        [DataMember]
        public int ItemCount { get; set; }
        [DataMember]
        public IEnumerable<ToolBarItem> Items { get; set; }
    }
}
