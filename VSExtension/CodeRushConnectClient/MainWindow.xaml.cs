using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Net.Sockets;
using System.Diagnostics;
using System.Collections.ObjectModel;
using PixelByProxy.VSWindow;
using PixelByProxy.VSWindow.Server;
using PixelByProxy.VSWindow.Server.Commands;

namespace CodeRushConnectClient
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();

            DataContext = this;

            Items = new ObservableCollection<object>();
        }

        private void button1_Click(object sender, RoutedEventArgs e)
        {
            //Connect(((Button)sender).CommandParameter.ToString());
        }

        private void Connect(CommandMessage message)
        {
            try
            {
                // Create a TcpClient.
                // Note, for this client to work you need to have a TcpServer 
                // connected to the same address as specified by the server, port
                // combination.
                Int32 port = 13000;
                TcpClient client = new TcpClient(serverTextBox.Text, port);

                var json = new System.Web.Script.Serialization.JavaScriptSerializer();

                byte[] data = System.Text.Encoding.ASCII.GetBytes(json.Serialize(message));

                // Get a client stream for reading and writing.
                //  Stream stream = client.GetStream();

                NetworkStream stream = client.GetStream();

                // Send the message to the connected TcpServer. 
                stream.Write(data, 0, data.Length);

                Trace.WriteLine(string.Format("Sent: {0}", message));

                // Receive the TcpServer.response.

                // Buffer to store the response bytes.
                data = new Byte[4000];

                // String to store the response ASCII representation.
                String responseData = String.Empty;

                // Read the first batch of the TcpServer response bytes.
                Int32 bytes = stream.Read(data, 0, data.Length);
                responseData = System.Text.Encoding.ASCII.GetString(data, 0, bytes);
                Trace.WriteLine(string.Format("Received: {0}", responseData));

                HandleResponse(message, responseData);
                //if (string.Equals(responseData, bool.FalseString, StringComparison.OrdinalIgnoreCase))
                //{
                //    MessageBox.Show(responseData);
                //}

                // Close everything.
                stream.Close();
                client.Close();
            }
            catch (ArgumentNullException e)
            {
                // TODO: Better
                Trace.WriteLine(string.Format("ArgumentNullException: {0}", e));
                MessageBox.Show(e.ToString());
            }
            catch (SocketException e)
            {
                Trace.WriteLine(string.Format("SocketException: {0}", e));
                MessageBox.Show(e.ToString());
            }
        }

        protected ObservableCollection<object> Items { get; set; }

        private void HandleResponse(CommandMessage message, string response)
        {
            switch (message.CommandName)
            {
                case "GetTaskList":
                    TaskListCommandResponse commandResponse = JsonHelper.Deserialize<TaskListCommandResponse>(response);

                    itemDataGrids.ItemsSource = commandResponse.UserTasks;
                    itemDataGrids.Items.Refresh();

                    break;
            }
        }

        private void ItemsComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            ComboBoxItem item = e.AddedItems[0] as ComboBoxItem;

            CommandMessage msg = new CommandMessage
            {
                CommandName = item.Tag.ToString()
            };

            Connect(msg);
        }
    }
}
