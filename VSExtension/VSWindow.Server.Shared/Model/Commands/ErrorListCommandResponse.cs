using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public class ErrorListCommandResponse : CommandResponse
    {
        public ErrorListCommandResponse()
        {
            Errors = new Collection<ErrorListItem>();
            Warnings = new Collection<ErrorListItem>();
        }

        [DataMember]
        public int ErrorCount { get; set; }
        [DataMember]
        public int WarningCount { get; set; }
        [DataMember]
        public IEnumerable<ErrorListItem> Errors { get; set; }
        [DataMember]
        public IEnumerable<ErrorListItem> Warnings { get; set; }
    }
}