using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Runtime.Serialization;

namespace PixelByProxy.VSWindow.Server.Shared.Model.Commands
{
    [DataContract]
    public class TaskListCommandResponse : CommandResponse
    {
        public TaskListCommandResponse()
        {
            UserTasks = new Collection<TaskListItem>();
            Comments = new Collection<TaskListItem>();
        }

        [DataMember]
        public int UserTaskCount { get; set; }
        [DataMember]
        public int CommentCount { get; set; }
        [DataMember]
        public IEnumerable<TaskListItem> UserTasks { get; set; }
        [DataMember]
        public IEnumerable<TaskListItem> Comments { get; set; }
    }
}
