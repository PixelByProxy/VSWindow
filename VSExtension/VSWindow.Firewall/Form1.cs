using System;
using System.Windows.Forms;
using PixelByProxy.VSWindow.Server.Firewall.Properties;
using PixelByProxy.VSWindow.Server.Shared;

namespace PixelByProxy.VSWindow.Server.Firewall
{
    public partial class Form1 : Form
    {
        private readonly int _port;
        private readonly int _oldPort;
        private readonly string _exeName;
        private readonly int _vsVersion;

        public Form1(int port, int oldPort, string exeName, int vsVersion)
        {
            InitializeComponent();

            _port = port;
            _oldPort = oldPort;
            _exeName = exeName;
            _vsVersion = vsVersion;

            PortLabel.Text = string.Format(Resources.ProgramInfo, _vsVersion);
        }

        private void EnableButton_Click(object sender, EventArgs e)
        {
            FirewallManager fw = new FirewallManager();

            try
            {
                if (_oldPort > 0)
                {
                    fw.RemovePortFirewallRule(_oldPort);
                }

                if (_port > 0 && !fw.AddPortFirewallRule(_port))
                {
                    MessageBox.Show(string.Format("Unable to update the Firewall rules. Please manually add port {0} to your Windows Firewall.", _port), "VS Window", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }

                if (!string.IsNullOrEmpty(_exeName) && !fw.AddProgramFirewallRule(_exeName, _vsVersion))
                {
                    MessageBox.Show(string.Format("Unable to update the Firewall rules. Please manually add Visual Studio \"{0}\" to your Windows Firewall.", _exeName), "VS Window", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(string.Format("Unable to update the Firewall rules. Please manually add port {0} to your Windows Firewall.{1}{2}", _port, Environment.NewLine, ex), "VS Window", MessageBoxButtons.OK, MessageBoxIcon.Error);
                Log.Instance.ErrorException("Failed to update Firewall rules.", ex);
            }

            Application.Exit();
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            Environment.ExitCode = (NeverShowCheckBox.Checked ? 2 : 0);
        }
    }
}