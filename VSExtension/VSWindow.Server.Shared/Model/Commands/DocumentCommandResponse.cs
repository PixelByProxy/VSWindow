using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public class DocumentCommandResponse : CommandResponse
    {
        public DocumentCommandResponse()
        {
            OpenDocuments = new Collection<DocumentItem>();
        }

        [DataMember]
        public int OpenDocumentCount { get; set; }
        [DataMember]
        public IEnumerable<DocumentItem> OpenDocuments { get; set; }
    }
}