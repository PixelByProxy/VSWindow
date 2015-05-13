using System;
using System.Collections.ObjectModel;
using System.IO;
using System.Runtime.Serialization;
using EnvDTE;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    [DataContract]
    public class TaskListItem : ItemBase
    {
        public static TaskListItem CreateTaskListItem(TaskItem item, int index)
        {
            if (item == null)
            {
                throw new ArgumentNullException("item", "The TaskItem can not be null.");
            }

            const string replaceNewLine = " ";

            TaskListItem tli = new TaskListItem
            {
                Category = item.Category,
                Checked = item.Checked,
                Description = item.Description.Replace(Environment.NewLine, replaceNewLine),
                TaskItem = item
            };

            if (string.Equals(tli.Category, "Comment", StringComparison.Ordinal))
            {
                FileInfo info = new FileInfo(item.FileName);
                tli.FileName = info.Name;
                tli.Line = item.Line;
                tli.GenerateId(tli.FileName, tli.Category, tli.Description, tli.Line);
            }
            else if (string.Equals(tli.Category, "User", StringComparison.Ordinal))
            {
                tli.Displayed = item.Displayed;
                tli.Priority = (int) item.Priority;
                tli.Subcategory = item.SubCategory;
                tli.GenerateId(item.Description, index);
            }
            else
            {
                tli.GenerateId(item.Description, tli.Subcategory);
            }

            return tli;
        }

        [DataMember]
        public string Category { get; set; }
        [DataMember]
        public bool Checked { get; set; }
        [DataMember]
        public Collection<TaskListItem> Items { get; set; }
        [DataMember]
        public string Description { get; set; }
        [DataMember]
        public bool Displayed { get; set; }
        [DataMember]
        public string FileName { get; set; }
        [DataMember]
        public int Line { get; set; }
        [DataMember]
        public int Priority { get; set; }
        [DataMember]
        public string Subcategory { get; set; }
        [IgnoreDataMember]
        public TaskItem TaskItem { get; set; }
    }
}