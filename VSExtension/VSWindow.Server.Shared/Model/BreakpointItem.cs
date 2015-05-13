using System.Runtime.Serialization;
using System.IO;
using System;
using EnvDTE;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    [DataContract]
    public sealed class BreakpointItem : ItemBase
    {
        public static BreakpointItem CreateBreakpointItem(Breakpoint item)
        {
            if (item == null)
            {
                throw new ArgumentNullException("item", "The Breakpoint can not be null.");
            }

            BreakpointItem bpi = new BreakpointItem
            {
                Enabled = item.Enabled,
                File = new FileInfo(item.File).Name,
                FileColumn = item.FileColumn,
                FileLine = item.FileLine,
                FunctionName = item.FunctionName,
                Name = item.Name,
                Tag = item.Tag,
                Breakpoint = item
            };

            bpi.GenerateId(item.File, item.FileColumn, item.FileLine, item.FunctionName);

            return bpi;
        }

        [DataMember]
        public bool Enabled { get; set; }
        [DataMember]
        public string File { get; set; }
        [DataMember]
        public int FileColumn { get; set; }
        [DataMember]
        public int FileLine { get; set; }
        [DataMember]
        public string FunctionName { get; set; }
        [DataMember]
        public string Name { get; set; }
        [DataMember]
        public string Tag { get; set; }
        [IgnoreDataMember]
        public Breakpoint Breakpoint { get; set; }
    }
}
