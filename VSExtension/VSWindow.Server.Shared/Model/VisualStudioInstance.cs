using System;
using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    [DataContract]
    public class VisualStudioInstance
    {
        [DataMember]
        public Guid Id { get; set; }
        [DataMember]
        public int ProcessId { get; set; }
        [DataMember]
        public string ConnectionId { get; set; }
        [DataMember]
        public string SolutionName { get; set; }
        [DataMember]
        public string Title { get; set; }
        [DataMember]
        public int Version { get; set; }
    }
}