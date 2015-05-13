using System;
using System.Collections.ObjectModel;
using System.IO;
using System.Runtime.Serialization;
using EnvDTE;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    [DataContract]
    public class SolutionItem : ItemBase
    {
        private const string PathPropertyName = "FullPath";
        private const string ItemTypePropertyName = "ItemType";

        public static SolutionItem CreateSolutionItem(Project item)
        {
            if (item == null)
                throw new ArgumentNullException("item", "The TaskItem can not be null.");

            SolutionItem tli = new SolutionItem
            {
                Name = item.Name,
                Saved = true,
                IsFile = false,
                ProjectItem = item
            };

            //for (int i = 1; i < (item.Properties.Count + 1); i++)
            //{
            //    var prop = item.Properties.Item(i);
            //    //System.Diagnostics.Trace.WriteLine(prop.Name + ": " + prop.Value);
            //}

            tli.GenerateId(item.UniqueName);

            return tli;
        }
        public static SolutionItem CreateSolutionItem(ProjectItem item, string parentId)
        {
            if (item == null)
                throw new ArgumentNullException("item", "The TaskItem can not be null.");

            SolutionItem tli = new SolutionItem
            {
                ParentId = parentId,
                Name = item.Name,
                Saved = true,
                ProjectSubItem = item
            };

            System.Text.StringBuilder blder = new System.Text.StringBuilder();

            for (int i = 1; i < (item.Properties.Count + 1); i++)
            {
                var prop = item.Properties.Item(i);

                switch(prop.Name)
                {
                    case PathPropertyName:
                        tli.GenerateId(prop.Value);
                        tli.Path = prop.Value;
                        break;
                    case ItemTypePropertyName:
                        tli.IsFile = true;
                        break;
                }

                blder.AppendLine(prop.Name + ": " + prop.Value);
            }

            if (tli.IsFile)
                tli.Saved = item.Document == null || item.Document.Saved;

            System.Diagnostics.Trace.WriteLine(blder.ToString());

            return tli;
        }

        [DataMember]
        public string ParentId { get; set; }
        [DataMember]
        public string Name { get; set; }
        [DataMember]
        public bool Saved { get; set; }
        [DataMember]
        public bool IsFile { get; set; }
        [IgnoreDataMember]
        public string Path { get; set; }
        [IgnoreDataMember]
        public Project ProjectItem { get; set; }
        [IgnoreDataMember]
        public ProjectItem ProjectSubItem { get; set; }
    }
}