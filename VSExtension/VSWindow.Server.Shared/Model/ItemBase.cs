using System;
using System.Runtime.Serialization;
using System.Text;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    [DataContract]
    public class ItemBase
    {
        [DataMember]
        public string Id { get; set; }

        protected void GenerateId(params object[] parameters)
        {
            Id = Convert.ToBase64String(Encoding.UTF8.GetBytes(string.Join(".", parameters)));
        }
    }
}