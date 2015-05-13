using System;
using System.Collections.ObjectModel;
using System.Linq;
using EnvDTE;
using EnvDTE80;
using PixelByProxy.VSWindow.Server.Shared.Model.Commands;

namespace PixelByProxy.VSWindow.Server.Shared.Model
{
    public sealed class TaskListModel : ModelBase
    {
        private readonly TaskList _taskList;
        private readonly TaskListEvents _tlEvents;
        //private readonly WindowEvents _winEvents;

        public TaskListModel(DTE2 dte)
            : base(dte)
        {
            _taskList = dte.ToolWindows.TaskList;
            _tlEvents = dte.Events.TaskListEvents;
            //_winEvents = dte.Events.WindowEvents;

            _tlEvents.TaskAdded += Events_TaskAdded;
            _tlEvents.TaskModified += Events_TaskModified;
            _tlEvents.TaskRemoved += Events_TaskRemoved;
            //_winEvents.WindowActivated += Events_WindowActivated;
        }

        #region Event Methods
        private void Events_TaskRemoved(TaskItem TaskItem)
        {
            RunDefaultCommand();
        }
        private void Events_TaskModified(TaskItem TaskItem, vsTaskListColumn ColumnModified)
        {
            RunDefaultCommand();
        }
        private void Events_TaskAdded(TaskItem TaskItem)
        {
            RunDefaultCommand(500);
        }
        private void Events_WindowActivated(Window GotFocus, Window LostFocus)
        {
            // for C++ file the task list changes whenever the file is activated
            if ((GotFocus != null && GotFocus.Document != null && !string.IsNullOrEmpty(GotFocus.Document.Name) && (GotFocus.Document.Name.EndsWith(".cpp", StringComparison.OrdinalIgnoreCase) || GotFocus.Document.Name.EndsWith(".h", StringComparison.OrdinalIgnoreCase))) ||
                (LostFocus != null && LostFocus.Document != null && !string.IsNullOrEmpty(LostFocus.Document.Name) && (LostFocus.Document.Name.EndsWith(".cpp", StringComparison.OrdinalIgnoreCase) || LostFocus.Document.Name.EndsWith(".h", StringComparison.OrdinalIgnoreCase))))
            {
                //RunDefaultCommand(500);
            }
        }
        #endregion

        #region CommandModel Members
        public override CommandResponse ExecuteCommand(CommandMessage message)
        {
            if (message == null)
            {
                throw new ArgumentNullException("message", "The message can not be null.");
            }
            
            TaskListCommandResponse response = new TaskListCommandResponse
            {
                CommandName = message.CommandName
            };

            bool returnTaskList = false;

            switch (message.CommandName)
            {
                case "NavigateTaskItem":
                    Navigate(message.CommandArgs);
                    break;
                case "SelectTaskItem":
                    Select(message.CommandArgs);
                    break;
                case "DeleteTaskItem":
                    Delete(message.CommandArgs);
                    break;
                case "CheckTaskItem":
                    Check(message.CommandArgs);
                    break;
                case "UncheckTaskItem":
                    Uncheck(message.CommandArgs);
                    break;
                case "AddTaskItem":
                    Add(message.CommandArgs);
                    response.CommandValue = true;
                    break;
                default:
                    returnTaskList = true;
                    break;
            }

            if (returnTaskList)
            {
                var items = ListItems();
                var comments = items.Where(i => string.Equals(i.Category, "Comment", StringComparison.OrdinalIgnoreCase)).ToList();
                var userTasks = items.Where(i => !string.Equals(i.Category, "Comment", StringComparison.OrdinalIgnoreCase)).ToList();
                response.CommandName = "GetTaskList";
                response.CommentCount = comments.Count;
                response.UserTaskCount = userTasks.Count;
                response.Comments = comments.Take(ServerSettings.MaxItemCount);
                response.UserTasks = userTasks.Take(ServerSettings.MaxItemCount);
            }

            return response;
        }
        public override void Deactivate()
        {
            base.Deactivate();

            _tlEvents.TaskAdded -= Events_TaskAdded;
            _tlEvents.TaskModified -= Events_TaskModified;
            _tlEvents.TaskRemoved -= Events_TaskRemoved;
            //_winEvents.WindowActivated -= Events_WindowActivated;
        }
        #endregion

        #region Public Methods
        public Collection<TaskListItem> ListItems()
        {
            Collection<TaskListItem> items = new Collection<TaskListItem>();

            if (DTE.ToolWindows != null && DTE.ToolWindows.TaskList != null && DTE.ToolWindows.TaskList.TaskItems != null)
            {
                for (int i = 1; i < (DTE.ToolWindows.TaskList.TaskItems.Count + 1); i++)
                {
                    TaskItem ti = DTE.ToolWindows.TaskList.TaskItems.Item(i);
                    if (!string.Equals(ti.Category, "BuildCompile", StringComparison.Ordinal) && !string.IsNullOrEmpty(ti.Description))
                    {
                        items.Add(TaskListItem.CreateTaskListItem(ti, i));
                    }
                }
            }

            /*
            for (int i = 0; i < 200; i++)
            {
                items.Add(new TaskListItem
                {
                    Id = "abc" + i.ToString(),
                    Category = "Comment",
                    Checked = true,
                    Description = "abc" + i.ToString(),
                    Displayed = true,
                    FileName = "abc" + i.ToString(),
                    Line = 1,
                    Priority = 1
                });
            }

            for (int i = 0; i < 200; i++)
            {
                items.Add(new TaskListItem
                {
                    Id = "abc" + i.ToString(),
                    Category = "UserTasks",
                    Checked = true,
                    Description = "abc" + i.ToString(),
                    Displayed = true,
                    FileName = "abc" + i.ToString(),
                    Line = 1,
                    Priority = 1
                });
            }
            */

            return items;
        }
        public TaskListItem GetItemByDescription(string description)
        {
            return ListItems().FirstOrDefault(i => string.Equals(i.Description, description, StringComparison.Ordinal));
        }
        public TaskListItem GetItemById(string id)
        {
            TaskListItem item = null;

            for (int i = 1; i < (DTE.ToolWindows.TaskList.TaskItems.Count + 1); i++)
            {
                TaskItem ti = DTE.ToolWindows.TaskList.TaskItems.Item(i);
                if (!string.Equals(ti.Category, "BuildCompile", StringComparison.Ordinal) && !string.IsNullOrEmpty(ti.Description))
                {
                    var tli = TaskListItem.CreateTaskListItem(ti, i);

                    if (string.Equals(tli.Id, id, StringComparison.Ordinal))
                    {
                        item = tli;
                        break;
                    }
                }
            }

            return item;
        }
        public void Navigate(string id)
        {
            var tli = GetItemById(id);
            if (tli != null)
            {
                tli.TaskItem.Navigate();
            }
        }
        public void Select(string id)
        {
            var tli = GetItemById(id);
            if (tli != null && tli.Displayed)
            {
                tli.TaskItem.Select();
            }
        }
        public void Delete(string id)
        {
            var tli = GetItemById(id);
            if (tli != null)
            {
                tli.TaskItem.Delete();
            }
        }
        public void Check(string id)
        {
            var tli = GetItemById(id);
            if (tli != null)
            {
                tli.TaskItem.Checked = true;
            }
        }
        public void Uncheck(string id)
        {
            var tli = GetItemById(id);
            if (tli != null)
            {
                tli.TaskItem.Checked = false;
            }
        }
        public TaskListItem Add(object args)
        {
            if (args == null)
            {
                throw new ArgumentNullException("args", "The args can not be null.");
            }

            string[] parms = args.ToString().Split(new[] { ',' }, 2);

            if (parms == null || parms.Length == 0)
            {
                throw new InvalidOperationException("The parameters are missing.");
            }

            vsTaskPriority priority = vsTaskPriority.vsTaskPriorityMedium;
            int priorityParm;

            if (int.TryParse(parms[0], out priorityParm))
            {
                priority = (vsTaskPriority)priorityParm;
            }

            TaskItem item = _taskList.TaskItems.Add(" ", Guid.NewGuid().ToString(), parms[1], priority, vsTaskIcon.vsTaskIconUser, true, string.Empty);

            return TaskListItem.CreateTaskListItem(item, 0);
        }
        #endregion
    }
}