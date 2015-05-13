using EnvDTE;
using System;
using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    [DataContract]
    public sealed class DocumentItem : ItemBase
    {
        public static DocumentItem CreateDocumentItem(Document item)
        {
            if (item == null)
            {
                throw new ArgumentNullException("item", "The Document can not be null.");
            }

            DocumentItem di = new DocumentItem
            {
                Id = item.FullName,
                Name = item.Name,
                ReadOnly = item.ReadOnly,
                Saved = item.Saved,
                Document = item
            };

            return di;
        }

        [DataMember]
        public string Name { get; set; }
        [DataMember]
        public bool ReadOnly { get; set; }
        [DataMember]
        public bool Saved { get; set; }
        [IgnoreDataMember]
        public Document Document { get; set; }
    }
}