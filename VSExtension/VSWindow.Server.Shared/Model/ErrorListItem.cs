using System;
using System.IO;
using System.Runtime.Serialization;
using EnvDTE80;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    [DataContract]
    public sealed class ErrorListItem : ItemBase
    {
        public static ErrorListItem Create(ErrorItem item)
        {
            if (item == null)
            {
                throw new ArgumentNullException("item", "The ErrorItem can not be null.");
            }

            ErrorListItem eli = new ErrorListItem
            {
                Description = item.Description,
                ErrorLevel = item.ErrorLevel,
                ErrorItem = item
            };

            try
            {
                // TODO: Figure out why this sometimes errors out
                eli.Project = Path.GetFileNameWithoutExtension(item.Project);
            }
            // ReSharper disable EmptyGeneralCatchClause
            catch
            // ReSharper restore EmptyGeneralCatchClause
            {
            }

            string fileName = item.FileName;
            if (!string.IsNullOrEmpty(fileName))
            {
                eli.FileName = new FileInfo(fileName).Name;

                try
                {
                    // TODO: Check this one too
                    eli.Column = item.Column;
                    eli.Line = item.Line;
                }
                // ReSharper disable EmptyGeneralCatchClause
                catch
                // ReSharper restore EmptyGeneralCatchClause
                {
                }
            }
            else
            {
                eli.FileName = string.Empty;
            }

            eli.GenerateId(eli.FileName, eli.Column, eli.Line, eli.Project);

            return eli;
        }

        [DataMember]
        public int Column { get; set; }
        [DataMember]
        public string Description { get; set; }
        [DataMember]
        public vsBuildErrorLevel ErrorLevel { get; set; }
        [DataMember]
        public string FileName { get; set; }
        [DataMember]
        public int Line { get; set; }
        [DataMember]
        public string Project { get; set; }
        [IgnoreDataMember]
        public ErrorItem ErrorItem { get; set; }
    }
}