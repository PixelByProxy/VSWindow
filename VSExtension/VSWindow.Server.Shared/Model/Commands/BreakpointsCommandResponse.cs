using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public class BreakpointsCommandResponse : CommandResponse
    {
        public BreakpointsCommandResponse()
        {
            Items = new Collection<BreakpointItem>();
        }

        [DataMember]
        public int ItemCount { get; set; }
        [DataMember]
        public IEnumerable<BreakpointItem> Items { get; set; }
    }
}
