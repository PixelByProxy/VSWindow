using System.Collections.ObjectModel;
using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public sealed class InstancesCommandResponse : CommandResponse
    {
        #region Public Properties
        [DataMember]
        public override string CommandName
        {
            get { return "Instances"; }
            set { }
        }
        [DataMember]
        public Collection<VisualStudioInstance> Instances { get; set; }
        #endregion
    }
}