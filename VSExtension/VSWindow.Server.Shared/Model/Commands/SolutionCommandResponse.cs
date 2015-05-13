using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public class SolutionCommandResponse : CommandResponse
    {
        public SolutionCommandResponse()
        {
            Items = new Collection<SolutionItem>();
        }

        [DataMember]
        public int ItemCount { get; set; }
        [DataMember]
        public IEnumerable<SolutionItem> Items { get; set; }
    }
}