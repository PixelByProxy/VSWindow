using System;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using EnvDTE;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    [DataContract]
    public sealed class ToolBarItem : ItemBase
    {
        public static ToolBarItem CreateToolBarItem(Command item)
        {
            if (item == null)
            {
                throw new ArgumentNullException("item", "The Command can not be null.");
            }

            ToolBarItem tli = new ToolBarItem
            {
                Id = item.Name,
                Name = FormatCommandName(item.LocalizedName)
            };

            return tli;
        }

        private static string FormatCommandName(string name)
        {
            const char spaceChar = ' ';
            StringBuilder bldr = new StringBuilder();

            if (!string.IsNullOrEmpty(name))
            {
                string[] parts = name.Split('.');
                string lastPart = parts.Last();
                char? lastLetter = null;

                foreach (char c in lastPart)
                {
                    if (char.IsUpper(c) && lastLetter.HasValue && char.IsLetter(lastLetter.Value) && !char.IsUpper(lastLetter.Value))
                    {
                        bldr.Append(spaceChar);
                    }

                    bldr.Append(c);

                    lastLetter = c;
                }
            }

            return bldr.ToString();
        }

        [DataMember]
        public string Name { get; set; }
    }
}